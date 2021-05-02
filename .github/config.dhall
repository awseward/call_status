let imports = ./imports.dhall

let versions = ./versions.dhall

in  { dhall = let version = versions.dhall in { setup = <>, version }
    , nim =
        let version = versions.nim

        in  { setup =
                let Setup = imports.action_templates.nim/Setup

                let opts = Setup.Opts::{ nimVersion = versions.nim }

                in  { steps = Setup.mkSteps opts, opts }
            , version
            }
    , _release =
        let Release = imports.action_templates.release

        in  { homebrew =
                let opts =
                      Release.Opts::{
                      , formula-name = "call_status_checker"
                      , homebrew-tap = "awseward/homebrew-tap"
                      }

                in  { steps = Release.mkSteps opts, opts }
            }
    }
