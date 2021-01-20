let dhall-misc =
      https://raw.githubusercontent.com/awseward/dhall-misc/20210120084654/package.dhall sha256:dd96ab865c56cf24385331749e25fd1985430ed43f91265e6adc234883b3ffef

in  dhall-misc.{ actions-catalog, action_templates, GHA }
