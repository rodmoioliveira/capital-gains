#!/bin/bash

declare TRACE
[[ "${TRACE}" == 1 ]] && set -o xtrace
set -o errexit
set -o nounset
set -o pipefail
set -o noclobber

deps-validate() {
  summary=()
  is_valid=true

  deps=(
    "cat"
    "diff"
    "grep"
    "sed"
    "sort"
  )
  for dep in "${deps[@]}"; do
    if ! command -v "${dep}" &>/dev/null; then
      summary+=("[deps] Fail ${dep}")
      is_valid=false
    else
      summary+=("[deps] OK   ${dep}")
    fi
  done

  if [[ "${is_valid}" == false ]]; then
    printf 1>&2 "You must install all the dependencies for %s to work correctly:\n\n" "makefile-descriptions.sh"
    printf 1>&2 "    %s\n" "${summary[@]}"
    exit 1
  fi
}

makefile-descriptions() {
  if ! diff <(cat Makefile | grep -E ':.+##' | grep -E '^\w' | sed -E 's/:.+//g' | sort) <(cat Makefile | grep '.PHONY' | sed 's/.PHONY: //g' | sort); then
    printf 1>&2 'There are values in [.PHONY: rule] without description [rule: ## description].\n'
    exit 1
  fi

  printf 1>&2 'All the values in [.PHONY: rule] have description [rule: ## description].\n'
}

main() {
  deps-validate
  makefile-descriptions
}

main
