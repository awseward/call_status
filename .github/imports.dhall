let dhall-misc =
      https://raw.githubusercontent.com/awseward/dhall-misc/20210430054139/package.dhall sha256:2841a40cce2ad8eeafbac552ddb9fef4a46353a5848eb72e190ee70440f85572

in  dhall-misc.{ actions-catalog, action_templates, GHA }
