let dhall-misc =
      https://raw.githubusercontent.com/awseward/dhall-misc/20210612180332/package.dhall
        sha256:61348f29f9ed05d780d7650e9aeba711b4fc71aba263d5de4ac1a9905fbd8be8

in  dhall-misc.{ actions-catalog, job-templates, GHA }
