let imports = ../imports.dhall

let config = ../config.dhall

let GHA = imports.GHA

let actions = imports.actions-catalog

let checkoutDo = actions.actions/checkout.plainDo

let OS = GHA.OS.Type

let multiOS =
      λ(os : List OS) →
        let Strategy = GHA.Strategy

        in  { strategy = Some Strategy::{
              , matrix =
                  Strategy.Matrix.mk
                    Strategy.Matrix.Common::{ os }
                    Strategy.Matrix.otherEmpty
              }
            , runs-on = [ OS.other (GHA.subst "matrix.os") ]
            }

let opts =
        config._workflows.cache
      ⫽ { jobs = toMap
            { update-cache =
                let opts =
                        multiOS [ OS.macos-latest, OS.ubuntu-latest ]
                      ⫽ { steps = checkoutDo config.nim.setup.steps }

                in  GHA.Job::opts
            }
        }

in  GHA.Workflow::opts
