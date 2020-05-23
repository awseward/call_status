import asyncdispatch
import jester
import json
import os
import sequtils
import strutils

import ws, ws/jester_extra

import ./db_web
import ./deprecations
import ./logs
import ./models/person
import ./models/status
import ./views/index
import ./statics

let settings = newSettings()
if existsEnv("PORT"):
  settings.port = Port(parseInt(getEnv("PORT")))

logs.setupWeb()

info "version:  ", pkgVersion
info "revision: ", pkgRevision

var websockets: seq[WebSocket] = @[]

proc wsRefresh(): Future[void] {.async.} =
  # TODO: Also clean up Closed ones
  for ws in websockets:
    if ws.readyState == Open:
      await ws.send "REFRESH"

router api:
  # DEPRECATED
  get "/status":
    deprecations.ApiStatusEndpoints.check(supported, logProc):
      logProc()
      if not supported: halt Http404

    redirect "/api/people"

  get "/people": resp %*getPeople()

  # DEPRECATED
  post "/status":
    deprecations.ApiStatusEndpoints.check(supported, logProc):
      logProc()
      if not supported: halt Http404

    let jsonNode = parseJson request.body
    debug jsonNode
    updatePerson person.fromJson(jsonNode)
    discard wsRefresh()
    resp Http204

  put "/person/@name":
    let rawName: TaintedString = @"name"
    if not nameExists(rawName.string): halt Http404

    let jsonNode = parseJson request.body
    debug jsonNode

    let person = person.fromJson jsonNode
    if not(person.name == rawName.string): halt Http422

    updatePerson person
    discard wsRefresh()
    resp Http204

router web:
  get "/":
    let forms = getPeople().map(renderPerson)
    resp renderIndex(forms[0], forms[1])

  get "/ws":
    let ws = await newWebSocket(request)
    websockets.add ws
    discard ws.send("Hello from Websocket server")
    resp Http101

  # I'd like for this to be PUT, but browser forms are GET and POST only
  post "/person/@name":
    let status = status.fromIsOnCall parseBool(request.params["is_on_call"])
    let person = Person(name: @"name", status: status)
    updatePerson person
    discard wsRefresh()
    redirect "/"

routes:
  extend web, ""
  extend api, "/api"

runForever()
