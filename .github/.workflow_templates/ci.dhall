let imports = ../imports.dhall

let config = ../config.dhall

let GHA = imports.GHA

let OS = GHA.OS.Type

let action_templates = imports.action_templates

let actions = imports.actions-catalog

let checkoutDo = actions.actions/checkout.plainDo

let opts =
        config._workflows.ci
      ⫽ { jobs =
              [ let A = action_templates.nim/Build

                in  A.mkJobEntry
                      A.Opts::{
                      , platforms = [ OS.ubuntu-latest ]
                      , bin = "web"
                      , nimbleFlags = "--define:release --define:useStdLib"
                      , nimSetup = config.nim.setup.opts
                      }
              , let A = action_templates.nim/Build

                in  A.mkJobEntry
                      A.Opts::{
                      , platforms = [ OS.macos-latest ]
                      , bin = "call_status_checker"
                      , nimbleFlags = "--define:release --define:ssl"
                      , nimSetup = config.nim.setup.opts
                      }
              , let A = action_templates.nim/Assets

                in  A.mkJobEntry
                      A.Opts::{
                      , platforms = [ OS.macos-latest ]
                      , nimSetup = config.nim.setup.opts
                      }
              , let A = action_templates.nim/Docs

                in  A.mkJobEntry
                      A.Opts::{
                      , platforms = [ OS.ubuntu-latest ]
                      , nimSetup = config.nim.setup.opts
                      }
              ]
            # toMap
                { check-shell = GHA.Job::{
                  , runs-on = [ OS.ubuntu-latest ]
                  , steps =
                      checkoutDo
                        [ let A = actions.awseward/gh-actions-shell

                          in  A.mkStep A.Common::{=} A.Inputs::{=}
                        ]
                  }
                , check-dhall = GHA.Job::{
                  , runs-on = [ OS.ubuntu-latest ]
                  , steps =
                      checkoutDo
                        [ let A = actions.awseward/gh-actions-dhall

                          in  A.mkStep
                                A.Common::{=}
                                A.Inputs::{
                                , dhallVersion = config.dhall.version
                                }
                        ]
                  }
                }
        }

in  GHA.Workflow::opts
