let dhall-misc =
      https://raw.githubusercontent.com/awseward/dhall-misc/20210430055601/package.dhall sha256:00e9178803575c12ede13d88ac3b30793758e24b4530e7cf076c397b1bc3d4e5

in  dhall-misc.{ actions-catalog, action_templates, GHA }
