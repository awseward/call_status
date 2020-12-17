#!/usr/bin/env bash

set -euo pipefail

### Setup .bin/

mkdir -v -p .bin/
PATH="$(pwd)/.bin:${PATH}"; export PATH
echo "PATH=${PATH}"

### Install uplink

curl -L https://github.com/storj/storj/releases/latest/download/uplink_linux_amd64.zip -o uplink_linux_amd64.zip
unzip -o uplink_linux_amd64.zip
chmod +x uplink
mv uplink .bin/
rm -f uplink_linux_amd64.zip

which uplink && uplink version

### Install files from dw-misc

readonly dw_misc_ver='6b0b3f107f8c3bebe1f482621e691368061b87a1'

curl "https://github.com/awseward/dw-misc/raw/${dw_misc_ver}/bin/dw_push_sqlite" \
  -L -o .bin/dw_push_sqlite \
  && chmod 511 .bin/dw_push_sqlite
curl "https://github.com/awseward/dw-misc/raw/${dw_misc_ver}/bin/dw_signal_sqlite" \
  -L -o .bin/dw_signal_sqlite \
  && chmod 511 .bin/dw_signal_sqlite
