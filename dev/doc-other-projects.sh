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
    "jq"
    "rm"
    "sed"
    "seq"
    "sleep"
    "sort"
    "sponge"
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
  if [[ -f OTHER_PROJECTS.md ]]; then
    rm OTHER_PROJECTS.md
  fi

  local steps=5
  for i in $(seq 1 "${steps}"); do
    printf 1>&2 "Step %s/%s\n" "${i}" "${steps}"
    gh api \
      -H "Accept: application/vnd.github+json" \
      -H "X-GitHub-Api-Version: 2022-11-28" \
      '/search/code?page='"${i}"'&per_page=1000&q=+{"operation"%3A"sell"%2C+"unit-cost"%3A20.00%2C+"quantity"%3A+5000}' |
      jq '.items[].repository.full_name' -r |
      sort -u |
      sed -E 's@(.+)@- [\1](https://github.com/\1)@g' |
      tee -a OTHER_PROJECTS.md
    sleep 5
  done

  cat OTHER_PROJECTS.md | sort -u | grep rodmoioliveira -v | sponge OTHER_PROJECTS.md
}

main() {
  deps-validate
  other-projects
}

main
