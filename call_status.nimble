# Package

version       = "0.3.4"
author        = "Andrew Seward"
description   = "An app to indicate who's on a call"
license       = "MIT"
srcDir        = "src"
bin           = @["call_status_checker", "call_status_cli", "web"]


# Dependencies

requires "jester >= 0.4.3"
requires "nim >= 1.2.0"
requires "argparse >= 0.10.1"
requires "nimassets >= 0.1.0"
requires "ws >= 0.4.0"

# Tasks

# See: https://web.archive.org/web/20200515050555/https://www.rockyourcode.com/how-to-serve-static-files-with-nim-and-jester-on-heroku/
task assets, "Generate packaged assets":
  exec "echo src/views/assets_file.nim | xargs -t -I{} nimassets --dir=public --output={}"

task db_setup, "Set up the DB":
  exec "./misc/db_setup.sh"

task docs, "Generate documentation":
  exec "nimble doc --project src/call_status_checker.nim"
  exec "nimble doc --project src/call_status_cli.nim"
  # Web currently errors here, will have to figure out why
  # exec "nim doc --project src/web.nim"

task pretty, "Run nimpretty on all .nim files in the repo":
  exec "find . -type f -not -name 'assets_file.nim' -name '*.nim' | xargs -n1 nimpretty --indent:2 --maxLineLen:120"

task watch_web, "Watch for changes and reload web accordingly":
  exec "find . -type f -name '*.nim' -or -name '*.nimf' | entr -r nimble run web"

task watch_zoom, "Simulate a zoom watching daemon (launchd LaunchAgent on MacOS)":
  while true:
    exec "nimble -d:ssl run call_status_checker; sleep 10"

