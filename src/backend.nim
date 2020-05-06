import asyncdispatch
import db_postgres as pg
import htmlgen as h
import jester
import json
import os
import sequtils
import strutils

var settings = newSettings()

if existsEnv("PORT"):
  settings.port = Port(parseInt(getEnv("PORT")))

proc openDb(): DbConn =
  pg.open("", "", "", getEnv("DATABASE_URL"))

routes:
  get "/":
    proc renderUser(name: string, isOn: string): string =
      let isOnACall = (isOn == "t")
      let submitText =
        if isOnACall: "Set status to \"Not On a Call\""
                else: "Set status to \"On a Call\""
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
            value=($ not isOnACall)[0]
          ),
          h.h1(name),
          h.button(type = "submit", submitText),
        )
      )

    let db   = openDb()
    let rows = db.getAllRows sql"""
      SELECT
          name
        , is_on_call
      FROM people
      ORDER BY name
      ;
    """
    db.close

    # Ew..
    let forms = rows.map(proc (r: Row): string = renderUser(r[0], r[1]))
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

          button {
            padding: 100px;
          }

          h1 {
            display: inline-block;
            margin: 15px;
            width: 80%;
            font-size: 60pt;
          }
        """
      ),
      forms[0],
      forms[1]
    )


  post "/api/status":
    let jsonNode = parseJson request.body
    echo jsonNode
    let user     = jsonNode["user"].getStr()
    let isOnCall = jsonNode["is_on_call"].getBool()
    let db       = openDb()
    db.exec sql(
      """
        UPDATE people
        SET is_on_call = $1
        WHERE name = '$2';
      """ % [ ($ isOnCall), user ]
    )
    db.close
    resp Http204

  post "/set_status/@name":
    let isOnCall = request.params["is_on_call"]
    let db       = openDb()
    let command  = sql(
      """
        UPDATE people
        SET is_on_call = '$1'
        WHERE name = '$2';
      """ % [isOnCall, @"name"]
    )

    db.exec command
    db.close

    redirect "/"

runForever()
