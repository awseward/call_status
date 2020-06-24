#!/usr/bin/env bash

set -euo pipefail

git remote show heroku \
  && >&2 echo -e "\nERROR: Found an existing git remote named 'heroku'. Aborting." \
  && exit 1

heroku create --buildpack heroku/nodejs
heroku buildpacks:add https://github.com/awseward/heroku-buildpack-nim
heroku addons:create heroku-postgresql:hobby-dev
heroku addons:create heroku-redis:hobby-dev

heroku config:set IS_HEROKU=true
heroku config:set NIM_BRANCH=devel
heroku config:set NIM_REV=dc3919bb1af89799e391b4c4ecd0f1f60f7862ff
heroku config:set NIMBLE_FLAGS='-d:release -d:ssl'
heroku config:set MQTT_SERVER=mqtt://broker.mqttdashboard.com:1883
heroku config:set MQTT_TOPIC="call-status/$(hexdump -n 16 -e '4/4 "%08X" 1 "\n"' /dev/random)"

git push heroku master
