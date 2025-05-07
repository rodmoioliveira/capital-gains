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
    "git"
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
    printf 1>&2 "You must install all the dependencies for %s to work correctly:\n\n" "docker-build-local.sh"
    printf 1>&2 "    %s\n" "${summary[@]}"
    exit 1
  fi
}

docker-build-local() {
  BUILD_VCS_REF="$(git -P log --oneline --format='%h' -n1)"

  DOCKER_BUILDKIT=1 docker build \
    -f ./Dockerfile.local \
    --progress=plain \
    --build-arg BUILD_DATE="$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
    --build-arg BUILD_NAME="$(grep ^name Cargo.toml | sed 's/name = //g; s/"//g')" \
    --build-arg BUILD_DESCRIPTION="$(grep ^description Cargo.toml | sed 's/description = //g; s/"//g')" \
    --build-arg BUILD_VCS_URL="$(grep ^repository Cargo.toml | sed 's/repository = //g; s/"//g')" \
    --build-arg BUILD_VCS_REF="${BUILD_VCS_REF}" \
    --build-arg BUILD_VERSION="$(grep ^version Cargo.toml | sed 's/version = //g; s/"//g')" \
    --tag "capital-gains:local" .
}

main() {
  deps-validate
  docker-build-local
}

main
