import argparse
import httpClient
import os

import ./api_client
import ./logs
from ./misc import pkgVersion, pkgRevision
import ./models/person
import ./models/status

logs.setupCli()

let p = newParser("call-status"):
  help("Manage call status via the CLI")

  flag("-n", "--dry-run")
  flag "-f", "--force"

  flag("--version")
  flag("--revision")

  option("-u", "--user", choices = @["D", "N"], env = "CALL_STATUS_USER")
  option("-s", "--status", choices = @["on", "off"])

  option("--api-base-url",
    default = "https://call-status.herokuapp.com",
    env = "CALL_STATUS_API_BASE_URL"
  )

  run:
    if (opts.version):
      echo pkgVersion
      quit 0

    if (opts.revision):
      echo pkgRevision
      quit 0

    if (opts.user == "" or opts.status == ""):
      echo "ERROR: Both user and status are required.", "\n"
      echo p.help
      quit 1

    if opts.dryRun:
      echo "Would set ", opts.user, "\'s status to ", opts.status, "."
    else:
      let person = Person(
        name: opts.user,
        status: status.fromIsOnCall parseBool(opts.status)
      )
      newApiClient(opts.apiBaseUrl).updatePerson person

p.run()
