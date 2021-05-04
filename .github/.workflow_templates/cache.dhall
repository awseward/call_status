let imports = ../imports.dhall

let config = ../config.dhall

let GHA = imports.GHA

let On = GHA.On

let OS = GHA.OS.Type

let actions = imports.actions-catalog

let checkoutDo = actions.actions/checkout.plainDo

in  GHA.Workflow::{
    , name = "Cache"
    , on =
        On.map
          [ On.push On.PushPull::{ branches = On.include [ "master", "main" ] }
          ]
    , jobs = toMap
        { update-cache = GHA.Job::{
          , strategy = Some GHA.Strategy::{
            , matrix =
                GHA.Strategy.Matrix.mk
                  GHA.Strategy.Matrix.Common::{
                  , os = [ OS.macos-latest, OS.ubuntu-latest ]
                  }
                  GHA.Strategy.Matrix.otherEmpty
            }
          , runs-on = [ OS.other (GHA.subst "matrix.os") ]
          , steps = checkoutDo config.nim.setup.steps
          }
        }
    }
