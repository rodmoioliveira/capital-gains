#!/bin/bash

declare TRACE
[[ "${TRACE}" == 1 ]] && set -o xtrace
set -o errexit
set -o nounset
set -o pipefail

deps-validate() {
  summary=()
  is_valid=true

  deps=(
    "grep"
    "sed"
    "valgrind"
    "xargs"
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
    printf 1>&2 "You must install all the dependencies for %s to work correctly:\n\n" "valgrind-test.sh"
    printf 1>&2 "    %s\n" "${summary[@]}"
    exit 1
  fi
}

valgrind-test() {
  bash -c "valgrind --leak-check=full <src/data/input-1.json capital-gains > /dev/null" |& tee "./tests/valgrind.txt"
}

main() {
  deps-validate
  valgrind-test
}

main
