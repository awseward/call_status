#!/usr/bin/env bash

set -euo pipefail

# Run as systemd service
#
# See also:
#   - https://www.linode.com/docs/quick-answers/linux/start-service-at-boot/
#   - https://gist.github.com/awseward/100cec20c2523b0c5c5bc083dd114ae8/20da7082070affdb259013b00abbdba7d4352ddc
#   - https://web.archive.org/web/20200628142802/https://ma.ttias.be/auto-restart-crashed-service-systemd/
#

readonly topic_heartbeat='call-status/heartbeat'
readonly topic_heartbeat_latest='call-status/heartbeat/latest'

_info() { systemd-cat -t call_status_heartbeat_consumer -p info ; }

_info <<< "Started at $(date --iso-8601=s)"

while true; do
  mosquitto_sub -t "${topic_heartbeat}" | while read -r line; do
    msg="$(echo "${line}" | jq -c --arg timestamp "$(date --iso-8601=s)" '. + { $timestamp }')"
    mosquitto_pub -t "${topic_heartbeat_latest}" -r -m "${msg}"
  done
  _info <<< "subscription dropped for some reason; resubscribing…"
done
