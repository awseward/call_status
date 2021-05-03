let imports = ../imports.dhall

let config = ../config.dhall

let GHA = imports.GHA

let OS = GHA.OS.Type

let job-templates = imports.job-templates

let actions = imports.actions-catalog

let checkoutDo = actions.actions/checkout.plainDo

let opts =
        config._workflows.ci
      ⫽ { jobs =
              [ let J_ = job-templates.nim/Build

                in  J_.mkJobEntry
                      J_.Opts::{
                      , platforms = [ OS.ubuntu-latest ]
                      , bin = "web"
                      , nimbleFlags = "--define:release --define:useStdLib"
                      , nimSetup = config.nim.setup.opts
                      }
              , let J_ = job-templates.nim/Build

                in  J_.mkJobEntry
                      J_.Opts::{
                      , platforms = [ OS.macos-latest ]
                      , bin = "call_status_checker"
                      , nimbleFlags = "--define:release --define:ssl"
                      , nimSetup = config.nim.setup.opts
                      }
              , let J_ = job-templates.nim/Assets

                in  J_.mkJobEntry
                      J_.Opts::{
                      , platforms = [ OS.macos-latest ]
                      , nimSetup = config.nim.setup.opts
                      }
              , let J_ = job-templates.nim/Docs

                in  J_.mkJobEntry
                      J_.Opts::{
                      , platforms = [ OS.ubuntu-latest ]
                      , nimSetup = config.nim.setup.opts
                      }
              ]
            # toMap
                { check-shell = GHA.Job::{
                  , runs-on = [ OS.ubuntu-latest ]
                  , steps =
                      checkoutDo
                        [ let J_ = actions.awseward/gh-actions-shell

                          in  J_.mkStep J_.Common::{=} J_.Inputs::{=}
                        ]
                  }
                , check-dhall = GHA.Job::{
                  , runs-on = [ OS.ubuntu-latest ]
                  , steps =
                      checkoutDo
                        [ let J_ = actions.awseward/gh-actions-dhall

                          in  J_.mkStep
                                J_.Common::{=}
                                J_.Inputs::{
                                , dhallVersion = config.dhall.version
                                }
                        ]
                  }
                }
        }

in  GHA.Workflow::opts
