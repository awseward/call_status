let dhall-misc =
      https://raw.githubusercontent.com/awseward/dhall-misc/20210120085637/package.dhall sha256:b32145fee2ff889e178d8000c117702c6ebdf1ab66a712ff1e3a3719f83eb85f

in  dhall-misc.{ actions-catalog, action_templates, GHA }
