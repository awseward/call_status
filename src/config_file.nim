import os

type Filepath* = distinct string

let defaultPath*: Filepath =
  Filepath (os.getConfigDir() / "call_status" / "checker.conf.json")
