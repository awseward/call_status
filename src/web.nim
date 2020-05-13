import asyncdispatch
import db_postgres
import jester
import json
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

proc setStatus(person: Person) =
  let isOnCall = person.isOnCall()
  db_open().use do (conn: DbConn):
    conn.exec sql(
      """
        UPDATE people
        SET is_on_call = $1
        WHERE name = '$2';
      """ % [$isOnCall, person.name]
    )

proc getPeople(): seq[Person] =
  let rows = db_open().use do (conn: DbConn) -> seq[Row]:
    conn.getAllRows sql"""
      SELECT
          name
        , is_on_call
      FROM people
      WHERE name IN ('D', 'N')
      ORDER BY name
      ;
    """
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
