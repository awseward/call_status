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
# This can be used in place of the above for dev on a non-systemd env
# _info() { >&2 echo -n 'info: '; >&2 cat; }
_start_msg() { date --iso-8601=s | xargs echo 'Started at' ; }

_pub() {
  mosquitto_pub \
    --host localhost \
    --retain \
    "$@"
}

_sub() {
  mosquitto_sub \
    --host localhost \
    "$@"
}

_to_elapsed_s() {
  jq -r '.timestamp' \
  | xargs -I{} date -d {} +%s \
  | jq --argjson now_s "$(date +%s)" '$now_s - .'
}

fetch_if_enabled() {
  _name="${FUNCNAME[0]}"; info() { _info "$_name" ; }
  local -r enabled="$1"

  info <<< "enabled: $enabled"

  if [ "$enabled" = 'false' ]; then
    info <<< 'doing nothing…'
  else
    info <<< "${api_url_people} >> ${topic_people}"
    echo "${api_url_people}" \
    | xargs -t curl -fsS -XGET \
    | _pub --stdin-file --topic "${topic_people}"
  fi
}

poll_statuses() {
  _name="${FUNCNAME[0]}"; info() { _info "$_name" ; }
  _start_msg | info

  while true; do
    _sub --topic "${topic_heartbeat_latest}" -C 1 -W 1 \
    | _to_elapsed_s \
    | jq '. <= 10' \
    | xargs -t "$0" fetch_if_enabled

    sleep 5
  done
}

poll_heartbeats() {
  _name="${FUNCNAME[0]}"; info() { _info "$_name" ; }
  _start_msg | info

  _sub --topic "${topic_heartbeat}" \
  | while read -r msg; do
      jq \
        --compact-output \
        --arg timestamp "$(date --iso-8601=s)" \
        '{ $timestamp } + .' <<< "${msg}"
    done \
  | _pub --stdin-line --topic "${topic_heartbeat_latest}"
}

"$@"
