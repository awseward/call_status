let action_templates =
      https://raw.githubusercontent.com/awseward/dhall-misc/df33f30d4f96f1c511701de262fe5df63c6d9b4c/action_templates/package.dhall sha256:6a0abbf79af93f97ad0260008a33282796120cd8b8614a04ab73d0216acf0867

let concat =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/v20.0.0/Prelude/List/concat sha256:54e43278be13276e03bd1afa89e562e94a0a006377ebea7db14c7562b0de292b

let GHA = action_templates.gha/jobs

let checkedOut =
      λ(steps : List GHA.Step) →
        concat GHA.Step [ [ action_templates.gha/steps.checkout ], steps ]

let collectJobs =
      let Job = { runs-on : List Text, steps : List GHA.Step }

      let JobEntry = { mapKey : Text, mapValue : Job }

      in  concat JobEntry

in  { action_templates
    , checkedOut
    , collectJobs
    , concat
    , gh-actions-dhall =
        https://raw.githubusercontent.com/awseward/gh-actions-dhall/0.2.4/job.dhall sha256:0b2e1700a8ff61bdcd491a828974963544264dd062889b4eb0371be65b86b479
    , gh-actions-shell =
        https://raw.githubusercontent.com/awseward/gh-actions-shell/0.1.2/job.dhall sha256:823c2e674988f61efcb33f757675c104e788172b5316e1c4a65e7f3cafa9d015
    }
