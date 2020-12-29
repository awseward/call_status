import db_sqlite
import options
import strutils

import ./db
import ./logs
import ./misc
import ./models/person

let db_open = open_sqlite

proc dbSetup*() =
  let query = sql misc.dedent """
    CREATE TABLE IF NOT EXISTS people (
      name         TEXT UNIQUE NOT NULL,
      is_on_call   BOOLEAN NOT NULL,
      last_checked DATETIME NOT NULL
    )"""
  debug query.string
  db_open.use conn: conn.exec query

proc updatePerson*(person: Person) =
  let query = sql misc.dedent """
    INSERT INTO people (name, is_on_call, last_checked) VALUES
      (?, ?, current_timestamp)
      ON CONFLICT(name) DO UPDATE SET
        is_on_call = ?,
        last_checked = current_timestamp"""
  debug query.string
  let isOnCall = person.isOnCall()
  db_open.use conn: conn.exec query, person.name, isOnCall, isOnCall

proc getLastKnownIsOnCall*(name: string): Option[bool] =
  let query = sql misc.dedent """
    SELECT is_on_call
    FROM people
    WHERE name = ?"""
  debug query.string
  let value = db_open.use conn: conn.getValue(query, name)
  if value == "":
    none bool
  else:
    try: some parseBool(value) except ValueError: none bool
