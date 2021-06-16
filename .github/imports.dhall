let dhall-misc =
      https://raw.githubusercontent.com/awseward/dhall-misc/20210616052737/package.dhall
        sha256:8e1fe66925df2a92a25774e809da7dda1ce6775058db22a21f79fab2f12bbaed

let dhall-utils =
      https://raw.githubusercontent.com/awseward/dhall-utils/20210612223556/package.dhall
        sha256:86e54888676e53ed156742ab15653806ea8d6f39daca47abd395323717c04ec0

in  dhall-misc.{ actions-catalog, job-templates, GHA } ⫽ dhall-utils.{ Plural }
