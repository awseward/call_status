import asyncdispatch
import json
import nmqtt
import oids
import os
import strutils
import uri

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

let clientId = "clientId-callstatus-" & $genOid()

proc mqttPublish*(json: JsonNode) {.async.} =
  let ctx = newMqttCtx clientId
  ctx.set_host(configured.host, configured.port)
  await ctx.start()
  await ctx.publish(configured.topic, $json, qos = 1, retain = true)
  await ctx.disconnect()
