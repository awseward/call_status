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

let logger = newConsoleLogger(fmtStr="[$datetime] - $levelname: ")
addHandler logger

let user       = getEnv "CALL_STATUS_USER"

db_open().use_command do (conn: DbConn):
  conn.exec sql"""
    CREATE TABLE IF NOT EXISTS statuses (
      name         TEXT UNIQUE NOT NULL,
      is_on_call   BOOLEAN NOT NULL,
      last_checked DATETIME NOT NULL
    )"""

let lastKnown = db_open().use_query do (conn: DbConn) -> Option[bool]:
  let textValue = conn.getValue(sql"""
    SELECT is_on_call
    FROM statuses
    WHERE name = ?""",
    user
  )
  return if textValue == "": none bool
                       else: some parseBool(textValue)

let current = isZoomCallActive()

if lastKnown.isSome and lastKnown.get() == current:
  info "Status unchanged: doing nothing."
  quit 0
else:
  let apiBaseUrl = "https://call-status.herokuapp.com"
  let user       = getEnv "CALL_STATUS_USER"

  discard postStatus(apiBaseUrl, user, current)

  db_open().use_command do (conn: DbConn):
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
