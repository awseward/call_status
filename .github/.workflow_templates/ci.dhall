let imports = ../imports.dhall

let GHA = imports.GHA

let On = GHA.On

let OS = GHA.OS.Type

let action_templates = imports.action_templates

let Checkout = action_templates.actions/Checkout

let nim/Assets = action_templates.nim/Assets

let nim/Build = action_templates.nim/Build

let nim/Docs = action_templates.nim/Docs

in  GHA.Workflow::{
    , name = "CI"
    , on =
        On.map
          [ On.pullRequest
              On.PushPull::{ branches = On.include [ "main", "master" ] }
          ]
    , jobs =
          [ nim/Assets.mkJobEntry
              nim/Assets.Opts::{ platforms = [ OS.macos-latest ] }
          , nim/Build.mkJobEntry
              nim/Build.Opts::{
              , platforms = [ OS.ubuntu-latest ]
              , bin = "web"
              , nimbleFlags = "--define:release --define:useStdLib"
              }
          , nim/Build.mkJobEntry
              nim/Build.Opts::{
              , platforms = [ OS.macos-latest ]
              , bin = "call_status_checker"
              , nimbleFlags = "--define:release --define:ssl"
              }
          , nim/Docs.mkJobEntry
              nim/Docs.Opts::{ platforms = [ OS.ubuntu-latest ] }
          ]
        # toMap
            { check-shell = GHA.Job::{
              , runs-on = [ OS.ubuntu-latest ]
              , steps =
                  Checkout.plainDo
                    [ let action = imports.gh-actions-shell

                      in  action.mkStep action.Common::{=} action.Inputs::{=}
                    ]
              }
            , check-dhall = GHA.Job::{
              , runs-on = [ OS.ubuntu-latest ]
              , steps =
                  Checkout.plainDo
                    [ let action = imports.gh-actions-dhall

                      in  action.mkStep
                            action.Common::{=}
                            action.Inputs::{ dhallVersion = "1.37.1" }
                    ]
              }
            }
    }
