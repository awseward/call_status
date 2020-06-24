import asyncdispatch
import asyncfutures
import base64
import httpClient
import json
import net
import os
import redis
import sequtils
import strutils
import sugar
import times
import typetraits
import uri

import ./logs

const pubsubBaseUri = parseUri "https://patchbay.pub/pubsub"

type ClientId = distinct string

type PatchbayChannel* = object
  uri*: Uri
  expires*: Time

# Redis stuff...

type Quittable = concept x
  quit x

proc logQuit[T: Quittable](qt: T) =
  debug "Closing ", qt.type.name, "..."
  quit qt

template use(getClient, client, actions: untyped): untyped =
  let client: Quittable = getClient()
  try:
    actions
  finally:
    logQuit client

const DaySeconds = 1 * 24 * 60 * 60

proc whUrlKey(clientId: ClientId): string =
  "webhookUrl:" & clientId.string

proc redis_open(): Redis =
  let rUri = parseUri getEnv("REDIS_URL")
  let hostname = rUri.hostname
  let port = rUri.port
  debug "Opening Redis connection to ", hostname, ":", port, "..."
  result = redis.open(hostname, Port parseInt(port))
  if rUri.password != "":
    result.auth rUri.password

proc pbRegister*(rawClientId: string, path = ""): PatchbayChannel =
  let key = whUrlKey ClientId(rawClientId)
  let uri = pubsubBaseUri / encode(rawClientId, safe = true) / path
  redis_open.use client:
    discard client.setEx(key, DaySeconds, $uri)
    let expires = getTime() + client.ttl(key).int.seconds
    PatchbayChannel(uri: uri, expires: expires)

proc getAllPbUris(): seq[Uri] =
  let pattern = whUrlKey ClientId("*")
  redis_open.use client:
    client.keys(pattern).map(key => parseUri client.get(key))

proc pbPublish*(json: JsonNode) {.async.} =
  let http = newAsyncHttpClient(
    headers = newHttpHeaders {"Content-Type": "application/json"}
  )
  let httpMethod = HttpPost
  for pbUri in getAllPbUris():
    debug httpMethod, " ", pbUri
    discard await http.request($pbUri, httpMethod, body = $json)
