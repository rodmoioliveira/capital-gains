#!/bin/bash

declare TRACE
[[ "${TRACE}" == 1 ]] && set -o xtrace
set -o errexit
set -o nounset
set -o pipefail
set -o noclobber
shopt -s inherit_errexit

deps-validate() {
  summary=()
  is_valid=true

  deps=(
    "cargo"
    "cat"
    "dprint"
    "grep"
    "jq"
    "make"
    "paste"
    "sed"
    "sort"
    "yq"
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
    printf 1>&2 "You must install all the dependencies for %s to work correctly:\n\n" "doc-readme.sh"
    printf 1>&2 "    %s\n" "${summary[@]}"
    exit 1
  fi
}

index() {
  paste -d "" \
    <(
      cat dev/doc-readme.sh |
        grep -E '^#{1,} [A-Z]' |
        sed 's/^ {1,}//g' |
        sed -E 's/(^#{1,}) (.+)/\1\[\2]/g' |
        sed 's/#/  /g' |
        sed -E 's/\[/- [/g'
    ) \
    <(
      cat dev/doc-readme.sh |
        grep -E '^#{1,} [A-Z]' |
        sed 's/#//g' |
        sed -E 's/^ {1,}//g' |
        # https://www.gnu.org/software/grep/manual/html_node/Character-Classes-and-Bracket-Expressions.html
        sed -E "s1[][!#$%&'()*+,./:;<=>?@\\^_\`{|}~]11g" |
        sed -E 's/"//g' |
        sed 's/[A-Z]/\L&/g' |
        sed 's/ /-/g' |
        sed -E 's@(.+)@(#\1)@g'
    )
}

backlink() {
  sed -i -E '/^#{1,} [A-Z]/a\\n\[back^\](#index)' README.md
}

readme() {
  cat <<EOF >|README.md
# capital-gains

\`capital-gains\` is a CLI to calculate the tax to be paid on profits or losses
from operations in the stock market.

# index

$(index)

# Disclaimer

This is a code challenge test that I've done for a banking company.

# Rationale

I chose [Rust](https://www.rust-lang.org/tools/install) to construct this
application. The key argument for this decision is that [Rust's CLI
ecosystem](https://www.jimlynchcodes.com/blog/rust-is-a-great-programming-language-for-building-cli-tools)
is one of the best available today. Add to that the fact that Rust is a very
[efficient](https://thenewstack.io/which-programming-languages-use-the-least-electricity/),
[stable](https://www.reddit.com/r/rust/comments/j2xzuq/how_stable_is_rust/), and
[safe](https://linuxsecurity.com/news/government/memory-safe-languages)
language. All of this has resulted in an increasing number of
[adopters](https://github.blog/developer-skills/programming-languages-and-frameworks/why-rust-is-the-most-admired-language-among-developers/),
more use [inside businesses](https://serokell.io/blog/rust-companies), and even
its [inclusion in the Linux kernel](https://youtu.be/YyRVOGxRKLg).

In order to reduce the core application libraries to the minimum, I've used only
a few dependencies crates for this application, as you can see in the
\`Cargo.toml\`. Which are:

$(
    paste -d '@' \
      <(
        yq '.dependencies | keys[]' Cargo.toml |
          sort |
          sed -E 's@(.+)@- [\1](https://crates.io/crates/\1)@g'
      ) \
      <(
        yq '.dependencies | keys[]' Cargo.toml |
          sort |
          xargs -n1 bash -c 'cargo info $0 2>/dev/null | sed -n "2p"'
      ) |
      sed 's/@/ - /g'
  )

# Building

\`capital-gains\` is written in Rust, so you'll need to grab a [Rust
installation](https://www.rust-lang.org/tools/install) in order to compile it.
To build \`capital-gains\` from source, run:

\`\`\`
make rs-build
\`\`\`

# Installation

Archives of [precompiled
binaries](https://github.com/rodmoioliveira/capital-gains/releases) for
\`capital-gains\` are available for Windows, macOS, and Linux.

To install \`capital-gains\` on your local machine, install
[Rust](https://www.rust-lang.org/tools/install) and run:

\`\`\`
make rs-install
\`\`\`

If you don't want to install Rust on your machine, you may build the Docker
image with the command:

\`\`\`
make docker-build-local
\`\`\`

The Docker image is constructed using a
[distroless](https://github.com/GoogleContainerTools/distroless) image.
Therefore is very small and more secure, because contains only the necessary
code to run the application:

\`\`\`
$ docker images

REPOSITORY      TAG       IMAGE ID       CREATED         SIZE
capital-gains   local     9a7201859b1e   2 minutes ago   24.7MB
\`\`\`

# Usage

\`capital-gains\` follows the [Command Line Interface
Guidelines](https://clig.dev/). To get help about the CLI usage, run:

\`\`\`
cargo run -- --help
# or
docker run -i capital-gains:local --help

$(cargo run -- --help)
\`\`\`

# Testing

To test the application, you have two options:

1. Install [Rust](https://www.rust-lang.org/tools/install) and run \`make rs-tests\`;
2. Run the tests within Docker with \`make docker-build-test\`;

# Performance

Here are the performance results measured with
[hyperfine](https://github.com/sharkdp/hyperfine) according to input size:

$(cat benches/results.md)

The results above were measured on the following machine:

\`\`\`
inxi -Cmz

Memory:
  RAM: total: 31.04 GiB used: 13.96 GiB (45.0%)
  RAM Report:
    permissions: Unable to run dmidecode. Root privileges required.
CPU:
  Info: 10-core (2-mt/8-st) model: 13th Gen Intel Core i5-1345U bits: 64
    type: MST AMCP cache: L2: 6.5 MiB
  Speed (MHz): avg: 984 min/max: 400/4700:3500 cores: 1: 1262 2: 1130
    3: 977 4: 400 5: 1400 6: 1063 7: 1389 8: 1034 9: 904 10: 974 11: 886
    12: 400
\`\`\`

# Memory

No memory leaks were found using [Valgrind](https://valgrind.org/). We don't
have to worry about the data presented in the still reachable section, [here's
why](https://stackoverflow.com/a/3857638). To execute the memory test, run:

\`\`\`
make valgrind-test

$(cat tests/valgrind.txt)
\`\`\`

# Dependencies

## Deps: Core

- [Rust](https://www.rust-lang.org/tools/install) - A language empowering everyone to build reliable and efficient software.

## Deps: Dev

- [Docker](https://docs.docker.com/engine/install/) - Docker is an open platform for developing, shipping, and running applications.
- [cargo-audit](https://crates.io/crates/cargo-audit) - Audit your dependencies for crates with security vulnerabilities reported to the RustSec Advisory Database.
- [cargo-outdated](https://crates.io/crates/cargo-outdated) - A cargo subcommand for displaying when Rust dependencies are out of date.
- [cargo-watch](https://crates.io/crates/cargo-watch) - Cargo Watch watches over your project's source for changes, and runs Cargo commands when they occur.
- [clippy](https://doc.rust-lang.org/clippy/installation.html) - A collection of lints to catch common mistakes and improve your Rust code.
- [dprint](https://dprint.dev/install/) - dprint is a command line application that automatically formats code.
- [git-cliff](https://git-cliff.org/docs/) - git-cliff can generate changelog files from the Git history by utilizing conventional commits as well as regex-powered custom parsers.
- [hyperfine](https://github.com/sharkdp/hyperfine) - A command-line benchmarking tool.
- [jq](https://github.com/jqlang/jq) - jq is a lightweight and flexible command-line JSON processor akin to sed,awk,grep, and friends for JSON data.
- [shellcheck](https://www.shellcheck.net/) - A static analysis tool for shell scripts.
- [shfmt](https://github.com/mvdan/sh) - A shell parser, formatter, and interpreter with bash support.
- [typos-cli](https://github.com/crate-ci/typos) -  Source code spell checker.
- [valgrind](https://valgrind.org/) - Valgrind is an instrumentation framework for building dynamic analysis tools.
- [yq](https://github.com/mikefarah/yq) - yq is a portable command-line YAML, JSON, XML, CSV, TOML and properties processor.

# Make Recipes

Run \`make\` to view all possible recipes to run within the project:

\`\`\`
$(make help)
\`\`\`

# How to Release

$(cat RELEASE.md)

# Documentation

This documentation is generated by shell scripts. Please check out \`dev\`
directory for more information.

# Other Projects

$(cat OTHER_PROJECTS.md)
EOF

  sed -i -E '/^make\[[0-9]/d' README.md
  sed -i -E 's/cargo run --/capital-gains/g' README.md
  sed -i -E 's/^ {1,}$//g' README.md
  backlink
  dprint fmt README.md CHANGELOG.md
}

main() {
  deps-validate
  readme
}

main
