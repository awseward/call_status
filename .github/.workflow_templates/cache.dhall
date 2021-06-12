let imports = ../imports.dhall

let config = ../config.dhall

let GHA = imports.GHA

let actions = imports.actions-catalog

let checkoutDo = actions.actions/checkout.plainDo

let OS = GHA.OS

let opts =
        config._workflows.cache
      ⫽ { jobs = toMap
            { update-cache =
                let opts =
                        GHA.multiOS
                          OS.Type.macos-latest
                          [ OS.Type.ubuntu-latest ]
                      ⫽ { steps = checkoutDo config.nim.setup.steps }

                in  GHA.Job::opts
            }
        }

in  GHA.Workflow::opts
