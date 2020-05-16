import json
import options
import logs

const USER_NAME = "user_name"

type CheckerConfig* = object
  userName*: string

proc fromJson(jsonStr: string): CheckerConfig =
  let json = parseJson jsonStr
  CheckerConfig(userName: json[USER_NAME].getStr())

proc `%`(config: CheckerConfig): JsonNode =
  %*{
    USER_NAME: %config.user_name
  }

proc tryReadConfigFile*(filePath: string): Option[CheckerConfig] =
  try:
    let fileContents = readFile filepath
    some fromJson(fileContents)
  except Exception:
    warn "Handled exception in tryReadConfig: ", getCurrentExceptionMsg()
    none CheckerConfig

proc writeConfigFile*(config: CheckerConfig, filePath: string) =
  writeFile filePath, $ %config
