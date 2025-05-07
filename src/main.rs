pub mod models {
    use serde::{Deserialize, Serialize};

    #[derive(Serialize, Deserialize, Debug)]
    #[serde(rename_all = "lowercase")]
    pub enum Operation {
        Buy,
        Sell,
    }

    #[derive(Serialize, Deserialize, Debug)]
    #[serde(rename_all = "kebab-case")]
    pub struct Transaction {
        pub operation: Operation,
        pub unit_cost: f64,
        pub quantity: u64,
    }

    #[derive(Serialize, Deserialize, Debug, PartialEq)]
    #[serde(rename_all = "lowercase")]
    #[serde(untagged)]
    pub enum TransactionResult {
        Ok(Tax),
        Err(Error),
    }

    #[derive(Serialize, Deserialize, Debug, PartialEq, Default)]
    pub struct Tax {
        pub tax: f64,
    }

    #[derive(Serialize, Deserialize, Debug, PartialEq, Default)]
    pub struct Error {
        pub error: String,
    }
}

pub mod finance {
    use crate::models::{Error, Operation, Tax, Transaction, TransactionResult};

    const TAX_PROFIT: f64 = 0.2_f64;
    const TAX_EXEMPTION: f64 = 20_000_f64;

    pub fn calculate_taxes(input: Vec<Transaction>) -> Vec<TransactionResult> {
        let input_len = input.len();
        let mut result: Vec<TransactionResult> = Vec::with_capacity(input_len);
        if input_len == 0 {
            return result;
        }

        let mut transaction_losses = 0_f64;
        let mut transaction_stock_quantity = 0_u64;
        let mut transaction_average_price = input[0].unit_cost;

        for op in input {
            let transaction_total = op.quantity as f64 * op.unit_cost;
            let transaction_balance =
                (op.unit_cost - transaction_average_price) * op.quantity as f64;

            match op.operation {
                Operation::Buy => {
                    let average_price = ((transaction_stock_quantity as f64
                        * transaction_average_price)
                        + transaction_total)
                        / (transaction_stock_quantity + op.quantity) as f64;
                    transaction_average_price = f64::ceil(average_price * 100.0) / 100.0;
                    transaction_stock_quantity += op.quantity;
                    result.push(TransactionResult::Ok(Tax::default()));
                }
                Operation::Sell => {
                    match transaction_stock_quantity.checked_sub(op.quantity) {
                        Some(v) => {
                            transaction_stock_quantity = v;
                        }
                        None => {
                            result.push(TransactionResult::Err(Error {
                                error: "Can't sell more stocks than you have".to_string(),
                            }));
                            continue;
                        }
                    }

                    match transaction_balance.is_sign_positive() {
                        true => {
                            if transaction_total <= TAX_EXEMPTION {
                                result.push(TransactionResult::Ok(Tax::default()));
                            } else {
                                let mut new_balance = transaction_balance;
                                let has_losses = transaction_losses < 0_f64;
                                let has_full_debt_pay_off =
                                    transaction_losses.abs() < transaction_balance;

                                if has_losses {
                                    if has_full_debt_pay_off {
                                        new_balance = transaction_balance + transaction_losses;
                                        transaction_losses = 0_f64;
                                    } else {
                                        transaction_losses += transaction_balance;
                                        new_balance = 0_f64;
                                    }
                                }

                                result.push(TransactionResult::Ok(Tax {
                                    tax: new_balance * TAX_PROFIT,
                                }));
                            }
                        }
                        false => {
                            result.push(TransactionResult::Ok(Tax::default()));
                            transaction_losses += transaction_balance
                        }
                    };
                }
            };
        }
        result
    }

    #[cfg(test)]
    pub mod tests {
        use crate::finance;
        use crate::models::{Transaction, TransactionResult};

        #[test]
        fn case_1() -> anyhow::Result<()> {
            let input: Vec<Transaction> = serde_json::from_str(include_str!("data/input-1.json"))?;
            let expected: Vec<TransactionResult> =
                serde_json::from_str(include_str!("data/expected-1.json"))?;
            let result: Vec<TransactionResult> = finance::calculate_taxes(input);
            assert_eq!(expected, result);
            Ok(())
        }

        #[test]
        fn case_2() -> anyhow::Result<()> {
            let input: Vec<Transaction> = serde_json::from_str(include_str!("data/input-2.json"))?;
            let expected: Vec<TransactionResult> =
                serde_json::from_str(include_str!("data/expected-2.json"))?;
            let result: Vec<TransactionResult> = finance::calculate_taxes(input);
            assert_eq!(expected, result);
            Ok(())
        }

        #[test]
        fn case_3() -> anyhow::Result<()> {
            let input: Vec<Transaction> = serde_json::from_str(include_str!("data/input-3.json"))?;
            let expected: Vec<TransactionResult> =
                serde_json::from_str(include_str!("data/expected-3.json"))?;
            let result: Vec<TransactionResult> = finance::calculate_taxes(input);
            assert_eq!(expected, result);
            Ok(())
        }

        #[test]
        fn case_4() -> anyhow::Result<()> {
            let input: Vec<Transaction> = serde_json::from_str(include_str!("data/input-4.json"))?;
            let expected: Vec<TransactionResult> =
                serde_json::from_str(include_str!("data/expected-4.json"))?;
            let result: Vec<TransactionResult> = finance::calculate_taxes(input);
            assert_eq!(expected, result);
            Ok(())
        }

        #[test]
        fn case_5() -> anyhow::Result<()> {
            let input: Vec<Transaction> = serde_json::from_str(include_str!("data/input-5.json"))?;
            let expected: Vec<TransactionResult> =
                serde_json::from_str(include_str!("data/expected-5.json"))?;
            let result: Vec<TransactionResult> = finance::calculate_taxes(input);
            assert_eq!(expected, result);
            Ok(())
        }

        #[test]
        fn case_6() -> anyhow::Result<()> {
            let input: Vec<Transaction> = serde_json::from_str(include_str!("data/input-6.json"))?;
            let expected: Vec<TransactionResult> =
                serde_json::from_str(include_str!("data/expected-6.json"))?;
            let result: Vec<TransactionResult> = finance::calculate_taxes(input);
            assert_eq!(expected, result);
            Ok(())
        }

        #[test]
        fn case_7() -> anyhow::Result<()> {
            let input: Vec<Transaction> = serde_json::from_str(include_str!("data/input-7.json"))?;
            let expected: Vec<TransactionResult> =
                serde_json::from_str(include_str!("data/expected-7.json"))?;
            let result: Vec<TransactionResult> = finance::calculate_taxes(input);
            assert_eq!(expected, result);
            Ok(())
        }

        #[test]
        fn case_8() -> anyhow::Result<()> {
            let input: Vec<Transaction> = serde_json::from_str(include_str!("data/input-8.json"))?;
            let expected: Vec<TransactionResult> =
                serde_json::from_str(include_str!("data/expected-8.json"))?;
            let result: Vec<TransactionResult> = finance::calculate_taxes(input);
            assert_eq!(expected, result);
            Ok(())
        }

        #[test]
        fn case_9() -> anyhow::Result<()> {
            let input: Vec<Transaction> = serde_json::from_str(include_str!("data/input-9.json"))?;
            let expected: Vec<TransactionResult> =
                serde_json::from_str(include_str!("data/expected-9.json"))?;
            let result: Vec<TransactionResult> = finance::calculate_taxes(input);
            assert_eq!(expected, result);
            Ok(())
        }

        #[test]
        fn case_10() -> anyhow::Result<()> {
            let input: Vec<Transaction> = serde_json::from_str(include_str!("data/input-10.json"))?;
            let expected: Vec<TransactionResult> =
                serde_json::from_str(include_str!("data/expected-10.json"))?;
            let result: Vec<TransactionResult> = finance::calculate_taxes(input);
            assert_eq!(expected, result);
            Ok(())
        }
    }
}

pub mod help {
    pub const TEMPLATE: &str = "\
{about-with-newline}
{usage-heading} {name} < [TRANSACTIONS]

{all-args}

Examples:
{tab}{name} <src/data/input-*.json
{tab}<src/data/input-*.json {name}
{tab}cat src/data/input-*.json | {name}

{tab}docker run -i {name}:local <src/data/input-*.json
{tab}<src/data/input-*.json docker run -i {name}:local
{tab}cat src/data/input-*.json | docker run -i {name}:local
";

    pub const TRANSACTIONS: &str =
        "A list of financial stock market operations that are JSON formatted
and separated by lines that need to be inputted using standard input.";
}

pub mod cli {
    use crate::help;
    use clap::Parser;

    #[derive(Debug, Parser)]
    #[clap(
        about = clap::crate_description!(),
        author = clap::crate_authors!(),
        color = clap::ColorChoice::Never,
        help_template = help::TEMPLATE,
        long_about = clap::crate_description!(),
        name = env!("CARGO_PKG_NAME"),
        version = env!("CARGO_PKG_VERSION"),
    )]
    pub struct Cli {
        #[clap(
            default_missing_value = "-",
            default_value = "-",
            help = help::TRANSACTIONS,
            long_help = help::TRANSACTIONS,
            required = false
        )]
        pub transactions: String,
    }

    #[cfg(test)]
    mod tests {
        use crate::cli::*;
        use clap::error::ErrorKind::*;
        use clap::CommandFactory;

        #[test]
        fn debug_assert() {
            Cli::command().debug_assert();
        }

        #[test]
        fn no_args() {
            let res = Cli::command().try_get_matches_from(vec![env!("CARGO_PKG_NAME")]);
            assert!(res.is_ok());
        }

        #[test]
        fn unknown_flag() {
            let res = Cli::command().try_get_matches_from(vec![
                env!("CARGO_PKG_NAME"),
                "--unknown-flag",
                "test",
            ]);
            assert!(res.is_err());
            assert_eq!(res.unwrap_err().kind(), UnknownArgument);
        }
    }
}

pub mod input {
    use crate::models::Transaction;

    pub fn is_positional(input: &str) -> bool {
        input != "-"
    }

    pub fn is_stdin(input: &str) -> bool {
        !is_positional(input)
    }

    pub fn is_valid(input: &str) -> bool {
        is_stdin(input) && grep_cli::is_readable_stdin()
    }

    pub fn parse() -> anyhow::Result<Vec<Vec<Transaction>>> {
        use std::io::BufRead;

        let stdin = std::io::stdin();
        let mut input: Vec<Vec<Transaction>> = Vec::new();
        for line in stdin.lock().lines() {
            let l = line.map_err(|e| anyhow::anyhow!("[InputGetLineError] {e}"))?;
            let l_trimmed = l.trim();
            if !l_trimmed.is_empty() {
                let transactions: Vec<Transaction> = serde_json::from_str(&l)
                    .map_err(|e| anyhow::anyhow!("[SerdeToStringError] {e}"))?;
                input.push(transactions);
            }
        }
        Ok(input)
    }
}

// The Rust standard library suppresses the default SIGPIPE behavior, so that
// writing to a closed pipe doesn't kill the process.
//
// See:
// https://stackoverflow.com/questions/65755853/simple-word-count-rust-program-outputs-valid-stdout-but-panicks-when-piped-to-he
// https://github.com/BurntSushi/ripgrep/commit/3065a8c9c839f7e722a73e8375f2e41c7e084737
#[cfg(unix)]
fn reset_sigpipe() {
    unsafe {
        libc::signal(libc::SIGPIPE, libc::SIG_DFL);
    }
}

#[cfg(not(unix))]
fn reset_sigpipe() {}

fn main() -> anyhow::Result<()> {
    use crate::cli::Cli;
    use crate::finance::calculate_taxes;
    use crate::models::{Transaction, TransactionResult};
    use clap::{CommandFactory, Parser};
    use std::io::Write;

    reset_sigpipe();
    let args = Cli::parse();

    debug_assert_ne!(
        input::is_positional(&args.transactions),
        input::is_stdin(&args.transactions),
        "Can't have both positional inputs and stdin inputs"
    );

    if !input::is_valid(&args.transactions) {
        Cli::command()
            .print_help()
            .map_err(|e| anyhow::anyhow!("[WriteStdoutError] {e}"))?;
        std::process::exit(1);
    }

    let inputs: Vec<Vec<Transaction>> = input::parse()?;
    for i in inputs {
        let result: Vec<TransactionResult> = calculate_taxes(i);
        let json = serde_json::to_string(&result)
            .map_err(|e| anyhow::anyhow!("[SerdeToStringError] {e}"))?;
        writeln!(std::io::stdout(), "{}", json)
            .map_err(|e| anyhow::anyhow!("[WriteStdoutError] {e}"))?;
    }
    Ok(())
}

#[cfg(unix)]
#[cfg(test)]
mod tests_cmd {
    use assert_cmd::Command;
    use predicates::prelude::*;
    use std::path::Path;

    #[test]
    fn single_file() {
        Command::new("cargo")
            .args(["run"])
            .pipe_stdin(Path::new("src/data/input-1.json"))
            .unwrap()
            .assert()
            .stdout(
                predicate::path::eq_file(Path::new("src/data/expected-1.json"))
                    .utf8()
                    .unwrap(),
            );
    }

    #[test]
    fn multiple_files() {
        let inputs = Command::new("cat")
            .args([
                "src/data/input-1.json",
                "src/data/input-2.json",
                "src/data/input-3.json",
                "src/data/input-4.json",
                "src/data/input-5.json",
                "src/data/input-6.json",
                "src/data/input-7.json",
                "src/data/input-8.json",
            ])
            .output()
            .unwrap();

        Command::new("cargo")
            .args(["run"])
            .write_stdin(inputs.stdout)
            .assert()
            .stdout(
                predicate::path::eq_file(Path::new("src/data/cli-expected-all.jsonl"))
                    .utf8()
                    .unwrap(),
            );
    }
}
