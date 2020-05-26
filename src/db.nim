import junk_drawer/db
import os
import db_postgres
import db_sqlite
import typetraits

import ./logs

export db

let postgresUrl = getEnv "DATABASE_URL"

proc open_pg*(): db_postgres.DbConn =
  db_postgres.open("", "", "", postgresUrl)

let sqliteFilepath = getEnv "DATABASE_FILEPATH"

proc open_sqlite*(): db_sqlite.DbConn =
  db_sqlite.open(sqliteFilepath, "", "", "")
