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
    "docker"
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
    printf 1>&2 "You must install all the dependencies for %s to work correctly:\n\n" "docker-build-test.sh"
    printf 1>&2 "    %s\n" "${summary[@]}"
    exit 1
  fi
}

docker-build-test() {
  DOCKER_BUILDKIT=1 docker build \
    -f ./Dockerfile.test \
    --progress=plain \
    --tag "capital-gains:test" .
}

main() {
  deps-validate
  docker-build-test
  docker run -i capital-gains:test
}

main
