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
  exec "type nimassets || nimble deps"
  exec "nimassets --help && echo src/views/assets_file.nim | xargs -t -I{} nimassets --dir=public --output={}"

task db_setup, "Set up the DB":
  exec "./misc/db_setup.sh"

task deps, "Install dependencies":
  exec "echo '--depsOnly' | xargs -t nimble install --accept"

task docs, "Generate documentation":
  exec "nimble doc --project src/call_status_checker.nim"
  exec "nimble doc --project src/call_status_cli.nim"
  # Web currently errors here, will have to figure out why
  # exec "nim doc --project src/web.nim"

task pretty, "Run nimpretty on all .nim files in the repo":
  exec "type nimpretty"
  exec "find . -type f -not -name 'assets_file.nim' -name '*.nim' | xargs -t nimpretty --indent:2 --maxLineLen:120"

task watch_web, "Watch for changes and reload web accordingly":
  exec "find . -type f -name '*.nim' -or -name '*.nimf' | entr -r nimble -d:useStdLib run web"

task watch_zoom, "Simulate a zoom watching daemon (launchd LaunchAgent on MacOS)":
  while true:
    exec "nimble -d:ssl run call_status_checker check; sleep 10"

task heroku_build, "Steps to perform during the heroku build phase":
  exec "echo '--version' | xargs -t nim"
  exec "echo '--version' | xargs -t nimble"
  exec "nimble deps"
  exec "nimble assets"
  exec "make heroku-local-bins"
