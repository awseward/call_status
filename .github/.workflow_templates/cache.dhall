let imports = ../imports.dhall

let config = ../config.dhall

let GHA = imports.GHA

let NonEmpty = GHA.NonEmpty

let checkoutDo = imports.actions-catalog.actions/checkout.plainDo

in  GHA.Workflow::( let os =
                          NonEmpty.make
                            GHA.OS.Type
                            GHA.OS.Type.macos-latest
                            [ GHA.OS.Type.ubuntu-latest ]

                    let steps = checkoutDo config.nim.setup.steps

                    in  GHA.mkCacheWorkflowOpts config.defaultBranch os steps
                  )
