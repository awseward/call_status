import argparse
import json
import httpClient

const API_URL_BASE = "https://whos-on-a-call.herokuapp.com"

proc doThething(user: string, isOnCall: bool) =
  let client = newHttpClient()
  client.headers = newHttpHeaders({ "Content-Type": "application/json" })
  let response = client.post(
    API_URL_BASE & "/api/status",
    body = ($ %*{ "user": user, "is_on_call": isOnCall })
  )
  echo response.status

  discard

let p = newParser("call-status-client"):
  help("A CLI client for managing call status")

  flag("-n", "--dryrun")

  option("-u", "--user",   choices = @["D", "N"])
  option("-s", "--status", choices = @["on", "off"])

  run:
    if (opts.user == "" or opts.status == ""):
      echo "ERROR: Both user and status are required.", "\n"
      echo p.help
      quit 1

    if opts.dryrun:
      echo "Would set ", opts.user, "\'s status to ", opts.status, "."
    else:
      doTheThing(opts.user, opts.status == "on")

p.run()
