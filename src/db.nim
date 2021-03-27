import junk_drawer/db
import os
import db_postgres
import db_sqlite

import ./app_files
import ./logs

export db

let postgresUrl = getEnv "DATABASE_URL"

proc open_pg*(): db_postgres.DbConn =
  db_postgres.open("", "", "", postgresUrl)

let sqliteFilepath = app_files.databasePath.string

proc open_sqlite*(): db_sqlite.DbConn =
  createDir parentDir(sqliteFilepath)
  debug "opening: " & sqliteFilepath
  db_sqlite.open(sqliteFilepath, "", "", "")
