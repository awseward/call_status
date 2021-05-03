let dhall-misc =
      https://raw.githubusercontent.com/awseward/dhall-misc/20210503020859/package.dhall sha256:681dde43b6dff84f5da7be27a1982123b968455e140b5508fc03720435bdb173

in  dhall-misc.{ actions-catalog, job-templates, GHA }
