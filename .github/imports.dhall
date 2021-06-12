let dhall-misc =
      https://raw.githubusercontent.com/awseward/dhall-misc/20210612224343/package.dhall
        sha256:3b00491aee91e23d6df498ec32e285a8075d9d46f74b69deb33fb3b1ad13be03

let dhall-utils =
      https://raw.githubusercontent.com/awseward/dhall-utils/20210612223556/package.dhall
        sha256:86e54888676e53ed156742ab15653806ea8d6f39daca47abd395323717c04ec0

in  dhall-misc.{ actions-catalog, job-templates, GHA } ⫽ dhall-utils.{ Plural }
