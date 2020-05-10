import argparse
import httpClient
import os
import ./api_client

proc setStatus(apiBaseUrl: string, user: string, isOnCall: bool) =
  let response = api_client.postStatus(apiBaseUrl, user, isOnCall)
  echo response.status
  echo response.body

let p = newParser("call-status"):
  help("A CLI client for managing call status")

  flag("-n", "--dryrun")

  option("-u", "--user",   choices = @["D", "N"], env = "CALL_STATUS_USER")
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

    if opts.dryrun:
      echo "Would set ", opts.user, "\'s status to ", opts.status, "."
    else:
      setStatus(opts.apiBaseUrl, opts.user, opts.status == "on")

p.run()
