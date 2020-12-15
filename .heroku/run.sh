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
