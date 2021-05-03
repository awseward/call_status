let dhall-misc =
      https://raw.githubusercontent.com/awseward/dhall-misc/20210503010711/package.dhall sha256:1db3dd76260ea735f7b2cbc15c7007fbb3eabf5eb104599e9529b29fdf656bbc

in  dhall-misc.{ actions-catalog, job-templates, GHA }
