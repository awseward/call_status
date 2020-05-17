#!/usr/bin/env bash

set -euo pipefail

hb_tap="awseward/homebrew-tap"
hb_formula="${hb_tap}/call_status_checker"

__tap_do() {
  # shellcheck disable=SC2068
  echo "${hb_tap}" | xargs -t brew $@
}

__formula_do() {
  # shellcheck disable=SC2068
  echo "${hb_formula}" | xargs -t brew $@
}

_info() {
  __formula_do info
}

_down() {
  __formula_do services stop
  __formula_do uninstall
  __tap_do     untap
}

_up() {
  __formula_do install
  __formula_do services start
}

_bounce() {
  _down
  _up
}

"_${1:-up}"
