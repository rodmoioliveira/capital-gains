#!/bin/bash

declare TRACE
[[ "${TRACE}" == 1 ]] && set -o xtrace
set -o nounset
set -o noclobber

deps-validate() {
  summary=()
  is_valid=true

  deps=(
    "cat"
    "gh"
    "grep"
    "jq"
    "sed"
    "sort"
    "tee"
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
    printf 1>&2 "You must install all the dependencies for %s to work correctly:\n\n" "other-projects.sh"
    printf 1>&2 "    %s\n" "${summary[@]}"
    exit 1
  fi
}

other-projects() {
  gh api \
    --paginate \
    --slurp \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    '/search/code?q=+{"operation"%3A"sell"%2C+"unit-cost"%3A20.00%2C+"quantity"%3A+5000}' |
    jq '.[].items[].repository.full_name' -r |
    sed -E 's@(.+)@- [\1](https://github.com/\1)@g' |
    sort -u |
    grep rodmoioliveira -v |
    tee OTHER_PROJECTS.md
}

main() {
  deps-validate
  other-projects
}

main
