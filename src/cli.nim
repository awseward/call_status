import argparse
import httpClient
import logging
import os
import ./api_client

block logging:
  addHandler newConsoleLogger(fmtStr = "[$levelname] ")
  setLogFilter when defined(release): lvlInfo else: lvlDebug

proc setStatus(apiBaseUrl: string, user: string, isOnCall: bool) =
  discard api_client.postStatus(apiBaseUrl, user, isOnCall)

let p = newParser("call-status"):
  help("Manage call status via the CLI")

  flag("-n", "--dry-run")

  option("-u", "--user", choices = @["D", "N"], env = "CALL_STATUS_USER")
  option("-s", "--status", choices = @["on", "off"])

  option("--api-base-url",
    default = "https://call-status.herokuapp.com",
    env = "CALL_STATUS_API_BASE_URL"
  )

  run:
    if (opts.user == "" or opts.status == ""):
      echo "ERROR: Both user and status are required.", "\n"
      echo p.help
      quit 1

    if opts.dryRun:
      echo "Would set ", opts.user, "\'s status to ", opts.status, "."
    else:
      discard postStatus(opts.apiBaseUrl, opts.user, parseBool opts.status)

p.run()
