let dhall-misc =
      https://raw.githubusercontent.com/awseward/dhall-misc/20210504051557/package.dhall sha256:4ad8a9503b9d1e7bc050851473d9a49c50100067222335e3db970ed947e0dbff

in  dhall-misc.{ actions-catalog, job-templates, GHA }
