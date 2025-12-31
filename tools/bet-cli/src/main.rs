// SPDX-License-Identifier: MIT OR Apache-2.0
//! Betlang Command-Line Interface
//!
//! Usage:
//!   bet repl          - Start interactive REPL
//!   bet run <file>    - Run a betlang file
//!   bet check <file>  - Type-check a file
//!   bet fmt <file>    - Format a file
//!   bet parse <file>  - Parse and print AST

use clap::{Parser, Subcommand};
use miette::{IntoDiagnostic, Result};
use std::path::PathBuf;

mod repl;

#[derive(Parser)]
#[command(name = "bet")]
#[command(author = "Betlang Team")]
#[command(version)]
#[command(about = "Betlang - A ternary probabilistic programming language", long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Option<Commands>,
}

#[derive(Subcommand)]
enum Commands {
    /// Start interactive REPL
    Repl,

    /// Run a betlang file
    Run {
        /// The file to run
        file: PathBuf,
    },

    /// Parse a file and print AST
    Parse {
        /// The file to parse
        file: PathBuf,

        /// Print as JSON
        #[arg(long)]
        json: bool,
    },

    /// Type-check a file
    Check {
        /// The file to check
        file: PathBuf,
    },

    /// Format a file
    Fmt {
        /// The file to format
        file: PathBuf,

        /// Write output to file (instead of stdout)
        #[arg(short, long)]
        write: bool,
    },

    /// Show version information
    Version,
}

fn main() -> Result<()> {
    // Initialize tracing
    tracing_subscriber::fmt()
        .with_env_filter(
            tracing_subscriber::EnvFilter::from_default_env()
                .add_directive(tracing::Level::WARN.into()),
        )
        .init();

    let cli = Cli::parse();

    match cli.command {
        Some(Commands::Repl) | None => {
            repl::run_repl()
        }
        Some(Commands::Run { file }) => {
            run_file(&file)
        }
        Some(Commands::Parse { file, json }) => {
            parse_file(&file, json)
        }
        Some(Commands::Check { file }) => {
            check_file(&file)
        }
        Some(Commands::Fmt { file, write }) => {
            format_file(&file, write)
        }
        Some(Commands::Version) => {
            print_version();
            Ok(())
        }
    }
}

fn run_file(path: &PathBuf) -> Result<()> {
    let source = std::fs::read_to_string(path).into_diagnostic()?;

    let module = bet_parse::parse(&source).map_err(|e| miette::miette!("{}", e))?;

    // TODO: Type check
    // TODO: Evaluate

    println!("Parsed {} items", module.items.len());
    println!("(Evaluation not yet implemented)");

    Ok(())
}

fn parse_file(path: &PathBuf, json: bool) -> Result<()> {
    let source = std::fs::read_to_string(path).into_diagnostic()?;

    let module = bet_parse::parse(&source).map_err(|e| miette::miette!("{}", e))?;

    if json {
        // TODO: serde serialization
        println!("{{\"items\": {}}}", module.items.len());
    } else {
        println!("{:#?}", module);
    }

    Ok(())
}

fn check_file(path: &PathBuf) -> Result<()> {
    let source = std::fs::read_to_string(path).into_diagnostic()?;

    let _module = bet_parse::parse(&source).map_err(|e| miette::miette!("{}", e))?;

    // TODO: Type checking
    println!("Type checking not yet implemented");

    Ok(())
}

fn format_file(path: &PathBuf, write: bool) -> Result<()> {
    let source = std::fs::read_to_string(path).into_diagnostic()?;

    let _module = bet_parse::parse(&source).map_err(|e| miette::miette!("{}", e))?;

    // TODO: Pretty printing
    let formatted = source.clone(); // placeholder

    if write {
        std::fs::write(path, &formatted).into_diagnostic()?;
        println!("Formatted {}", path.display());
    } else {
        print!("{}", formatted);
    }

    Ok(())
}

fn print_version() {
    println!("bet {}", env!("CARGO_PKG_VERSION"));
    println!("Betlang - A ternary probabilistic programming language");
    println!();
    println!("Features:");
    println!("  - Ternary bet primitive: bet {{ a, b, c }}");
    println!("  - First-class distributions: Dist τ");
    println!("  - Monadic do-notation for probabilistic programming");
    println!("  - Ternary logic: true, false, unknown");
}
