import os
import strutils
import uri

type MqttInfo* = object
  host*: string
  port*: int
  topic*: string

let mqttInfo = block:
  let uri = parseUri getEnv("MQTT_SERVER")
  MqttInfo(
    host: uri.hostname,
    port: parseInt uri.port,
    topic: getEnv "MQTT_TOPIC"
  )
