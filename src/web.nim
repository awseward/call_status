import asyncdispatch
import jester
import json
import os
import sequtils
import strutils
import times
import uri

import ws, ws/jester_extra

import ./api_client
import ./db_web
import ./logs
import ./models/person
import ./models/status
import ./mqtt
import ./patchbay
import ./views/index
import ./statics
import ./websockets

let settings = newSettings()
if existsEnv("PORT"):
  settings.port = Port(parseInt(getEnv("PORT")))

logs.setupWeb()

info "version:  ", pkgVersion
info "revision: ", pkgRevision

proc publishUpdates() =
  wsRefreshAll()
  let json = %*getPeople()
  waitFor json.mqttPublish()
  waitFor json.pbPublish()

if defined(release):
  publishUpdates()

router api:
  get "/people": resp %*getPeople()

  put "/person/@name":
    let rawName: TaintedString = @"name"
    if not nameExists(rawName.string): halt Http404

    let jsonNode = parseJson request.body
    debug jsonNode

    let person = person.fromJson jsonNode
    if not(person.name == rawName.string): halt Http422

    updatePerson person
    publishUpdates()
    resp Http204

  post "/client/@client_id/up":
    let path = "/api/people"
    let pbChannel = pbRegister(@"client_id", path = path)

    resp %*{
      "app_url": request.makeUri path,
      "pb_url": $pbChannel.uri,
      "pb_url_expires": $pbChannel.expires,
      "mqtt": mqtt.configured
    }

router web:
  get "/":
    let forms = getPeople().map(renderPerson)
    resp renderIndex(forms[0], forms[1])

  get "/ws":
    const supportedProtocol = "REFRESH"
    let ws = await newWebSocket(request)
    if ws.protocol != supportedProtocol:
      await ws.send("Bad protocol")
      ws.close()
      resp Http400
    else:
      wsAdd ws
      resp Http101

  # I'd like for this to be PUT, but browser forms are GET and POST only
  post "/person/@name":
    let status = status.fromIsOnCall parseBool(request.params["is_on_call"])
    let person = Person(name: @"name", status: status)
    updatePerson person
    publishUpdates()
    redirect "/"

routes:
  extend web, ""
  extend api, "/api"

runForever()
