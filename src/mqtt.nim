import asyncdispatch
import json
import oids
import os
import strutils
import tables
import uri

import ./logs

let server = parseUri getEnv("MQTT_SERVER")

let host* = server.hostname

let port* = parseInt server.port

let topics* = {
  "people": getEnv "MQTT_TOPIC_PEOPLE",
  "heartbeat": getEnv "MQTT_TOPIC_HEARTBEAT"
}.toTable
