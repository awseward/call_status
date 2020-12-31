#!/usr/bin/env bash

set -euo pipefail

readonly tag_name="$1"
readonly binary_name='call_status_checker'
readonly tarball_name="${binary_name}-${tag_name}.tar.gz"

echo "${binary_name}" | xargs -t >&2 nimble build \
  --accept --define:ssl --define:release --stacktrace:on --linetrace:on

echo "${binary_name}" | xargs -t >&2 tar -czf "${tarball_name}"

echo "${tarball_name}"
