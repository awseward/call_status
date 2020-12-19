#!/usr/bin/env bash

set -euo pipefail

### Setup .bin/

mkdir -v -p .bin/
PATH="$(pwd)/.bin:${PATH}"; export PATH
echo "PATH=${PATH}"

### Install uplink

curl -L https://github.com/storj/storj/releases/latest/download/uplink_linux_amd64.zip -o uplink_linux_amd64.zip
unzip -o uplink_linux_amd64.zip
mv uplink .bin/
rm -vf uplink_linux_amd64.zip

which uplink && uplink version

### Install files from dw-misc

dw_bin_install() {
  local -r dw_misc_ver='644bd6fb3209a0c1fc8ac274239eb7fc40b12584'
  local -r relpath="$1"
  local -r url="https://github.com/awseward/dw-misc/raw/${dw_misc_ver}/bin/${relpath}"
  local -r outpath=".bin/${relpath}"

  mkdir -p "$(dirname "${outpath}")"

  curl "${url}" -L -o "${outpath}"
}

dw_bin_install 'dw_push_sqlite'
dw_bin_install 'dw_signal_sqlite'
dw_bin_install 'dw_push'

chmod -v 500 .bin/*
