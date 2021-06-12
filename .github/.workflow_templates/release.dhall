let imports = ../imports.dhall

let config = ../config.dhall

let GHA = imports.GHA

let NonEmpty =
    -- TODO: Should consider eventually pulling this from Prelude instead
      GHA.NonEmpty

let OS = GHA.OS.Type

let checkoutDo = imports.actions-catalog.actions/checkout.plainDo

let opts =
        config._workflows.release
      ⫽ { jobs = toMap
            { release-call_status_checker = GHA.Job::{
              , runs-on = NonEmpty.singleton OS OS.macos-latest
              , steps =
                  checkoutDo (config.nim.setup.steps # config.homebrew.steps)
              }
            }
        }

in  GHA.Workflow::opts
