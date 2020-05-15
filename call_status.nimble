# Package

version       = "0.1.0"
author        = "Andrew Seward"
description   = "An app to indicate who's on a call"
license       = "MIT"
srcDir        = "src"
bin           = @["check_zoom", "cli", "web"]


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

task docs, "Generate documentation":
  exec "nimble doc --project src/check_zoom.nim"
  exec "nimble doc --project src/cli.nim"
  # Web currently errors here, will have to figure out why
  # exec "nim doc --project src/web.nim"

task pretty, "Run nimpretty on all .nim files in the repo":
  exec "find . -type f -not -name 'assets_file.nim' -name '*.nim' | xargs -n1 nimpretty --indent:2 --maxLineLen:120"

task watch_web, "Watch for changes and reload web accordingly":
  exec "find . -type f -name '*.nim' -or -name '*.nimf' | entr -r nimble run web"

task watch_zoom, "Simulate a zoom watching daemon (launchd LaunchAgent on MacOS)":
  while true:
    exec "nimble -d:ssl run check_zoom; sleep 10"

