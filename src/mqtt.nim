import asyncdispatch
import json
import oids
import os
import strutils
import uri

import ./logs

type MqttInfo* = object
  host*: string
  port*: int
  topic*: string

let configured* = block:
  let uri = parseUri getEnv("MQTT_SERVER")
  MqttInfo(
    host: uri.hostname,
    port: parseInt uri.port,
    topic: getEnv "MQTT_TOPIC"
  )
