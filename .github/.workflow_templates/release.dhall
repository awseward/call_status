let imports = ../imports.dhall

let GHA = imports.GHA

let On = GHA.On

let OS = GHA.OS.Type

let actions = imports.actions-catalog

let Checkout = actions.actions/checkout

let nim/Setup = imports.action_templates.nim/Setup

let Release = imports.action_templates.release

in  GHA.Workflow::{
    , name = "Release"
    , on = On.map [ On.push On.PushPull::{ tags = On.include [ "*" ] } ]
    , jobs = toMap
        { release-call_status_checker = GHA.Job::{
          , runs-on = [ OS.macos-latest ]
          , steps =
              Checkout.plainDo
                (   nim/Setup.mkSteps nim/Setup.Opts::{ nimVersion = "1.4.2" }
                  # Release.mkSteps
                      Release.Opts::{
                      , formula-name = "call_status_checker"
                      , homebrew-tap = "awseward/homebrew-tap"
                      }
                )
          }
        }
    }
