import base64
import net
import os
import redis
import sequtils
import strutils
import sugar
import uri

type ChannelId = distinct string

proc patchBayPubSubUrlBase(channelId: ChannelId): string =
  "https://patchbay.pub/pubsub/" & channelId.string

# Redis stuff...

const DaySeconds = 1 * 24 * 60 * 60

proc getRedisClient(): Redis =
  let rUri = parseUri getEnv("REDIS_URL")
  let hostname = rUri.hostname
  let port = rUri.port
  result = redis.open(hostname, Port parseInt(port))
  if rUri.password != "":
    result.auth rUri.password

proc registerPatchBay*(clientId: string): string =
  let encoded = encode(clientId, safe = true)
  let client = getRedisClient()
  discard client.setEx(clientId, DaySeconds, encoded)
  patchBayPubSubUrlBase ChannelId(encoded)

proc getPatchBayChannelIds*(): seq[string] =
  let client = getRedisClient()
  client.keys("mac:*").map(k => client.get k)
