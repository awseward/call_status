let imports = ../imports.dhall

let Assets = imports.action_templates.NimAssets

let Build = imports.action_templates.NimBuild

let Docs = imports.action_templates.NimDocs

let check-dhall = imports.gh-actions-dhall

let check-shell = imports.gh-actions-shell

let checkedOut = imports.checkedOut

in  { name = "CI"
    , on.pull_request.branches = [ "main", "master" ]
    , jobs =
        imports.collectJobs
          [ [ Assets.mkJob Assets.Opts::{ platforms = [ "macos-latest" ] }
            , Build.mkJob
                Build.Opts::{
                , platforms = [ "ubuntu-latest" ]
                , bin = "web"
                , nimbleFlags = "--define:release --define:useStdLib"
                }
            , Build.mkJob
                Build.Opts::{
                , platforms = [ "macos-latest" ]
                , bin = "call_status_checker"
                , nimbleFlags = "--define:release --define:ssl"
                }
            , Docs.mkJob Docs.Opts::{ platforms = [ "ubuntu-latest" ] }
            ]
          , toMap
              { check-shell =
                { runs-on = [ "ubuntu-latest" ]
                , steps =
                    checkedOut [ check-shell.mkJob check-shell.Inputs::{=} ]
                }
              , check-dhall =
                { runs-on = [ "ubuntu-latest" ]
                , steps =
                    checkedOut
                      [ check-dhall.mkJob
                          check-dhall.Inputs::{ dhallVersion = "1.37.1" }
                      ]
                }
              }
          ]
    }
