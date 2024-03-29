#!/usr/bin/env bash

set -euo pipefail

# Run as systemd service
#
# See also:
#   - https://www.linode.com/docs/quick-answers/linux/start-service-at-boot/
#   - https://gist.github.com/awseward/100cec20c2523b0c5c5bc083dd114ae8/20da7082070affdb259013b00abbdba7d4352ddc
#   - https://web.archive.org/web/20200628142802/https://ma.ttias.be/auto-restart-crashed-service-systemd/
#

set +e
if (type -f systemd-cat >/dev/null 2>&1); then
  _log() {
    local -r level="$1"
    local -r label="$2"
    systemd-cat -t "$0<$label>" -p "$level" ;
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

_pub() { mosquitto_pub --host localhost "$@"; }

_sub() { mosquitto_sub --host localhost "$@"; }

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

# This is really just to help with debugging convenience, I wouldn't probably
# actually use this outside that context
send_heartbeat() {
  jq -c -n --arg client_id "$0<${FUNCNAME[0]}>" '{ $client_id }' \
  | _pub --topic "${TOPIC_HEARTBEAT}" --stdin-line
}

# This is really just to help with debugging convenience, I wouldn't probably
# actually use this outside that context
sub_all() {
  _sub \
    --topic "${TOPIC_HEARTBEAT}" \
    --topic "${TOPIC_HEARTBEAT_LATEST}" \
    --topic "${TOPIC_PEOPLE}" \
    --verbose \
    "$@"
}

poll_statuses() {
  _name="${FUNCNAME[0]}"; info() { _info "$_name"; }
  _start_msg | info

  _sub --topic "${TOPIC_HEARTBEAT_LATEST}" -W 300 \
  | _to_elapsed_s \
  | while read -r elapsed; do
      _debug "$_name" <<< "Elapsed since last heartbeat: $elapsed seconds"
      echo "$elapsed"
    done \
  | jq --unbuffered '. <= 10' \
  | while read -r enabled; do
      if [ "$enabled" = 'false' ]; then
        info <<< 'No recent enough heartbeat, doing nothing…'
      else
        info <<< "${API_URL_PEOPLE} >> ${TOPIC_PEOPLE}"
        echo "${API_URL_PEOPLE}" \
        | xargs curl -fsS -XGET \
        | _pub --retain --stdin-file --topic "${TOPIC_PEOPLE}"
      fi
    done
}

poll_heartbeats() {
  _name="${FUNCNAME[0]}"; info() { _info "$_name" ; }
  _start_msg | info

  _sub --topic "${TOPIC_HEARTBEAT}" -W 300 \
  | while read -r msg; do
      echo "$msg" \
      | tee >("$0" _debug "$_name") \
      | jq \
          --compact-output \
          --arg timestamp "$(date --iso-8601=s)" \
          '{ $timestamp } + .'
    done \
  | _pub --retain --stdin-line --topic "${TOPIC_HEARTBEAT_LATEST}"
}

"$@"
