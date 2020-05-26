import junk_drawer/flogging
import logging
import os
import strutils

export flogging

proc chooseLevel(): Level =
  result = parseEnum[Level](
    "lvl" & getEnv("LOG_LEVEL", default = ""),
    default = when defined(release): lvlInfo else: lvlDebug
  )

proc setupWeb*() =
  addHandler newConsoleLogger(fmtStr = "[$levelname] ")
  setLogFilter chooseLevel()

proc setupCli*() =
  addHandler newConsoleLogger(fmtStr = "[$levelname] ")
  setLogFilter chooseLevel()

proc setupChecker*() =
  addHandler newConsoleLogger(fmtStr = "[$datetime][$levelname] ")
  setLogFilter chooseLevel()
