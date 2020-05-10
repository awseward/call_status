import asyncdispatch
import db_postgres
import htmlgen as h
import jester
import json
import os
import sequtils
import strutils

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
    resp h.div(
      class = "main-wrapper",
      style(
        """
          body {
            font-family: monospace;
          }

          form {
            padding: 20px;
            text-align: center;
            margin-top: 25vh;
          }

          .main-wrapper {
            display: flex;
          }

          .half {
            flex: 0 0 50%;
            height: 100vh;
          }

          .half.is-on-call {
            background-color: #FF4136;
          }

          .half:not(.is-on-call) {
            background-color: #01FF70;
            opacity: 0.4;
          }

          details {
            margin-top: 100px;
          }

          summary {
            font-size: 20pt;
            color: #222;
          }

          button {
            margin-top: 20px;
            font-size: 14pt;
            padding: 30px 100px;
          }

          h1 {
            display: inline-block;
            margin: 15px;
            width: 80%;
            font-size: 100pt;
            font-weight: 200;
          }
        """
      ),
      # Ew...
      forms[0],
      forms[1]
    )

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
