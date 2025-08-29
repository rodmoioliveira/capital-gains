# capital-gains

`capital-gains` is a CLI to calculate the tax to be paid on profits or losses
from operations in the stock market.

# index

- [Disclaimer](#disclaimer)
- [Rationale](#rationale)
- [Building](#building)
- [Installation](#installation)
- [Usage](#usage)
- [Testing](#testing)
- [Performance](#performance)
- [Memory](#memory)
- [Dependencies](#dependencies)
  - [Deps: Core](#deps-core)
  - [Deps: Dev](#deps-dev)
- [Make Recipes](#make-recipes)
- [How to Release](#how-to-release)
- [Documentation](#documentation)
- [Other Projects](#other-projects)

# Disclaimer

[back^](#index)

This is a code challenge test that I've done for a banking company.

# Rationale

[back^](#index)

I chose [Rust](https://www.rust-lang.org/tools/install) to construct this
application. The key argument for this decision is that [Rust's CLI ecosystem](https://www.jimlynchcodes.com/blog/rust-is-a-great-programming-language-for-building-cli-tools)
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
`Cargo.toml`. Which are:

- [anyhow](https://crates.io/crates/anyhow) - Flexible concrete Error type built on std::error::Error
- [clap](https://crates.io/crates/clap) - A simple to use, efficient, and full-featured Command Line Argument Parser
- [grep-cli](https://crates.io/crates/grep-cli) - Utilities for search oriented command line applications.
- [libc](https://crates.io/crates/libc) - Raw FFI bindings to platform libraries like libc.
- [serde](https://crates.io/crates/serde) - A generic serialization/deserialization framework
- [serde_json](https://crates.io/crates/serde_json) - A JSON serialization file format

# Building

[back^](#index)

`capital-gains` is written in Rust, so you'll need to grab a [Rust installation](https://www.rust-lang.org/tools/install) in order to compile it.
To build `capital-gains` from source, run:

```
make rs-build
```

# Installation

[back^](#index)

Archives of [precompiled binaries](https://github.com/rodmoioliveira/capital-gains/releases) for
`capital-gains` are available for Windows, macOS, and Linux.

To install `capital-gains` on your local machine, install
[Rust](https://www.rust-lang.org/tools/install) and run:

```
make rs-install
```

If you don't want to install Rust on your machine, you may build the Docker
image with the command:

```
make docker-build-local
```

The Docker image is constructed using a
[distroless](https://github.com/GoogleContainerTools/distroless) image.
Therefore is very small and more secure, because contains only the necessary
code to run the application:

```
$ docker images

REPOSITORY      TAG       IMAGE ID       CREATED         SIZE
capital-gains   local     9a7201859b1e   2 minutes ago   24.7MB
```

# Usage

[back^](#index)

`capital-gains` follows the [Command Line Interface Guidelines](https://clig.dev/). To get help about the CLI usage, run:

```
capital-gains --help
# or
docker run -i capital-gains:local --help

capital-gains is a CLI to calculate the tax to be paid on profits or losses from
operations in the stock financial market.

Usage: capital-gains < [TRANSACTIONS]

Arguments:
  [TRANSACTIONS]
          A list of financial stock market operations that are JSON formatted
          and separated by lines that need to be inputted using standard input.

          [default: -]

Options:
  -h, --help
          Print help (see a summary with '-h')

  -V, --version
          Print version

Examples:
  capital-gains <src/data/input-*.json
  <src/data/input-*.json capital-gains
  cat src/data/input-*.json | capital-gains

  docker run -i capital-gains:local <src/data/input-*.json
  <src/data/input-*.json docker run -i capital-gains:local
  cat src/data/input-*.json | docker run -i capital-gains:local
```

# Testing

[back^](#index)

To test the application, you have two options:

1. Install [Rust](https://www.rust-lang.org/tools/install) and run `make rs-tests`;
2. Run the tests within Docker with `make docker-build-test`;

# Performance

[back^](#index)

Here are the performance results measured with
[hyperfine](https://github.com/sharkdp/hyperfine) according to input size:

| Command                             |        Mean [ms] | Min [ms] | Max [ms] |         Relative |
| :---------------------------------- | ---------------: | -------: | -------: | ---------------: |
| `capital-gains [ input_size=10^0 ]` |       15.1 ± 2.2 |     11.5 |     24.8 |      1.01 ± 0.18 |
| `capital-gains [ input_size=10^1 ]` |       14.9 ± 1.5 |     12.1 |     19.7 |             1.00 |
| `capital-gains [ input_size=10^2 ]` |       18.9 ± 2.2 |     15.5 |     25.5 |      1.26 ± 0.20 |
| `capital-gains [ input_size=10^3 ]` |       52.6 ± 6.8 |     40.6 |     61.7 |      3.52 ± 0.58 |
| `capital-gains [ input_size=10^4 ]` |     276.5 ± 16.1 |    243.1 |    294.9 |     18.53 ± 2.16 |
| `capital-gains [ input_size=10^5 ]` |   2622.1 ± 193.7 |   2420.4 |   3020.5 |   175.75 ± 22.02 |
| `capital-gains [ input_size=10^6 ]` | 35029.2 ± 8242.0 |  24562.3 |  44798.0 | 2347.88 ± 601.36 |

The results above were measured on the following machine:

```
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
```

# Memory

[back^](#index)

No memory leaks were found using [Valgrind](https://valgrind.org/). We don't
have to worry about the data presented in the still reachable section, [here's why](https://stackoverflow.com/a/3857638). To execute the memory test, run:

```
make valgrind-test

==499495== Memcheck, a memory error detector
==499495== Copyright (C) 2002-2017, and GNU GPL'd, by Julian Seward et al.
==499495== Using Valgrind-3.18.1 and LibVEX; rerun with -h for copyright info
==499495== Command: capital-gains
==499495==
==499495==
==499495== HEAP SUMMARY:
==499495==     in use at exit: 8,192 bytes in 1 blocks
==499495==   total heap usage: 47 allocs, 46 frees, 17,539 bytes allocated
==499495==
==499495== LEAK SUMMARY:
==499495==    definitely lost: 0 bytes in 0 blocks
==499495==    indirectly lost: 0 bytes in 0 blocks
==499495==      possibly lost: 0 bytes in 0 blocks
==499495==    still reachable: 8,192 bytes in 1 blocks
==499495==         suppressed: 0 bytes in 0 blocks
==499495== Reachable blocks (those to which a pointer was found) are not shown.
==499495== To see them, rerun with: --leak-check=full --show-leak-kinds=all
==499495==
==499495== For lists of detected and suppressed errors, rerun with: -s
==499495== ERROR SUMMARY: 0 errors from 0 contexts (suppressed: 0 from 0)
```

# Dependencies

[back^](#index)

## Deps: Core

[back^](#index)

- [Rust](https://www.rust-lang.org/tools/install) - A language empowering everyone to build reliable and efficient software.

## Deps: Dev

[back^](#index)

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
- [typos-cli](https://github.com/crate-ci/typos) - Source code spell checker.
- [valgrind](https://valgrind.org/) - Valgrind is an instrumentation framework for building dynamic analysis tools.
- [yq](https://github.com/mikefarah/yq) - yq is a portable command-line YAML, JSON, XML, CSV, TOML and properties processor.

# Make Recipes

[back^](#index)

Run `make` to view all possible recipes to run within the project:

```
bash-all               Run all bash tests
bash-check             Check format bash code
bash-deps              Install bash dependencies
bash-fmt               Format bash code
bash-lint              Check lint bash code
comments-tidy          Tidy comments within code
doc-changelog          Write CHANGELOG.md
doc-other-projects     Write OTHER_PROJECTS.md
doc-readme             Write README.md
docker-build-local     Docker build local image
docker-build-test      Docker build test image and run tests
dprint-check           Dprint check
dprint-fmt             Dprint format
help                   Display this help screen
makefile-descriptions  Check if all Makefile rules have descriptions
rs-audit               Audit Cargo.lock
rs-audit-fix           Update Cargo.toml to fix vulnerable dependency requirement
rs-bench               Benchmark binary
rs-build               Build binary
rs-cargo-deps          Install cargo dependencies
rs-check               Run check
rs-dev                 Run check in watch mode
rs-doc                 Open app documentation
rs-fix                 Fix rust code
rs-fmt                 Format rust code
rs-fmt-fix             Format fix rust code
rs-install             Install binary
rs-lint                Lint rust code
rs-lint-fix            Fix lint rust code
rs-outdated            Display when dependencies are out of date
rs-tests               Run tests
rs-uninstall           Uninstall binary
rs-update-cargo        Update dependencies
rs-update-rustup       Update rust
typos                  Check typos
typos-fix              Fix typos
valgrind-test          Valgrind test for memory leaks
```

# How to Release

[back^](#index)

To generate a new version, you need to follow these steps:

1. In the `main` branch, you must bump the version inside the `Cargo.toml` file.
2. Run `make rs-check` so that the version is changed in the `Cargo.lock` file.
3. Run the command `git add -A && git commit -m "release: bump version"`.
4. Run the command `git tag -a <your.new.version> -m "version <your.new.version>"`.
5. Run the command `make doc-changelog && make doc-readme`.
6. Run the command `git add -A && git commit -m "release: <your.new.version>"`.
7. Run `git push` to `main`.

# Documentation

[back^](#index)

This documentation is generated by shell scripts. Please check out `dev`
directory for more information.

# Other Projects

[back^](#index)

- [0x0th30/capital-gains](https://github.com/0x0th30/capital-gains)
- [Adriano-Santtos/capital-gain-tax-calcutator__python__poc](https://github.com/Adriano-Santtos/capital-gain-tax-calcutator__python__poc)
- [alexx-navarro/capital-gain](https://github.com/alexx-navarro/capital-gain)
- [andrews-pd/tax-calculator](https://github.com/andrews-pd/tax-calculator)
- [arielalvesdutra/java-calculo-impostos](https://github.com/arielalvesdutra/java-calculo-impostos)
- [barbaramariani/capital-gains](https://github.com/barbaramariani/capital-gains)
- [brienze1/test-nubank](https://github.com/brienze1/test-nubank)
- [BrunnoQ/calculator](https://github.com/BrunnoQ/calculator)
- [CamiloHernandezC/pruebaNu](https://github.com/CamiloHernandezC/pruebaNu)
- [carlosfrtr/ganho-de-capital](https://github.com/carlosfrtr/ganho-de-capital)
- [cdcordobaa/stock-tax-calculator](https://github.com/cdcordobaa/stock-tax-calculator)
- [CesarF/capital-gains](https://github.com/CesarF/capital-gains)
- [chinnonsantos/capital-gains](https://github.com/chinnonsantos/capital-gains)
- [crevelandiagu/nu-bank-test](https://github.com/crevelandiagu/nu-bank-test)
- [dalmarcogd/capital-gain](https://github.com/dalmarcogd/capital-gain)
- [davidcaliari/MeuLivroDeReceitas](https://github.com/davidcaliari/MeuLivroDeReceitas)
- [diegoalves0688/challenge-ganho-de-capital](https://github.com/diegoalves0688/challenge-ganho-de-capital)
- [diegolopes98/capital-gains-cli](https://github.com/diegolopes98/capital-gains-cli)
- [DogMaker/capital-gains](https://github.com/DogMaker/capital-gains)
- [DouglasJunqueira/CapitalGains](https://github.com/DouglasJunqueira/CapitalGains)
- [drunkman123/Bank_Challenge](https://github.com/drunkman123/Bank_Challenge)
- [eliardo/Ganho-de-Capital-](https://github.com/eliardo/Ganho-de-Capital-)
- [elmanza/CapitalGains](https://github.com/elmanza/CapitalGains)
- [emersonmendes/capital-gains](https://github.com/emersonmendes/capital-gains)
- [erick-tmr/stocks-tax-calculator](https://github.com/erick-tmr/stocks-tax-calculator)
- [evaporei/capital-gains](https://github.com/evaporei/capital-gains)
- [FabsHC/capital-gain](https://github.com/FabsHC/capital-gain)
- [FabsHC/stock-tax-calculation](https://github.com/FabsHC/stock-tax-calculation)
- [felipebortoli/capital-gains-nubank](https://github.com/felipebortoli/capital-gains-nubank)
- [Felipefsanos/capital-gains](https://github.com/Felipefsanos/capital-gains)
- [fmo00/tech-challenge](https://github.com/fmo00/tech-challenge)
- [gabmac/capital-gain](https://github.com/gabmac/capital-gain)
- [gabrielfreirebraz/capital-gain-cli](https://github.com/gabrielfreirebraz/capital-gain-cli)
- [Gabrielhmr/Nubank](https://github.com/Gabrielhmr/Nubank)
- [gabriellaporte/nubank](https://github.com/gabriellaporte/nubank)
- [gasil96/capital-gains](https://github.com/gasil96/capital-gains)
- [Grifo89/Nubank-Assessment](https://github.com/Grifo89/Nubank-Assessment)
- [guilhermeikeda/go-practice](https://github.com/guilhermeikeda/go-practice)
- [GuilhermePortella/desafio](https://github.com/GuilhermePortella/desafio)
- [gustuxd/capital-gains](https://github.com/gustuxd/capital-gains)
- [henriquecrz/capital-gains](https://github.com/henriquecrz/capital-gains)
- [iam-eduardo/capital-gains](https://github.com/iam-eduardo/capital-gains)
- [igor0212/nubank](https://github.com/igor0212/nubank)
- [IngDanielALH/capital_gains](https://github.com/IngDanielALH/capital_gains)
- [ivomoreirati/capital-gains-hexagonal](https://github.com/ivomoreirati/capital-gains-hexagonal)
- [JessicaNathany/calculates-capital-gain](https://github.com/JessicaNathany/calculates-capital-gain)
- [jonathanandujo/dsa](https://github.com/jonathanandujo/dsa)
- [jonathanpontes/ganho-capital](https://github.com/jonathanpontes/ganho-capital)
- [jonnycca/capital-gains](https://github.com/jonnycca/capital-gains)
- [JulianePires/capital-gain](https://github.com/JulianePires/capital-gain)
- [julianevianna/ganho-capital](https://github.com/julianevianna/ganho-capital)
- [jvmuller/code-challenge-ganho-de-capital](https://github.com/jvmuller/code-challenge-ganho-de-capital)
- [klferreira/capital-gains](https://github.com/klferreira/capital-gains)
- [Lakshamana/assets-flow](https://github.com/Lakshamana/assets-flow)
- [leguzman/nu-capital-gains](https://github.com/leguzman/nu-capital-gains)
- [lhpvolpi/nu-capital-gains](https://github.com/lhpvolpi/nu-capital-gains)
- [liberopassadorneto/financial-market](https://github.com/liberopassadorneto/financial-market)
- [lmgomes91/capital_gains](https://github.com/lmgomes91/capital_gains)
- [lucasoliveiraa/code-challenge](https://github.com/lucasoliveiraa/code-challenge)
- [lucaspiresc/Financial-Tax-Processor](https://github.com/lucaspiresc/Financial-Tax-Processor)
- [luisjavierjn/capitalgains](https://github.com/luisjavierjn/capitalgains)
- [luiz-santos-it/Investment-Earnings-Tax-Calculator](https://github.com/luiz-santos-it/Investment-Earnings-Tax-Calculator)
- [marcelom220/Desafio-nubank](https://github.com/marcelom220/Desafio-nubank)
- [MarcioBdeveloper/java-cli](https://github.com/MarcioBdeveloper/java-cli)
- [mateusgms/nu-challenge](https://github.com/mateusgms/nu-challenge)
- [MateusGuedess/nubank-test](https://github.com/MateusGuedess/nubank-test)
- [matheuspicioli/capital-gains](https://github.com/matheuspicioli/capital-gains)
- [MaximilianoOliveiraFurtado/capital-gains-api](https://github.com/MaximilianoOliveiraFurtado/capital-gains-api)
- [mickambar19/capital-gains](https://github.com/mickambar19/capital-gains)
- [pedrohrod/capital-gains](https://github.com/pedrohrod/capital-gains)
- [pplanel/capital-gains](https://github.com/pplanel/capital-gains)
- [ProfThiagoVicco/Nubank](https://github.com/ProfThiagoVicco/Nubank)
- [rafaelcx/nu-capital-test](https://github.com/rafaelcx/nu-capital-test)
- [ranog/capital-gains](https://github.com/ranog/capital-gains)
- [ratacheski/capital-gains](https://github.com/ratacheski/capital-gains)
- [renatofagalde/nubank-ganho-capital](https://github.com/renatofagalde/nubank-ganho-capital)
- [RodrigoLimaM/capital-gains](https://github.com/RodrigoLimaM/capital-gains)
- [rodrigosdo/capital-gains](https://github.com/rodrigosdo/capital-gains)
- [rodrigo-sntg/CapitalGainsCalculator](https://github.com/rodrigo-sntg/CapitalGainsCalculator)
- [RogerToledo/capital-gain](https://github.com/RogerToledo/capital-gain)
- [rpedrodasilva10/capital-gains-nubank](https://github.com/rpedrodasilva10/capital-gains-nubank)
- [samsantosb/code-challenge](https://github.com/samsantosb/code-challenge)
- [ssgoncalves/stock-challenge](https://github.com/ssgoncalves/stock-challenge)
- [thalysf/tax-challange](https://github.com/thalysf/tax-challange)
- [themarcosramos/ganhoDeCapital](https://github.com/themarcosramos/ganhoDeCapital)
- [thiagolcmelo/capital-gains](https://github.com/thiagolcmelo/capital-gains)
- [thiagomendes/capital-gains](https://github.com/thiagomendes/capital-gains)
- [thiagorfaria/Capital-Ganho](https://github.com/thiagorfaria/Capital-Ganho)
- [thiagorigonatti/capital-gains](https://github.com/thiagorigonatti/capital-gains)
- [tiagonpsilva/calculadora-ganho-capital](https://github.com/tiagonpsilva/calculadora-ganho-capital)
- [tota1099/capital_gains](https://github.com/tota1099/capital_gains)
- [valerivno/PI-UFABC](https://github.com/valerivno/PI-UFABC)
- [VictorNevola/capital-gains](https://github.com/VictorNevola/capital-gains)
- [VictorNevola/stocks-calc](https://github.com/VictorNevola/stocks-calc)
- [victorSsantos/code-challenge-capital-gain](https://github.com/victorSsantos/code-challenge-capital-gain)
- [vinicinbgs/capital-gains-nodejs](https://github.com/vinicinbgs/capital-gains-nodejs)
- [willianpinho/capital-gains-python](https://github.com/willianpinho/capital-gains-python)
