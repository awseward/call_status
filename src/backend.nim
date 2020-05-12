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
  let isOnCall = isOnCall person.status
  db_open().use do (conn: DbConn):
    conn.exec sql(
      """
        UPDATE people
        SET is_on_call = $1
        WHERE name = '$2';
      """ % [$isOnCall, person.name]
    )

routes:
  get "/":
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
    let forms = rows.map(fromPgRow).map(renderPerson)

    resp renderIndex(forms[0], forms[1])

  post "/api/status":
    let jsonNode = parseJson request.body
    # Maybe use logger?
    echo jsonNode
    setStatus person.fromJson(jsonNode)
    resp Http204

  post "/set_status/@name":
    let status = fromIsOnCall parseBool(request.params["is_on_call"])
    let person = Person(
      name:   @"name",
      status: status,
    )
    setStatus person
    redirect "/"

runForever()
