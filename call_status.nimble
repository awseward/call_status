# Package

version       = "0.6.4"
author        = "Andrew Seward"
description   = "An app to indicate who's on a call"
license       = "MIT"
srcDir        = "src"
bin           = @["call_status_checker", "call_status_cli", "web"]

# Dependencies

requires "argparse >= 2.0.0 & <= 2.0.0"
requires "jester >= 0.5.0"
requires "nim >= 1.4.2"
requires "ws >= 0.4.3"

requires "https://github.com/awseward/heroku_database_url_splitter"
requires "https://github.com/awseward/nim-junk-drawer#9ff04c5c70b2fe5d24f951f0ff8f408a108ee059"
requires "https://github.com/awseward/nimassets#0.2.0"

# Tasks

# See: https://web.archive.org/web/20200515050555/https://www.rockyourcode.com/how-to-serve-static-files-with-nim-and-jester-on-heroku/
task assets, "Generate packaged assets":
  exec "script/misc.sh _nimble_assets"

task deps, "Install dependencies":
  exec "script/misc.sh _nimble_deps"

task docs, "Generate documentation":
  exec "script/misc.sh _nimble_docs"

task pretty, "Run nimpretty on all .nim files in the repo":
  exec "script/misc.sh _nimble_pretty"

task watch_web, "Watch for changes and reload web accordingly":
  exec "script/misc.sh _nimble_watch_web"

task watch_zoom, "Simulate a Zoom-watching daemon (launchd LaunchAgent on MacOS)":
  exec "script/misc.sh _nimble_watch_zoom"

task simulate_call_zoom, "Simulate a zoom call":
  exec "script/misc.sh _nimble_simulate_call_zoom"

task heroku_build, "Steps to perform during the heroku build phase":
  exec "script/misc.sh _nimble_heroku_build"
