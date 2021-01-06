  { concat =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/v20.0.0/Prelude/List/concat sha256:54e43278be13276e03bd1afa89e562e94a0a006377ebea7db14c7562b0de292b
  , gh-actions-dhall =
      https://raw.githubusercontent.com/awseward/gh-actions-dhall/0.2.5/package.dhall sha256:5d3e05eda8f21123a614b8bfc301d5bf3a0ae1898c0b117ac3d38cabc8a2ca98
  , gh-actions-shell =
      https://raw.githubusercontent.com/awseward/gh-actions-shell/0.1.3/package.dhall sha256:422e828ace13b7fb64d67b0834d942928ae4816fae80bfabe024b1709f5bd677
  }
⫽ ( https://raw.githubusercontent.com/awseward/dhall-misc/92efe30d19f7de27b4def32c3e0cb1a81134395d/package.dhall sha256:3d0b2b5ab2b16b87ce49f4eb272722c165f4975dd8c3c78b0ea3833b533250ab
  ).{ action_templates, GHA }
