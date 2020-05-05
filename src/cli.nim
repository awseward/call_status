import argparse
import json
import httpClient

proc postStatus(apiBaseUrl: string, user: string, isOnCall: bool) =
  let client = newHttpClient()
  client.headers = newHttpHeaders({ "Content-Type": "application/json" })
  let response = client.post(
    apiBaseUrl & "/api/status",
    body = ($ %*{ "user": user, "is_on_call": isOnCall })
  )
  echo response.status
  echo response.body

  discard

let p = newParser("call-status"):
  help("A CLI client for managing call status")

  flag("-n", "--dryrun")

  option("-u", "--user",   choices = @["D", "N"])
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
      postStatus(opts.apiBaseUrl, opts.user, opts.status == "on")

p.run()
