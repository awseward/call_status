#!/usr/bin/env bash

set -euo pipefail

cat <<- MSG

This is just a dummy file to simulate the zoom in-meeting process.

It does a never-ending sleep loop, so you'll need to '^C' it.

MSG

while true; do sleep 10; done
