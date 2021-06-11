let dhall-misc =
      https://raw.githubusercontent.com/awseward/dhall-misc/20210611190215/package.dhall
        sha256:9739f7e3d3b4be0cbff599ac3dd63045b474d6f34f081f6f6a3166aa5616b286

in  dhall-misc.{ actions-catalog, job-templates, GHA }
