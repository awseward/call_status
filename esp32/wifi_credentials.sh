#!/usr/bin/env bash

set -euo pipefail

envsubst < main/wifiCredentials.template.h > main/wifiCredentials.h
