let dhall-misc =
        env:DHALL_MISC
      ? https://raw.githubusercontent.com/awseward/dhall-misc/20210618054443/package.dhall
          sha256:8069801dbbfc48b58b11e0a91a84d4a84df61a174d30202be8be68844a904e59

let dhall-utils =
        env:DHALL_UTILS
      ? https://raw.githubusercontent.com/awseward/dhall-utils/20210612223556/package.dhall
          sha256:86e54888676e53ed156742ab15653806ea8d6f39daca47abd395323717c04ec0

in  dhall-misc.{ actions-catalog, job-templates, GHA } ⫽ dhall-utils.{ Plural }
