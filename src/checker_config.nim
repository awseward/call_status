import json
import logs
import options
import os

import ./config_file

const UserName = "user_name"

proc fromString(str: string): Filepath =
  if str == "":
    config_file.defaultPath
  else:
    Filepath str

# ---

type CheckerConfig* = object
  userName*: string

proc fromJson(jsonStr: string): CheckerConfig =
  let json = parseJson jsonStr
  CheckerConfig(userName: json[UserName].getStr())

proc `%`(config: CheckerConfig): JsonNode =
  %*{
    UserName: %config.user_name
  }

proc tryRead(filepath: Filepath): Option[CheckerConfig] =
  try:
    let fileContents = readFile filepath.string
    some fromJson(fileContents)
  except Exception:
    warn "Handled exception in tryRead: ", getCurrentExceptionMsg()
    none CheckerConfig

proc write(config: CheckerConfig, filepath: Filepath) =
  block:
    let (dir, _, _) = splitFile filepath.string
    createDir dir
  writeFile filepath.string, $ %config

proc tryReadConfigFile*(filepath: string): Option[CheckerConfig] =
  filepath.fromString().tryRead()

proc writeConfigFile*(config: CheckerConfig, filepath: string) =
  config.write fromString(filepath)
