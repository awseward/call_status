import argparse
import db_sqlite
import httpClient
import options
import os
import strutils
import sugar

import ./api_client
import ./checker_config
import ./db
import ./detect_zoom
import ./logs
import ./misc
import ./models/person
import ./models/status
import ./statics

logs.setupChecker()

block tempBackwardsCompat:
  # Would like to use DATABASE_FILEPATH, but will have to migrate existing
  # installs to be safe. In the meantime, this should do it.
  if not(existsEnv "DATABASE_FILEPATH") and existsEnv "DB_FILEPATH":
    putEnv("DATABASE_FILEPATH", getEnv("DB_FILEPATH"))

let db_open = open_sqlite

proc dbSetup() =
  let query = sql dedent """
    CREATE TABLE IF NOT EXISTS statuses (
      name         TEXT UNIQUE NOT NULL,
      is_on_call   BOOLEAN NOT NULL,
      last_checked DATETIME NOT NULL
    )"""
  debug query.string

  db_open.use conn:
    conn.exec query

proc tryParseBool(str: string): Option[bool] =
  if str == "":
    none bool
  else:
    try: some parseBool(str) except ValueError: none bool

proc getLastKnownLocalStatus(name: string): Option[bool] =
  let query = sql dedent """
    SELECT is_on_call
    FROM statuses
    WHERE name = ?"""
  debug query.string
  db_open.use conn:
    tryParseBool conn.getValue(query, name)

proc updatePerson(person: Person) =
  let query = sql dedent """
    INSERT INTO statuses (name, is_on_call, last_checked) VALUES
      (?, ?, current_timestamp)
      ON CONFLICT(name) DO UPDATE SET
        is_on_call = ?,
        last_checked = current_timestamp"""
  debug query.string
  let isOnCall = person.isOnCall()
  db_open.use conn: conn.exec query, person.name, isOnCall, isOnCall

proc runCheck(name: string, apiBaseUrl: string, dryRun: bool, force: bool) =
  dbSetup()
  let lastKnown = getLastKnownLocalStatus(name)
  let current = isZoomCallActive()

  if (not force) and lastKnown.isSome and lastKnown.get() == current:
    info "Status unchanged; doing nothing."
    quit 0
  else:
    if dryRun:
      info "New status (or just forced update), but dry run; doing nothing."
      return
    info "New status (or just forced update); updating."
    let person = Person(
      name: name,
      status: status.fromIsOnCall current
    )
    newApiClient(apiBaseUrl).updatePerson person
    updatePerson person

proc runConfig(name: string) =
  CheckerConfig(userName: name).writeConfigFile getEnv("CONFIG_FILEPATH")

const APP_NAME = "call_status_checker"

let p = newParser(APP_NAME):
  help "Check call status and update Call Status API accordingly"

  flag("--version",  help = "Print the version of " & APP_NAME)
  flag("--revision", help = "Print the Git SHA of " & APP_NAME)
  flag("--info",     help = "Print version and revision")

  command "config":
    option "-u", "--user", choices = @["D", "N"], env = "CALL_STATUS_USER"
    run:
      let user = opts.user
      if user == "":
        echo "ERROR: User is required, but was not provided"
        echo p.help
        quit 1

      runConfig user

  command "check":
    option "-u", "--user", choices = @["D", "N"], env = "CALL_STATUS_USER"

    flag "-n", "--dry-run"
    flag "-f", "--force"

    option "--api-base-url",
      default = "https://call-status.herokuapp.com",
      env = "CALL_STATUS_API_BASE_URL"

    run:
      let user = block:
        if opts.user != "":
          opts.user
        else:
          tryReadConfigFile(getEnv "CONFIG_FILEPATH")
            .map(conf => conf.userName)
            .get ""

      if user == "":
        echo "ERROR: User is required, but was not provided"
        echo p.help
        quit 1

      runCheck user, opts.apiBaseUrl, opts.dryRun, opts.force

  run:
    if opts.version:
      echo pkgVersion
    elif opts.revision:
      echo pkgRevision
    elif opts.info:
      echo "version:  ", pkgVersion
      echo "revision: ", pkgRevision
    elif commandLineParams().len == 0:
      echo p.help

p.run()
