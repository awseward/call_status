#!/usr/bin/env bash

set -euo pipefail

_set_env_and_output() {
  local -r name_cap="$1"
  local -r value="$1"

  echo "${name_cap}=${value}" | tee -a "$GITHUB_ENV"
  echo "::set-output name=${name_cap,,}::${value}"
}

plan() {
  local -r git_tag="${GITHUB_REF/refs\/tags\//}"

  _set_env_and_output 'GIT_TAG' "${git_tag}"
}

create_tarball() {
  local -r build="${BUILD_RELEASE_TARBALL:-./_build_release_tarball.sh}"

  # shellcheck disable=SC2153
  local -r tarball_filename="$(
    "${build}" "${GIT_TAG}" "$( tr '[:upper:]' '[:lower:]' <<< "${PLATFORM_NAME}" )"
  )"

  ls -lah

  _set_env_and_output 'TARBALL_FILENAME' "${tarball_filename}"
  _set_env_and_output 'TARBALL_FILEPATH' "./${tarball_filename}"
}

record_checksum() {
  # shellcheck disable=SC2153
  _set_env_and_output 'TARBALL_CHECKSUM' "$(
    shasum -a 256 "${TARBALL_FILENAME}" | cut -d ' ' -f1
  )"
}

"$@"
