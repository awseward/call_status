let imports = ./imports.dhall

let GHA = imports.GHA

let On = GHA.On

let _config =
      { versions = { dhall = "1.39.0", nim = "1.4.6" }
      , homebrew =
        { formula = "call_status_checker", tap = "awseward/homebrew-tap" }
      }

let _workflows =
      { cache =
        { name = "Cache"
        , on =
            On.map [ On.push On.PushPull::{ branches = On.include [ "main" ] } ]
        }
      , ci =
        { name = "CI"
        , on =
            On.map
              [ On.pullRequest On.PushPull::{ branches = On.include [ "main" ] }
              ]
        }
      , release =
        { name = "Release"
        , on = On.map [ On.push On.PushPull::{ tags = On.include [ "*" ] } ]
        }
      }

in  { dhall.version = _config.versions.dhall
    , nim =
        let version = _config.versions.nim

        in  { setup =
                let J_ = imports.job-templates.nim/Setup

                let opts = J_.Opts::{ nimVersion = version }

                in  { steps = J_.mkSteps opts, opts }
            , version
            }
    , homebrew =
        let J_ = imports.job-templates.release

        let opts =
              J_.Opts::{
              , formula-name = _config.homebrew.formula
              , homebrew-tap = _config.homebrew.tap
              }

        in  { steps = J_.mkSteps opts, opts }
    , _config
    , _workflows
    }
