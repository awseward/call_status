let dhall-misc =
      https://raw.githubusercontent.com/awseward/dhall-misc/20210615160625/package.dhall
        sha256:f2f63279600b19f733c04683286b9a955886d64b89589aee251bfb3643d18218

let dhall-utils =
      https://raw.githubusercontent.com/awseward/dhall-utils/20210612223556/package.dhall
        sha256:86e54888676e53ed156742ab15653806ea8d6f39daca47abd395323717c04ec0

in  dhall-misc.{ actions-catalog, job-templates, GHA } ⫽ dhall-utils.{ Plural }
