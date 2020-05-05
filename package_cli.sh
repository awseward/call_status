#!/usr/bin/env bash

set -euo pipefail

nimble -d:ssl -d:release build cli

mkdir dist/ || true
rm -rf dist/*

cp -v cli                            dist/call-status
cp -v com.call_status.plist.template dist/
cp -v watch_zoom.sh                  dist/

tar -czvf dist/call-status.tar.gz dist/*

printf "\nPackaged CLI @ dist/call-status.tar.gz\n"
