import argparse
import db_sqlite
import httpClient
import logging
import options
import os
import strutils
import uri

import ./api_client
import ./db
import ./detect_zoom
import ./misc
import ./models/person
import ./models/status

block logging:
  let logger = newConsoleLogger(fmtStr = "[$datetime][$levelname] ")
  addHandler logger

let db_open = open_sqlite

proc dbSetup() =
  db_open().use do (conn: DbConn):
    let query = sql dedent """
      CREATE TABLE IF NOT EXISTS statuses (
        name         TEXT UNIQUE NOT NULL,
        is_on_call   BOOLEAN NOT NULL,
        last_checked DATETIME NOT NULL
      )"""
    debug query.string
    conn.exec query

proc tryParseBool(str: string): Option[bool] =
  if str == "":
    none bool
  else:
    try: some parseBool(str) except ValueError: none bool

proc getLastKnownLocalStatus(conn: DbConn, name: string): Option[bool] =
  let query = sql dedent """
    SELECT is_on_call
    FROM statuses
    WHERE name = ?"""
  debug query.string
  tryParseBool conn.getValue(query, name)

proc updatePerson(conn: DbConn, person: Person) =
  let query = sql dedent """
    INSERT INTO statuses (name, is_on_call, last_checked) VALUES
      (?, ?, current_timestamp)
      ON CONFLICT(name) DO UPDATE SET
        is_on_call = ?,
        last_checked = current_timestamp"""
  debug query.string
  let isOnCall = person.isOnCall()
  conn.exec query, person.name, isOnCall, isOnCall

proc main(name: string, apiBaseUrl: string, dryRun: bool, force: bool) =
  dbsetup()
  let lastKnown = db_open().use do (conn: DbConn) -> Option[bool]:
    getLastKnownLocalStatus(conn, name)
  let current = isZoomCallActive()

  if (not force) and lastKnown.isSome and lastKnown.get() == current:
    info "Status unchanged. Doing nothing."
    quit 0
  else:
    if dryRun:
      info "New status, but dry run. Doing nothing."
      return
    info "Updating."
    let person = Person(
      name: name,
      status: status.fromIsOnCall current
    )
    newApiClient(apiBaseUrl).updatePerson person
    db_open().use do (conn: DbConn): conn.updatePerson person

let p = newParser("check-zoom"):
  help "Check Zoom call status and update Call Status API accordingly"

  flag "-n", "--dry-run"

  flag "-f", "--force"

  option "-u", "--user", choices = @["D", "N"], env = "CALL_STATUS_USER"

  option "--api-base-url",
    default = "https://call-status.herokuapp.com",
    env = "CALL_STATUS_API_BASE_URL"

  run:
    if opts.user == "":
      echo "ERROR: Call Status user is required"
      echo p.help
      quit 1

    main opts.user, opts.apiBaseUrl, opts.dryRun, opts.force

p.run()
