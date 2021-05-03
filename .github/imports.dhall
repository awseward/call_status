let dhall-misc =
      https://raw.githubusercontent.com/awseward/dhall-misc/20210503023841/package.dhall sha256:23e9e1548ffd14b83ca9e437928356ceb49ec584687f6ec495a73d9cc8afb73c

in  dhall-misc.{ actions-catalog, job-templates, GHA }
