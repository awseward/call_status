#!/usr/bin/env bash

set -euo pipefail

LOG_DIR='/tmp/log/local.call_status'
PLIST_FILEPATH="${HOME}/Library/LaunchAgents/local.call_status.plist"

_write_plist() { tee "${PLIST_FILEPATH}" > /dev/null ; }

_up() {
  nimble -d:ssl -d:release build cli

  cp "./watch_zoom.sh" /usr/local/bin/call_status_watch_zoom.sh
  cp "./cli"   /usr/local/bin/call-status

  echo -n 'Are you D or N? ' && read -r call_status_user

  ( sed -e "s/__CALL_STATUS_USER__/${call_status_user}/g" | _write_plist ) \
    < './local.call_status.plist.template'

  mkdir -p "${LOG_DIR}"

  xargs -t launchctl load -w <<< "${PLIST_FILEPATH}"

  cat <<-MSG

=====

Install complete!

If everything went according to plan, you should be see a process if you run:

  ps aux | grep -e '[w]atch_zoom.sh'

---

  To tail logs, run:

    tail -f ${LOG_DIR}/watch.log

---

  To stop the zoom watcher, run:

    launchctl unload -w ${PLIST_FILEPATH}

---

  To uninstall, run:

    macos_install.sh down

MSG
}

_down() {
  launchctl unload -w "${PLIST_FILEPATH}"

  xargs -t rm -rvf <<- FILES
    /usr/local/bin/call_status_watch_zoom.sh
    /usr/local/bin/call-status
FILES
}

"_${1}" "${@:2}"
