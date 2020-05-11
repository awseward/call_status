import os
import db_postgres
import db_sqlite

type Closeable = concept x
  close x

proc use*[TDb: Closeable](conn: TDb, fn: proc (conn: TDb)) =
  try:
    fn conn
  finally:
    close conn

proc use*[TDb: Closeable, TResult](conn: TDb, fn: proc(conn: TDb): TResult): TResult =
  try:
    return fn conn
  finally:
    close conn

# ---

proc open_pg*(): db_postgres.DbConn =
  db_postgres.open("", "", "", getEnv("DATABASE_URL"))

proc open_sqlite*(): db_sqlite.DbConn =
  db_sqlite.open(getEnv("DB_FILEPATH"), "", "", "")
