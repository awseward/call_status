let imports = ../imports.dhall

let config = ../config.dhall

let GHA = imports.GHA

let checkoutDo = imports.actions-catalog.actions/checkout.plainDo

in  GHA.Workflow::( config.mkCacheWorkflowOpts
                      config.defaultBranch
                      GHA.OS.Type.macos-latest
                      [ GHA.OS.Type.ubuntu-latest ]
                      (checkoutDo config.nim.setup.steps)
                  )
