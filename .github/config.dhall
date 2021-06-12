let imports = ./imports.dhall

let GHA = imports.GHA

let On = GHA.On

let OS = GHA.OS

let Plural = imports.Plural

let multiOS =
      λ(oses : Plural.Type OS.Type) →
        let nonempty = Plural.toNonEmpty OS.Type oses

        in  GHA.multiOS nonempty.head nonempty.tail

let _config =
      { versions = { dhall = "1.39.0", nim = "1.4.6" }
      , homebrew =
        { formula = "call_status_checker", tap = "awseward/homebrew-tap" }
      }

let defaultBranch = "main"

let _workflows =
      { ci =
        { name = "CI"
        , on =
            On.map
              [ On.pullRequest
                  On.PushPull::{ branches = On.include [ defaultBranch ] }
              ]
        }
      , release =
        { name = "Release"
        , on = On.map [ On.push On.PushPull::{ tags = On.include [ "*" ] } ]
        }
      }

let mkCacheWorkflowOpts -- TODO: Consider upstreaming in some form or another.
                        --
                        -- FIXME:
                        --   I'm not sure if requiring `Plural OS` is what we
                        --   actually want; for now I'm just trying things out.
                        =
      λ(defaultBranch : Text) →
      λ(os : Plural.Type OS.Type) →
      λ(steps : List GHA.Step.Type) →
        { name = "Cache"
        , on =
            On.map
              [ On.push On.PushPull::{ branches = On.include [ defaultBranch ] }
              ]
        , jobs = toMap { update-cache = GHA.Job::(multiOS os ⫽ { steps }) }
        }

in  { defaultBranch
    , dhall.version = _config.versions.dhall
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
    , mkCacheWorkflowOpts
    }
