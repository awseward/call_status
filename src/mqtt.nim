import asyncdispatch
import json
import nmqtt
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

let clientId = "uhhh" & $genOid()

proc mqttPublish*(jNode: JsonNode) {.async.} =
  let ctx = newMqttCtx clientId
  ctx.set_host(configured.host, configured.port)
  await ctx.start()
  debug "configured: ", configured
  debug "isConnected: ", ctx.isConnected
  # debug "Publishing to ", configured.host, ":", configured.port, " [", configured.topic, "]: ", $json
  await ctx.publish(configured.topic, $jNode, qos = 2, retain = true)
  await sleepAsync 500
  await ctx.disconnect()

# waitFor mqttPublish(%*{"foo": "wut"})
