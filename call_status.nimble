# Package

version       = "0.1.0"
author        = "Andrew Seward"
description   = "An app to indicate who's on a call"
license       = "MIT"
srcDir        = "src"
bin           = @["backend", "check_zoom", "cli"]


# Dependencies

requires "jester >= 0.4.3"
requires "nim >= 1.2.0"
requires "argparse >= 0.10.1"
requires "nimassets >= 0.1.0"

# Tasks

task assets, "Generate packaged assets":
  exec "nimassets --dir=public --output=src/views/assets_file.nim"

task db_setup, "Set up the DB":
  exec "./misc/db_setup.sh"

task watch_zoom, "Simulate a zoom watching daemon (launchd LaunchAgent on MacOS)":
  while true:
    exec "nimble -d:ssl run check_zoom; sleep 10"
