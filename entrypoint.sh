#!/usr/bin/env bash

set -euo pipefail

web() { ./web; }

release() { PATH="$(pwd)/.local/bin:${PATH}" ./hk/release; }

# ---

>&2 echo "$0 $*"

"$@"
