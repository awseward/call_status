#!/usr/bin/env bash

set -euo pipefail

_build() {
  xargs -t >&2 \
    nimble build --accept --define:ssl --define:release --stacktrace:on --linetrace:on
}

_tar() {
  local -r tarball_name="$1"
  xargs -t >&2 tar -czf "${tarball_name}"
}

build_tarball() {
  local -r tag_name="$1"
  local -r tarball_name="${binary_name}-${tag_name}.tar.gz"

  _build <<< "${binary_name}"
  _tar "${tarball_name}" <<< "${binary_name}"

  echo "$tarball_name"
}

# ---

readonly binary_name='call_status_checker'

"$@"
