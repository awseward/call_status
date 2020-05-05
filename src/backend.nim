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
        if isOnACall: "Set status: Not On a Call"
                else: "Set status: On a Call"
      let formClass =  if isOnACall: "is-on-call"
                               else: ""

      return h.form(
        action   = "set_status/" & name,
        `method` = "POST",
        class    = formClass,
        h.input(
          `type` = "hidden",
          name="is_on_call",
          value=($ not isOnACall)[0]
        ),
        h.h1(name),
        h.button(type = "submit", submitText),
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
      class = "form-wrapper",
      style(
        """
          body {
            font-family: monospace;
          }

          .form-wrapper form {
            padding: 20px;
          }

          .form-wrapper form.is-on-call {
            background-color: #FF4136;
          }

          .form-wrapper button {
            padding: 15px;
          }

          .form-wrapper h1 {
            display: inline-block;
            margin: 15px;
            width: 80%;
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
