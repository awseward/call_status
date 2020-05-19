import os
import db_postgres
import db_sqlite
import typetraits

import ./logs

type Closeable* = concept x
  ## Intended to facilitate generalizing DbConn types from the db_postgres and
  ## db_sqlite stdlib modules without having to duplicate much.
  close x

proc logClose[T: Closeable](cls: T) =
  debug "Closing ", cls.type.name, "..."
  close cls

template use*(getDb, db, actions: untyped): untyped =
  let db: Closeable = getDb()
  try:
    actions
  finally:
    logClose db

runnableExamples:
  import db_sqlite

  proc db_open(): DbConn = open("some.db", "", "", "")

  let res = db_open.use conn:
    conn.getValue sql"SELECT UPPER('foo')"

  doAssert "FOO" == res

# ---

let postgresUrl = getEnv "DATABASE_URL"

proc open_pg*() : db_postgres.DbConn =
  db_postgres.open("", "", "", postgresUrl)

let sqliteFilepath = getEnv "DATABASE_FILEPATH"

proc open_sqlite*(): db_sqlite.DbConn =
  db_sqlite.open(sqliteFilepath, "", "", "")
