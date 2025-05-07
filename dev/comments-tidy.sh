#!/bin/bash

declare TRACE
[[ "${TRACE}" == 1 ]] && set -o xtrace

deps-validate() {
  summary=()
  is_valid=true

  deps=(
    "grep"
    "sed"
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
    printf 1>&2 "You must install all the dependencies for %s to work correctly:\n\n" "comments-tidy.sh"
    printf 1>&2 "    %s\n" "${summary[@]}"
    exit 1
  fi
}

comments-tidy() {
  grep -rE --null --include=\*.rs '‐' -l | xargs -r -0 sed -i -E 's@‐@-@g'
  grep -rE --null --include=\*.rs '\w- {1,5}' -l | xargs -r -0 sed -i -E 's@(\w)- {1,8}@\1@g'
  grep -rE --null --include=\*.rs "’" -l | xargs -r -0 sed -i -E "s@’@'@g"
  grep -rE --null --include=\*.rs "”" -l | xargs -r -0 sed -i -E 's@”@"@g'
  grep -rE --null --include=\*.rs "“" -l | xargs -r -0 sed -i -E 's@“@"@g'
  grep -rE --null --include=\*.rs "ﬀ" -l | xargs -r -0 sed -i -E 's@ﬀ@ff@g'
  grep -rE --null --include=\*.rs "ﬃ" -l | xargs -r -0 sed -i -E 's@ﬃ@ffi@g'
  grep -rE --null --include=\*.rs "ﬁ" -l | xargs -r -0 sed -i -E 's@ﬁ@fi@g'
  grep -rE --null --include=\*.rs "→" -l | xargs -r -0 sed -i -E 's@→@->@g'
}

main() {
  deps-validate
  comments-tidy
}

main
