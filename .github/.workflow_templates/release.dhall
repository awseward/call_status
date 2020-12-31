let imports = ../imports.dhall

let action_templates = imports.action_templates

let NimSetup = action_templates.NimSetup

let GHA = action_templates.gha/jobs

let release = action_templates.release

in  { name = "Release"
    , on.push.tags = [ "*" ]
    , jobs = toMap
        { release-call_status_checker =
          { runs-on = [ "macos-latest" ]
          , steps =
              imports.concat
                GHA.Step
                [ NimSetup.mkSteps NimSetup.Opts::{ nimVersion = "1.4.2" }
                , release.mkSteps
                    release.Opts::{
                    , formula-name = "call_status_checker"
                    , homebrew-tap = "awseward/homebrew-tap"
                    }
                ]
          }
        }
    }
