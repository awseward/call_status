#!/usr/bin/env bash

# NOTE: This currently assumes that you're calling it from the root of the
# git repository.

set -euo pipefail

DIR_APP_SUPPORT="${HOME}/Library/ApplicationSupport/local.call_status"
DIR_LOG='/tmp/log/local.call_status'
FILE_PLIST="${HOME}/Library/LaunchAgents/local.call_status.plist"

_write_plist() { tee "${FILE_PLIST}" > /dev/null ; }

_up() {
  nimble -d:ssl -d:release build

  cp 'cli'        /usr/local/bin/call-status
  cp 'check_zoom' /usr/local/bin/call_status_check_zoom

  echo -n 'Are you D or N? ' && read -r call_status_user

  ( sed -e "s/__CALL_STATUS_USER__/${call_status_user}/g" \
  | sed -e "s%__DB_FILEPATH__%${DIR_APP_SUPPORT}/call_status.db%g" \
  | _write_plist
  ) < './install/macos/local.call_status.plist.template'

  mkdir -p "${DIR_LOG}"
  mkdir -p "${DIR_APP_SUPPORT}"

  xargs -t launchctl load -w <<< "${FILE_PLIST}"

  cat <<-MSG

=====

Install complete!

---

  To tail logs, run:

    tail -f ${DIR_LOG}/watch.log

---

  To stop the zoom watcher, run:

    launchctl unload -w ${FILE_PLIST}

---

  To uninstall, run:

    macos_install.sh down

MSG
}

_down() {
  launchctl unload -w "${FILE_PLIST}"

  xargs -t rm -rvf <<- FILES
    /usr/local/bin/call-status
    /usr/local/bin/call_status_check_zoom
    /usr/local/bin/call_status_watch_zoom.sh
    ${FILE_PLIST}
FILES
}

"_${1}" "${@:2}"
