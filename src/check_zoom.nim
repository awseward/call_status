import db_sqlite
import httpClient
import logging
import options
import os
import strutils

import ./api_client
import ./db
import ./detect_zoom
let db_open = open_sqlite
import ./misc

let logger = newConsoleLogger(fmtStr = "[$datetime][$levelname] ")
addHandler logger

let user = getEnv "CALL_STATUS_USER"

db_open().use do (conn: DbConn):
  let query = sql dedent """
    CREATE TABLE IF NOT EXISTS statuses (
      name         TEXT UNIQUE NOT NULL,
      is_on_call   BOOLEAN NOT NULL,
      last_checked DATETIME NOT NULL
    )"""
  debug query.string
  conn.exec query

let lastKnown = db_open().use do (conn: DbConn) -> Option[bool]:
  let query = sql dedent """
    SELECT is_on_call
    FROM statuses
    WHERE name = ?"""
  debug query.string
  let textValue = conn.getValue(query, user)
  return if textValue == "": none bool
                       else: some parseBool(textValue)

let current = isZoomCallActive()

if lastKnown.isSome and lastKnown.get() == current:
  info "Status unchanged. Doing nothing."
  quit 0
else:
  info "New status. updating."
  let apiBaseUrl = "https://call-status.herokuapp.com"
  let user = getEnv "CALL_STATUS_USER"

  discard postStatus(apiBaseUrl, user, current)

  db_open().use do (conn: DbConn):
    conn.exec(
      sql"""
        INSERT INTO statuses (name, is_on_call, last_checked) VALUES
          (?, ?, current_timestamp)
          ON CONFLICT(name) DO UPDATE SET
            is_on_call = ?,
            last_checked = current_timestamp""",
      user,
      current,
      current
    )
