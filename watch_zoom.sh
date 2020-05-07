#!/usr/bin/env bash

set -euo pipefail

is_on_call=0

zoom_pids() {
  # shellcheck disable=SC2009
  echo -n "$(( $(ps aux | grep -c --regexp='zoom.*[C]ptHost') ))"
}

echo "Watching zoom..."

while true; do
  if [ $is_on_call = 0 ]; then
    if [ "$(zoom_pids)" -gt 0 ]; then
      echo "setting on..."
      is_on_call=1
      call-status -s on
    fi
  else
    if [ "$(zoom_pids)" = 0 ]; then
      echo "setting off..."
      is_on_call=0
      call-status -s off
    fi
  fi
  sleep 10
done
