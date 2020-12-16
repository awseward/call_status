#!/usr/bin/env bash

set -euo pipefail

export PATH=".bin:${PATH}"
eval "$(heroku_database_url_splitter)"
echo up | xargs -t shmig
