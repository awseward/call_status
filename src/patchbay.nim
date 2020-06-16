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
import uri

import ./logs

const pubsubBaseUri = parseUri "https://patchbay.pub/pubsub"

type ChannelId = distinct string

# Redis stuff...

const DaySeconds = 1 * 24 * 60 * 60

proc getRedisClient(): Redis =
  let rUri = parseUri getEnv("REDIS_URL")
  let hostname = rUri.hostname
  let port = rUri.port
  debug "Opening Redis connection to ", hostname, ":", port, "..."
  result = redis.open(hostname, Port parseInt(port))
  if rUri.password != "":
    result.auth rUri.password

proc registerPatchBay*(clientId: string, path = ""): Uri =
  let channelId = encode(clientId, safe = true)
  let client = getRedisClient()
  discard client.setEx("clientid:" & clientId, DaySeconds, channelId)
  pubsubBaseUri / channelId / path

proc getChannelIds(): seq[ChannelId] =
  let client = getRedisClient()
  client.keys("clientid:*").map(k => ChannelId client.get(k))

proc foo*(path: string, json: JsonNode) =
  let http = newAsyncHttpClient(
    headers = newHttpHeaders { "Content-Type": "application/json" }
  )
  let httpMethod = HttpPost

  discard waitFor all getChannelIds().map(proc (channelId: ChannelId): Future[AsyncResponse] =
    let uri = pubsubBaseUri / channelId.string / path
    debug httpMethod, " ", uri
    http.request($uri, httpMethod, body = $json)
  )
