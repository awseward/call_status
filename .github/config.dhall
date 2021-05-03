let imports = ./imports.dhall

let GHA = imports.GHA

let On = GHA.On

let _config =
      { versions = { dhall = "1.38.1", nim = "1.4.6" }
      , homebrew =
        { formula = "call_status_checker", tap = "awseward/homebrew-tap" }
      }

let _workflows =
      { ci =
        { name = "CI"
        , on =
            On.map
              [ On.pullRequest
                  On.PushPull::{ branches = On.include [ "main", "master" ] }
              ]
        }
      , release =
        { name = "Release"
        , on = On.map [ On.push On.PushPull::{ tags = On.include [ "*" ] } ]
        }
      }

in  { dhall = let version = _config.versions.dhall in { setup = <>, version }
    , nim =
        let version = _config.versions.nim

        in  { setup =
                let Setup = imports.action_templates.nim/Setup

                let opts = Setup.Opts::{ nimVersion = version }

                in  { steps = Setup.mkSteps opts, opts }
            , version
            }
    , homebrew =
        let Release = imports.action_templates.release

        let opts =
              Release.Opts::{
              , formula-name = _config.homebrew.formula
              , homebrew-tap = _config.homebrew.tap
              }

        in  { steps = Release.mkSteps opts, opts }
    , _config
    , _workflows
    }
