import asyncdispatch
import db_postgres
import jester
import json
import logging
import os
import sequtils
import strutils

import ./db
let db_open = open_pg
import ./models/person
import ./models/status
import ./views/index

let settings = newSettings()
if existsEnv("PORT"):
  settings.port = Port(parseInt(getEnv("PORT")))

logging.addHandler newConsoleLogger(fmtStr="[$levelid] ")
logging.setLogFilter when defined(release): lvlInfo else: lvlDebug

proc setStatus(person: Person) =
  db_open().use do (conn: DbConn):
    let query = sql unindent """
      UPDATE people
      SET is_on_call = $1
      WHERE name = $2;"""
    let prepared = conn.prepare("set_person_status", query, 2)

    conn.exec prepared, $person.isOnCall(), person.name

proc getPeople(): seq[Person] =
  let rows = db_open().use do (conn: DbConn) -> seq[Row]:
    let query = sql unindent """
      SELECT
        name
      , is_on_call
      FROM people
      WHERE name IN ($1, $2)
      ORDER BY name;"""
    let prepared = conn.prepare("get_people", query, 2)

    conn.getAllrows prepared, "D", "N"

  rows.map(fromPgRow)

router api:
  get "/status":
    let jArr = newJArray()
    for person in getPeople().map(`%`):
      jArr.add person
    resp jArr

  post "/status":
    let jsonNode = parseJson request.body
    # Maybe use logger?
    echo jsonNode
    setStatus person.fromJson(jsonNode)
    resp Http204

router web:
  get "/":
    let forms = getPeople().map(renderPerson)
    resp renderIndex(forms[0], forms[1])

  post "/set_status/@name":
    let status = status.fromIsOnCall parseBool(request.params["is_on_call"])
    let person = Person(name: @"name", status: status)
    setStatus person
    redirect "/"

routes:
  extend web, ""
  extend api, "/api"

runForever()
