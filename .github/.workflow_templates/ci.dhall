let imports = ../imports.dhall

let GHA = imports.GHA

let On = GHA.On

let action_templates = imports.action_templates

let Checkout = action_templates.actions/Checkout

let nim/Assets = action_templates.nim/Assets

let nim/Build = action_templates.nim/Build

let nim/Docs = action_templates.nim/Docs

let checkShell =
      GHA.Job::{
      , runs-on = [ "ubuntu-latest" ]
      , steps =
          Checkout.plainDo
            [ [ GHA.Step.mkUses
                  GHA.Step.Common::{=}
                  GHA.Step.Uses::{ uses = "awseward/gh-actions-shell@0.1.2" }
              ]
            ]
      }

let collectJobs = imports.concat { mapKey : Text, mapValue : GHA.Job.Type }

in  GHA.Workflow::{
    , name = "CI"
    , on =
        On.map
          [ On.pullRequest
              On.PushPull::{ branches = On.include [ "main", "master" ] }
          ]
    , jobs =
        collectJobs
          [ [ nim/Assets.mkJobEntry
                nim/Assets.Opts::{ platforms = [ "macos-latest" ] }
            , nim/Build.mkJobEntry
                nim/Build.Opts::{
                , platforms = [ "ubuntu-latest" ]
                , bin = "web"
                , nimbleFlags = "--define:release --define:useStdLib"
                }
            , nim/Build.mkJobEntry
                nim/Build.Opts::{
                , platforms = [ "macos-latest" ]
                , bin = "call_status_checker"
                , nimbleFlags = "--define:release --define:ssl"
                }
            , nim/Docs.mkJobEntry
                nim/Docs.Opts::{ platforms = [ "ubuntu-latest" ] }
            ]
          , toMap
              { check-shell = checkShell
              , check-dhall = GHA.Job::{
                , runs-on = [ "ubuntu-latest" ]
                , steps =
                    Checkout.plainDo
                      [ [ let action = imports.gh-actions-dhall

                          in  action.mkStep
                                action.Common::{=}
                                action.Inputs::{ dhallVersion = "1.37.1" }
                        ]
                      ]
                }
              }
          ]
    }
