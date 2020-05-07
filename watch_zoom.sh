#!/usr/bin/env bash

set -euo pipefail

is_on_call=0

_zoom_pids() {
  # shellcheck disable=SC2009
  echo -n "$(( $(ps aux | grep -c --regexp='zoom.*[C]ptHost') ))"
}
_date() { date -u +'%Y-%m-%dT%H:%M:%SZ' ; }
_info() { echo "[$(_date)] ${1}" ; }

_set_status() {
  local status="${1}"
  _info "Setting status to: ${status}"
  xargs -t call-status -s <<< "${status}"
}

_info "Zoom process watcher starting..."

while true; do
  if [ $is_on_call = 0 ]; then
    if [ "$(_zoom_pids)" -gt 0 ]; then
      _set_status 'on' && is_on_call=1
    fi
  else
    if [ "$(_zoom_pids)" = 0 ]; then
      _set_status 'off' && is_on_call=0
    fi
  fi
  sleep 10
done
