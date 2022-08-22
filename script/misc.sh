#!/usr/bin/env bash

set -euo pipefail

_nimble_assets() {
  # See: https://web.archive.org/web/20200515050555/https://www.rockyourcode.com/how-to-serve-static-files-with-nim-and-jester-on-heroku/
  type nimassets || nimble deps
  nimassets --help && echo src/views/assets_file.nim \
    | xargs -t -I{} nimassets --dir=public --output={}
}

_nimble_deps() {
  echo '--depsOnly' | xargs -t nimble install --accept
}

_nimble_docs() {
  nimble doc --project src/call_status_checker.nim
  nimble doc --project src/call_status_cli.nim
  # Web currently errors here, will have to figure out why
  # nimble doc --project src/web.nim
}

_nimble_pretty() {
  type nimpretty
  find . -type f -not -name 'assets_file.nim' -name '*.nim' \
    | xargs -t nimpretty --indent:2 --maxLineLen:120
}

_nimble_watch_web() {
  find . -type f -name '*.nim' -or -name '*.nimf' \
    | entr -r nimble -d:useStdLib run web
}

_nimble_watch_zoom() {
  while true; do nimble -d:ssl run call_status_checker check; sleep 10; done
}

_nimble_simulate_call_zoom() {
  script/zoomCptHost.sh
}

_nimble_heroku_build() {
  echo '--version' | xargs -t nim
  echo '--version' | xargs -t nimble
  nimble deps
  nimble assets
  make heroku-local-bins
}

"$@"
