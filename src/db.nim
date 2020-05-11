import os
import db_postgres as pg
import db_sqlite as sqlite

type Db = pg.DbConn | sqlite.DbConn

proc use*[TDb: Db](conn: TDb, fn: proc (conn: TDb)) =
  try:
    fn conn
  finally:
    close conn

proc use*[TDb: Db, TResult](conn: TDb, fn: proc(conn: TDb): TResult): TResult =
  try:
    return fn(conn)
  finally:
    close conn

# ---

proc open_pg*(): pg.DbConn =
  pg.open("", "", "", getEnv("DATABASE_URL"))

proc open_sqlite*(): sqlite.DbConn =
  sqlite.open(getEnv("DB_FILEPATH"), "", "", "")
