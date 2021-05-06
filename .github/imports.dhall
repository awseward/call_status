let dhall-misc =
      https://raw.githubusercontent.com/awseward/dhall-misc/20210506061514/package.dhall sha256:dd1079dc6f05a252b91f211e19a712595b6f42047961f863eb68dc7bb26a7d6e

in  dhall-misc.{ actions-catalog, job-templates, GHA }
