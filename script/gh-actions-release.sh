#!/usr/bin/env bash

set -euo pipefail

_set_env_and_output() {
  local -r name_cap="$1"
  local -r value="$2"

  echo "${name_cap}=${value}" | tee -a "$GITHUB_ENV"
  echo "::set-output name=$(_lower "$name_cap")::${value}"
}

_checksum() { shasum -a 256 "$1" | cut -d ' ' -f1; }
_lower() { tr '[:upper:]' '[:lower:]' <<< "$1"; }

plan() {
  local -r git_tag="${GITHUB_REF/refs\/tags\//}"

  _set_env_and_output 'GIT_TAG' "${git_tag}"
}

create_tarball() {
  local -r tarball_filename="$(
    # shellcheck disable=SC2153
    ./script/release.sh build_tarball "${GIT_TAG}" "$(_lower "$PLATFORM_NAME")"
  )"

  xargs -t ls -lah <<< "$tarball_filename"

  _set_env_and_output 'TARBALL_FILENAME' "${tarball_filename}"
  _set_env_and_output 'TARBALL_FILEPATH' "./${tarball_filename}"
}

record_checksum() {
  # shellcheck disable=SC2153
  _set_env_and_output 'TARBALL_CHECKSUM' "$(_checksum "$TARBALL_FILENAME")"
}

"$@"
