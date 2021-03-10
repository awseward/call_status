#!/usr/bin/env bash

set -euo pipefail

# Run as systemd service
#
# See also:
#   - https://www.linode.com/docs/quick-answers/linux/start-service-at-boot/
#   - https://gist.github.com/awseward/100cec20c2523b0c5c5bc083dd114ae8/20da7082070affdb259013b00abbdba7d4352ddc
#   - https://web.archive.org/web/20200628142802/https://ma.ttias.be/auto-restart-crashed-service-systemd/
#

readonly mqtt_topic='call-status/heartbeat'

echo "Started at $(date --iso-8601=s)" | systemd-cat -t call_status_fake_heartbeat -p info

while true; do
  mosquitto_pub -h localhost -t "${mqtt_topic}" -r -m "$(date --iso-8601=s)"
  sleep 5
done
