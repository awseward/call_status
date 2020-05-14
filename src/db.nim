import os
import db_postgres
import db_sqlite

type Closeable* = concept x
  ## Intended to facilitate generalizing DbConn types from the db_postgres and
  ## db_sqlite stdlib modules without having to duplicate much.
  close x

proc use*[TDb: Closeable](conn: TDb, fn: proc (conn: TDb)) =
  ## Executes `fn` and closes `conn` for you.
  try: fn conn finally: close conn

proc use*[TDb: Closeable, TResult](conn: TDb, fn: proc(conn: TDb): TResult): TResult =
  ## Executes `fn` and closes `conn` for you, returning whatever the result of
  ## `fn` was.
  try: fn conn finally: close conn

runnableExamples:
  import db_sqlite

  proc db_open(): DbConn = open("some.db", "", "", "")

  let foo = db_open().use proc (conn: DbConn): string =
    conn.getValue sql"SELECT 'foo';"

  doAssert foo == "foo"

# ---

proc open_pg*(): db_postgres.DbConn =
  db_postgres.open("", "", "", getEnv("DATABASE_URL"))

proc open_sqlite*(): db_sqlite.DbConn =
  db_sqlite.open(getEnv("DB_FILEPATH"), "", "", "")
