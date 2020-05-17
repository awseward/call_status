import json
import options
import logs

const USER_NAME = "user_name"

type ConfigFilepath = distinct string

const DEFAULT_CONFIG_FILEPATH =
  when hostOS == "macosx":
    ConfigFilepath "/usr/local/etc/call_status_checker/config.json"
  else:
    raise Exception.newException "Unsupported host OS: " & hostOS

proc fromString(str: string): ConfigFilepath =
  if str == "":
    DEFAULT_CONFIG_FILEPATH
  else:
    ConfigFilepath str

# ---

type CheckerConfig* = object
  userName*: string

proc fromJson(jsonStr: string): CheckerConfig =
  let json = parseJson jsonStr
  CheckerConfig(userName: json[USER_NAME].getStr())

proc `%`(config: CheckerConfig): JsonNode =
  %*{
    USER_NAME: %config.user_name
  }

proc tryRead(filepath: ConfigFilepath): Option[CheckerConfig] =
  try:
    let fileContents = readFile filepath.string
    some fromJson(fileContents)
  except Exception:
    warn "Handled exception in tryRead: ", getCurrentExceptionMsg()
    none CheckerConfig

proc write(config: CheckerConfig, filepath: ConfigFilepath) =
  writeFile filepath.string, $ %config

proc tryReadConfigFile*(filepath: string): Option[CheckerConfig] =
  filepath.fromString().tryRead()

proc writeConfigFile*(config: CheckerConfig, filepath: string) =
  config.write fromString(filepath)
