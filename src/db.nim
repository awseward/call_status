import os
import db_postgres
import db_sqlite
import logging
import typetraits

type Closeable* = concept x
  ## Intended to facilitate generalizing DbConn types from the db_postgres and
  ## db_sqlite stdlib modules without having to duplicate much.
  close x

proc logClose[T:Closeable](cls: T) =
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

proc open_pg*(envVarKey: string = "DATABASE_URL"): db_postgres.DbConn =
  db_postgres.open("", "", "", getEnv(envVarKey))

proc open_sqlite*(envVarKey: string = "DATABASE_FILEPATH"): db_sqlite.DbConn =
  db_sqlite.open(getEnv(envVarKey), "", "", "")
