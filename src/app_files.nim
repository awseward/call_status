import os

type Filepath* = distinct string

let xdgCacheHome  = os.getEnv("XDG_CACHE_HOME", default = os.expandTilde "~/.cache/")
let xdgConfigHome = os.getConfigDir()
let xdgDataHome   = os.getEnv("XDG_DATA_HOME",  default = os.expandTilde "~/.local/share")

let configPath*: Filepath =
  Filepath (xdgConfigHome / "call_status" / "checker.conf.json")

let databasePath*: Filepath =
  if existsEnv "DATABASE_FILEPATH":
    Filepath getEnv("DATABASE_FILEPATH")
  else:
    Filepath (xdgDataHome / "call_status" / "checker.db")
