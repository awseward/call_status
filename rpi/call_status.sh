#!/usr/bin/env bash

set -euo pipefail

# Run as systemd service
#
# See also:
#   - https://www.linode.com/docs/quick-answers/linux/start-service-at-boot/
#   - https://gist.github.com/awseward/100cec20c2523b0c5c5bc083dd114ae8/20da7082070affdb259013b00abbdba7d4352ddc
#   - https://web.archive.org/web/20200628142802/https://ma.ttias.be/auto-restart-crashed-service-systemd/
#

readonly api_url_people='https://call-status.herokuapp.com/api/people'
readonly topic_heartbeat='call-status/heartbeat'
readonly topic_heartbeat_latest="${topic_heartbeat}/latest"
readonly topic_people='call-status/people'

_info() { systemd-cat -t "call_status<${1}>" -p info ; }
_start_msg() { date --iso-8601=s | xargs echo 'Started at' ; }

poll_statuses() {
  _name="${FUNCNAME[0]}"; info() { _info "$_name" ; }
  _start_msg | info

  while true; do
    now_s="$(date +%s)"
    latest="$(mosquitto_sub -t "${topic_heartbeat_latest}" -C 1 -W 1 | jq -r .timestamp)"

    info <<< "latest heartbeat: ${latest}"

    if [ "${latest}" == '' ]; then
      info <<< 'no latest heartbeat; doing nothing…'
    else
      latest_s="$(date -d "${latest}" +%s)"
      diff_s="$(( now_s - latest_s ))"

      info <<< "now_s:    ${now_s}"
      info <<< "latest_s: ${latest_s}"
      info <<< "diff_s:   ${diff_s}"

      if [ $diff_s -gt 10 ]; then
        info <<< 'more than 10s since latest heartbeat; doing nothing…'
      else
        info <<< "polling: ${api_url_people} >> ${topic_people}"
        echo "${api_url_people}" \
          | xargs -t curl -s \
          | mosquitto_pub -h localhost -t "${topic_people}" -r -s
      fi
    fi

    sleep 5
  done
}

poll_heartbeats() {
  _name="${FUNCNAME[0]}"; info() { _info "$_name" ; }
  _start_msg | info

  while true; do
    mosquitto_sub -t "${topic_heartbeat}" | while read -r line; do
      msg="$(echo "${line}" | jq -c --arg timestamp "$(date --iso-8601=s)" '. + { $timestamp }')"
      mosquitto_pub -t "${topic_heartbeat_latest}" -r -m "${msg}"
    done
    info <<< "subscription dropped for some reason; resubscribing…"
  done
}

"$@"
