let imports = ../imports.dhall

let GHA = imports.GHA

let On = GHA.On

let OS = GHA.OS.Type

let actions = imports.actions-catalog

let Checkout = actions.actions/checkout

let nim/Assets = imports.action_templates.nim/Assets

let nim/Build = imports.action_templates.nim/Build

let nim/Docs = imports.action_templates.nim/Docs

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
                    [ let A = actions.awseward/gh-actions-shell

                      in  A.mkStep A.Common::{=} A.Inputs::{=}
                    ]
              }
            , check-dhall = GHA.Job::{
              , runs-on = [ OS.ubuntu-latest ]
              , steps =
                  Checkout.plainDo
                    [ let A = actions.awseward/gh-actions-dhall

                      in  A.mkStep
                            A.Common::{=}
                            A.Inputs::{ dhallVersion = "1.37.1" }
                    ]
              }
            }
    }
