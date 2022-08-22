#!/usr/bin/env bash

set -euo pipefail

build_call_status_checker() {
  nimble --stacktrace:on --linetrace:on --define:release --define:ssl build --accept call_status_checker
}

build_web() {
  nimble --stacktrace:on --linetrace:on --define:release --define:useStdLib build --accept web
}

check_assets() {
  nimble assets
  git diff --exit-code --color
}

generate_docs() {
  nimble install --accept --depsOnly
  nimble docs
}

"$@"
