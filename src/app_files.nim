import os
import ./xdg_dirs

type Filepath* = distinct string

let configPath*: Filepath =
  Filepath (ConfigHome / "call_status" / "checker.conf.json")

let databasePath*: Filepath =
  if existsEnv "DATABASE_FILEPATH":
    Filepath getEnv("DATABASE_FILEPATH")
  else:
    Filepath (DataHome / "call_status" / "checker.db")
