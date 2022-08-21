#!/usr/bin/env bash

set -euo pipefail

build() {
  apt-get update -y
  apt-get install -y --no-install-recommends \
       bison \
       ccache \
       cmake \
       dfu-util \
       flex \
       git \
       gperf \
       libffi-dev \
       libssl-dev \
       libusb-1.0-0 \
       ninja-build \
       python3 \
       python3-venv \
       wget
  apt-get clean && rm -rf /var/lib/apt/lists/*

  git clone --recursive https://github.com/espressif/esp-idf.git
  cd esp-idf/
  ./install.sh esp32
}

"$@"
