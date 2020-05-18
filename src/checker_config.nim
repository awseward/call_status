import json
import options
import logs

const UserName = "user_name"

type ConfigFilepath = distinct string

const DefaultConfigFilepath =
  when hostOS == "macosx":
    # Basis of this filepath is homebrew installation directory choices.
    #
    # See:
    # https://github.com/awseward/homebrew-tap/Formula/call_status_checker.rb
    #
    ConfigFilepath "/usr/local/etc/call_status_checker/config.json"
  elif hostOS == "linux":
    # This application doesn't actually target linux currently, but am just
    # doing this so that CI can pass since this is evaluated at compile time.
    #
    # Maybe a better thing would be to just change the CI to run on a macosx
    # container, but this is simpler and the alternative can always be
    # revisited.
    #
    # For why this differs from the macosx path, see:
    # https://www.tldp.org/HOWTO/HighQuality-Apps-HOWTO/fhs.html
    #
    ConfigFilepath "/etc/call_status_checker/config.json"
  else:
    raise Exception.newException "Unsupported host OS: " & hostOS

proc fromString(str: string): ConfigFilepath =
  if str == "":
    DefaultConfigFilepath
  else:
    ConfigFilepath str

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
