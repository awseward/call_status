import logging
import os
import strutils

template flush(actions: untyped): untyped =
  actions
  flushFile stdout

type Args = varargs[string, `$`]
template debug*(args: Args)  = flush: debug  args
template info*(args: Args)   = flush: info   args
template notice*(args: Args) = flush: notice args
template warn*(args: Args)   = flush: warn   args
template error*(args: Args)  = flush: error  args
template fatal*(args: Args)  = flush: fatal  args

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
