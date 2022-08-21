#!/usr/bin/env bash

set -euo pipefail

# Run as systemd service
#
# See also:
#   - https://www.linode.com/docs/quick-answers/linux/start-service-at-boot/
#   - https://gist.github.com/awseward/100cec20c2523b0c5c5bc083dd114ae8/20da7082070affdb259013b00abbdba7d4352ddc
#   - https://web.archive.org/web/20200628142802/https://ma.ttias.be/auto-restart-crashed-service-systemd/
#

export API_URL_PEOPLE="${API_URL_PEOPLE:-https://call-status.herokuapp.com/api/people}"
export TOPIC_HEARTBEAT="${TOPIC_HEARTBEAT:-call-status/heartbeat}"
export TOPIC_HEARTBEAT_LATEST="${TOPIC_HEARTBEAT_LATEST:-${topic_heartbeat}/latest}"
export TOPIC_PEOPLE="${TOPIC_PEOPLE:-call-status/people}"

set +e
if (type -f systemd-cat >/dev/null 2>&1); then
  _log() {
    local -r level="$1"
    local -r label="$2"
    systemd-cat -t "call_status<$label>" -p "$level" ;
  }
else
  _log() {
    local -r level="$1"
    local -r label="$2"
    >&2 echo -n "[${level^^}] $0<$label>: "; >&2 cat;
  }
fi
set -e

_info()  { _log info "$@";  }
_debug() { _log debug "$@"; }

# This can be used in place of the above for dev on a non-systemd env
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
  jq -r --unbuffered '.timestamp' \
  | xargs -I{} date -d {} +%s \
  | while read -r latest_s; do
      jq -n \
        --argjson latest_s "$latest_s" \
        --argjson now_s    "$(date +%s)" \
        '$now_s - $latest_s'
    done
}

fetch_if_enabled() {
  _name="${FUNCNAME[0]}"; info() { _info "$_name" ; }
  local -r enabled="$1"

  if [ "$enabled" = 'false' ]; then
    info <<< 'doing nothing…'
  else
    info <<< "${API_URL_PEOPLE} >> ${TOPIC_PEOPLE}"
    echo "${API_URL_PEOPLE}" \
    | xargs -t curl -fsS -XGET \
    | _pub --stdin-file --topic "${TOPIC_PEOPLE}"
  fi
}

poll_statuses() {
  _name="${FUNCNAME[0]}"; info() { _info "$_name" ; }
  _start_msg | info

  _sub --topic "${TOPIC_HEARTBEAT_LATEST}" \
  | _to_elapsed_s \
  | jq --unbuffered '. <= 10' \
  | while read -r enabled; do
      xargs -t "$0" fetch_if_enabled <<< "$enabled"
    done
}

poll_heartbeats() {
  _name="${FUNCNAME[0]}"; info() { _info "$_name" ; }
  _start_msg | info

  _sub --topic "${TOPIC_HEARTBEAT}" \
  | while read -r msg; do
      jq \
        --compact-output \
        --arg timestamp "$(date --iso-8601=s)" \
        '{ $timestamp } + .' <<< "${msg}" \
      | tee >("$0" _debug "$_name")
    done \
  | _pub --stdin-line --topic "${TOPIC_HEARTBEAT_LATEST}"
}

"$@"
