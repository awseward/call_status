import base64
import net
import os
import redis
import sequtils
import strutils
import sugar
import uri

import ./logs

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

proc registerPatchBay*(clientId: string): string =
  let channelId = encode(clientId, safe = true)
  let client = getRedisClient()
  discard client.setEx("clientid:" & clientId, DaySeconds, channelId)
  "https://patchbay.pub/pubsub/" & channelId

proc getPatchBayChannelIds*(): seq[string] =
  let client = getRedisClient()
  client.keys("clientid:*").map(k => client.get k)
