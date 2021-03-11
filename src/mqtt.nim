import asyncdispatch
import os
import strutils
import tables
import uri

let server = parseUri getEnv("MQTT_SERVER")

let host* = server.hostname

let port* = parseInt server.port

let topics* = {
  "control": getEnv "MQTT_TOPIC_CONTROL",
  "heartbeat": getEnv "MQTT_TOPIC_HEARTBEAT",
  "people": getEnv "MQTT_TOPIC_PEOPLE",
}.toTable
