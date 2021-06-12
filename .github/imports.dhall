let dhall-misc =
      https://raw.githubusercontent.com/awseward/dhall-misc/nonempty/runs-on/package.dhall
        sha256:d6326ac83c4c31d5b04769b148374950f6814864450d1bc3f56bee21b43eb969

in  dhall-misc.{ actions-catalog, job-templates, GHA }
