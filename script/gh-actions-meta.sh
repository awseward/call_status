#!/usr/bin/env bash

set -euo pipefail

_gen_action() {
  local -r workflow_name="$1"

  if [ "${workflow_name}" = '' ]; then
    # shellcheck disable=SC2016
    >&2 echo 'Missing required positional arg `$1` (`workflow_name`)'
    return 1
  fi

  local -r template_file_rel=".github/.workflow_templates/${workflow_name}.dhall"
  local -r output_file_rel=".github/workflows/${workflow_name}.yml"

  >&2 echo "Generating action from ${template_file_rel}"

  ( set -euo pipefail

    cat <<WRN
# Warning: this is an automatically generated file.
#
# It was generated using '${template_file_rel}'.
#
# Please avoid editing it manually unless doing so temporarily.

WRN
    dhall-to-yaml --omit-empty <<< "./${template_file_rel}"
  ) > "${output_file_rel}"
}

_gen_actions() {
  # shellcheck disable=SC2038
  find '.github/.workflow_templates' -type f -name '*.dhall' \
    | xargs -t -n1 -I{} basename {} '.dhall' \
    | xargs -t -n1 "$0" _gen_action
}

check_workflow_templates() {
  _gen_actions
  git diff --color=always --exit-code
}

"$@"
