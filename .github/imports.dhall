let dhall-misc =
        env:DHALL_MISC
      ? https://raw.githubusercontent.com/awseward/dhall-misc/20210618085503/package.dhall
          sha256:62a426f128fc05bbed2184e5c91f9eb1848fbc064006835eed8dabcd02470ccc

let dhall-utils =
        env:DHALL_UTILS
      ? https://raw.githubusercontent.com/awseward/dhall-utils/20210612223556/package.dhall
          sha256:86e54888676e53ed156742ab15653806ea8d6f39daca47abd395323717c04ec0

in  dhall-misc.{ actions-catalog, job-templates, GHA } ⫽ dhall-utils.{ Plural }
