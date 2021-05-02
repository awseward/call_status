let imports = ../imports.dhall

let config = ../config.dhall

let GHA = imports.GHA

let On = GHA.On

let OS = GHA.OS.Type

let actions = imports.actions-catalog

let Checkout = actions.actions/checkout

in  GHA.Workflow::{
    , name = "Release"
    , on = On.map [ On.push On.PushPull::{ tags = On.include [ "*" ] } ]
    , jobs = toMap
        { release-call_status_checker = GHA.Job::{
          , runs-on = [ OS.macos-latest ]
          , steps =
              Checkout.plainDo
                (config.nim.setup.steps # config._release.homebrew.steps)
          }
        }
    }
