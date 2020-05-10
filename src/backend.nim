import asyncdispatch
import db_postgres
import htmlgen as h
import jester
import json
import os
import sequtils
import strutils

import ./views/index

var settings = newSettings()

if existsEnv("PORT"):
  settings.port = Port(parseInt(getEnv("PORT")))

proc db_open(): DbConn =
  db_postgres.open("", "", "", getEnv("DATABASE_URL"))

proc db_command(fn: proc(conn: DbConn)) =
  var conn: DbConn
  try:
    fn db_open()
  finally:
    conn.close()

proc db_query[T](fn: proc(conn: DbConn): T) : T =
  var conn: DbConn
  try:
    return fn db_open()
  finally:
    conn.close()

routes:
  get "/":
    proc renderUser(name: string, isOnACall: bool): string =
      let descText  =
        if isOnACall: "is on a call"
                else: "is not on a call"
      let submitText =
        if isOnACall: "Set status to \"not on a call\""
                else: "Set status to \"on a call\""
      let statusClass =  if isOnACall: "is-on-call"
                                 else: ""

      return h.div(
        class = statusClass & " half",
        h.form(
          action   = "set_status/" & name,
          `method` = "POST",
          class    = statusClass,
          h.input(
            `type` = "hidden",
            name="is_on_call",
            value=($ not isOnACall)
          ),
          h.h1(name),
          h.h2(descText),
          h.details(
            h.summary("Status not accurate?"),
            h.button(type = "submit", submitText),
          )
        )
      )

    let rows = db_query proc(conn: DbConn) : seq[Row] =
      conn.getAllRows sql"""
        SELECT
            name
          , is_on_call
        FROM people
        ORDER BY name
        ;
      """
    # Meh...
    let forms = rows.map proc (r: Row): string =
      let name = r[0]
      let isOn = r[1] == "t"
      return renderUser(name, isOn)
    resp renderIndex(forms[0], forms[1])

  proc setStatus(name: string, isOnCall: bool) =
    db_command proc(conn: DbConn) =
      conn.exec sql(
        """
          UPDATE people
          SET is_on_call = $1
          WHERE name = '$2';
        """ % [$isOnCall, name]
      )

  post "/api/status":
    let jsonNode = parseJson request.body
    echo jsonNode
    let user     = jsonNode["user"].getStr()
    let isOnCall = jsonNode["is_on_call"].getBool()

    setStatus user, isOnCall
    resp Http204

  post "/set_status/@name":
    let isOnCall = parseBool request.params["is_on_call"]
    setStatus @"name", isOnCall
    redirect "/"

runForever()
