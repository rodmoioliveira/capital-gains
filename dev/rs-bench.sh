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
    "bc"
    "cat"
    "echo"
    "hyperfine"
    "seq"
    "sync"
    "tee"
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
    printf 1>&2 "You must install all the dependencies for %s to work correctly:\n\n" "rs-bench.sh"
    printf 1>&2 "    %s\n" "${summary[@]}"
    exit 1
  fi
}

bench() {
  hyperfine \
    --prepare 'sync; echo 3 | sudo tee /proc/sys/vm/drop_caches' \
    --warmup 5 \
    --parameter-scan size 0 6 \
    -n 'capital-gains [ input_size=10^{size} ]' \
    'for i in $(seq 1 $(echo "10 ^ {size}" | bc)); do echo src/data/input-1.json; done | xargs cat | ./target/release/capital-gains' \
    --export-markdown benches/results.md
}

main() {
  deps-validate
  bench
}

main
