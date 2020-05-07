#!/usr/bin/env bash

set -euo pipefail

PLIST_FILEPATH="/Library/LaunchDaemons/com.call_status.plist"

_write_plist() {
  sudo tee "${PLIST_FILEPATH}" > /dev/null
}

_up() {
  local tarball_url="${1:-https://github.com/awseward/call_status/files/4590574/call-status.tar.gz}"
  local tmp_dir; tmp_dir="$(mktemp -d -t call-status)"
  local call_status_user
  echo -n 'Are you D or N? ' && read -r call_status_user

  wget -O "${tmp_dir}/call-status.tar.gz" "${tarball_url}"

  tar -zxvf "${tmp_dir}/call-status.tar.gz" -C "${tmp_dir}"

  cp "${tmp_dir}/dist/watch_zoom.sh" /usr/local/bin/call_status_watch_zoom.sh
  cp "${tmp_dir}/dist/call-status"   /usr/local/bin/call-status

  # shellcheck disable=SC2002
  cat "${tmp_dir}/dist/com.call_status.plist.template" \
    | sed -e "s/__LAUNCHCTL_USER_NAME__/${USER}/g" \
    | sed -e "s/__CALL_STATUS_USER__/${call_status_user}/g" \
    | _write_plist

  sudo mkdir -p /var/log/com.call_status.plist
  sudo chown -R "${USER}" /var/log/com.call_status.plist

  rm -rf "${tmp_dir}"

  echo "${PLIST_FILEPATH}" | xargs -t sudo launchctl load -w

  cat <<-MSG

=====

Install complete!

If everything went according to plan, you should be see a process if you run:

  ps aux | grep -e '[w]atch_zoom.sh'

---

  To tail logs, run:

    tail -f /var/log/com.call_status.plist/std{out,err}.log

---

  To stop the zoom watcher, run:

    sudo launchctl unload -w ${PLIST_FILEPATH}

---

  To uninstall, run:

    macos_install.sh down

MSG
}

_down() {
  sudo launchctl unload -w "${PLIST_FILEPATH}"

  rm -rf /usr/local/bin/call_status_watch_zoom.sh
  rm -rf /usr/local/bin/call-status
}

"_${1}" "${@:2}"
