let imports = ../imports.dhall

let config = ../config.dhall

let GHA = imports.GHA

let OS = GHA.OS.Type

let checkoutDo = imports.actions-catalog.actions/checkout.plainDo

let opts =
        config._workflows.release
      ⫽ { jobs = toMap
            { release-call_status_checker = GHA.Job::{
              , runs-on = [ OS.macos-latest ]
              , steps =
                  checkoutDo (config.nim.setup.steps # config.homebrew.steps)
              }
            }
        }

in  GHA.Workflow::opts
