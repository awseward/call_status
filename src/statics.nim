import parsecfg
import streams
import strutils
import os

proc getPkgVersion(): string {.compileTime.} =
  const filepath = staticExec("ls ../*.nimble").splitLines()[0]
  var stream: StringStream
  try:
    stream = newStringStream slurp(filePath)
    let cfg = loadConfig stream
    cfg.getSectionValue("", "version")
  finally:
    close stream

proc getPkgRevision(): string {.compileTime.} =
  let fromEnv = getEnv "SOURCE_VERSION"
  if fromEnv != "": fromEnv
  else:
    staticExec "git rev-parse HEAD"

const pkgVersion* = getPkgVersion()

const pkgRevision* = getPkgRevision()
