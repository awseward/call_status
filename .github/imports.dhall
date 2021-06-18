let dhall-misc =
        env:DHALL_MISC
      ? https://raw.githubusercontent.com/awseward/dhall-misc/20210618052055/package.dhall
          sha256:2921598959cef2b15ca06bfe7b1955203c7a4aa7b141a719f7fcea8efebc1933

let dhall-utils =
        env:DHALL_UTILS
      ? https://raw.githubusercontent.com/awseward/dhall-utils/20210612223556/package.dhall
          sha256:86e54888676e53ed156742ab15653806ea8d6f39daca47abd395323717c04ec0

in  dhall-misc.{ actions-catalog, job-templates, GHA } ⫽ dhall-utils.{ Plural }
