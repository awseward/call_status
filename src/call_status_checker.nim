import argparse
import options
import os
import strutils
import sugar

import ./api_client
import ./checker_config
import ./db_call_status_checker
import ./detect_zoom
import ./logs
import ./models/person
import ./models/status
import ./statics

logs.setupChecker()

block tempBackwardsCompat:
  # Would like to use DATABASE_FILEPATH, but will have to migrate existing
  # installs to be safe. In the meantime, this should do it.
  if not(existsEnv "DATABASE_FILEPATH") and existsEnv "DB_FILEPATH":
    putEnv("DATABASE_FILEPATH", getEnv("DB_FILEPATH"))

type Username* = distinct string

type Change = enum
  unchanged,
  changed,
  unknown

proc determineChange[T](previous: Option[T], current: T): Change =
  if not previous.isSome:
    unknown
  elif previous.get() == current:
    unchanged
  else:
    changed

type Override = enum
  none,
  dryRun,
  force

proc determineOverride(dryRun: bool, force: bool): Override =
  if dryRun:
    Override.dryRun
  elif force:
    Override.force
  else:
    none

proc getPreviousStatus(name: string): Option[Status] =
  name.getLastKnownIsOnCall().map fromIsOnCall

proc getCurrentStatus(): Status =
  fromIsOnCall isZoomCallActive()

proc runCheck(name: Username, apiBaseUrl: string, override: Override) =
  dbSetup()
  let previous = getPreviousStatus name.string
  let current = getCurrentStatus()

  case determineChange(previous, current):
    of changed, unknown:
      if override == Override.dryRun:
        info "Status changed; would update status, but not doing so (dry run)."
        return
      else:
        info "Status changed; updating."
    of unchanged:
      case override:
        of Override.dryRun:
          info "Status unchanged; would do nothing."
          return
        of Override.force:
          info "Status unchanged, but update forced; updating."
        else:
          info "Status unchanged; doing nothing."
          return

  let person = Person(
    name: name.string,
    status: current
  )
  newApiClient(apiBaseUrl).updatePerson person
  updatePerson person


proc runConfig(name: Username) =
  CheckerConfig(userName: name.string).writeConfigFile getEnv("CONFIG_FILEPATH")

const AppName = "call_status_checker"

let p = newParser(AppName):
  help "Check call status and update Call Status API accordingly"

  flag("--version", help = "Print the version of " & AppName)
  flag("--revision", help = "Print the Git SHA of " & AppName)
  flag("--info", help = "Print version and revision")

  command "config":
    option "-u", "--user", required = true, choices = @["D", "N"], env = "CALL_STATUS_USER"
    run:
      if isEmptyOrWhitespace opts.user:
        echo "ERROR: User is required, but no valid value was provided"
        quit 1

      runConfig Username(opts.user)

  command "check":
    option "-u", "--user", choices = @["D", "N"], env = "CALL_STATUS_USER"

    flag "-n", "--dry-run"
    flag "-f", "--force"

    option "--api-base-url",
      default = some "https://call-status.herokuapp.com",
      env = "CALL_STATUS_API_BASE_URL"

    run:
      let user = block:
        if isEmptyOrWhitespace opts.user:
          tryReadConfigFile(getEnv "CONFIG_FILEPATH")
            .map(conf => conf.userName)
            .get ""
        else:
          opts.user

      if isEmptyOrWhitespace user:
        echo "ERROR: User is required, but no valid value was provided"
        quit 1

      runCheck Username(user), opts.apiBaseUrl, determineOverride(opts.dryRun, opts.force)

  run:
    if opts.version:
      echo pkgVersion
    elif opts.revision:
      echo pkgRevision
    elif opts.info:
      echo "version:  ", pkgVersion
      echo "revision: ", pkgRevision
    # TODO: Evaluate whether this is still necessary
    # elif commandLineParams().len == 0:
    #   # Used to print help here

p.run()
