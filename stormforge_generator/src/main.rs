use clap::{Parser, Subcommand};
use anyhow::Result;
use std::path::PathBuf;

mod ir;
mod generators;

use ir::IRParser;
use generators::RustGenerator;

#[derive(Parser)]
#[command(name = "stormforge-generator")]
#[command(about = "StormForge code generator for Rust microservices", long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Generate Rust microservice from IR file
    Generate {
        /// Input IR YAML file
        #[arg(short, long)]
        input: PathBuf,
        
        /// Output directory for generated code
        #[arg(short, long)]
        output: PathBuf,
        
        /// Specific bounded context to generate (optional)
        #[arg(short, long)]
        context: Option<String>,
    },
    
    /// Validate IR file without generating code
    Validate {
        /// Input IR YAML file
        #[arg(short, long)]
        input: PathBuf,
    },
}

fn main() -> Result<()> {
    let cli = Cli::parse();
    
    match cli.command {
        Commands::Generate { input, output, context: _ } => {
            println!("📄 Reading IR file: {}", input.display());
            
            // Parse IR file
            let model = IRParser::parse_file(&input)?;
            
            println!("✅ IR file parsed successfully");
            println!("   Bounded Context: {}", model.bounded_context.name);
            println!("   Namespace: {}", model.bounded_context.namespace);
            println!("   Aggregates: {}", model.aggregates.len());
            println!("   Commands: {}", model.commands.len());
            println!("   Events: {}", model.events.len());
            println!("   Queries: {}", model.queries.len());
            
            // Generate code
            let output_path = output.to_str().unwrap().to_string();
            let generator = RustGenerator::new(output_path);
            generator.generate(&model)?;
            
            println!("\n🎉 Generation complete!");
            println!("   Output: {}", output.display());
            println!("\n📝 Next steps:");
            println!("   cd {}", output.display());
            println!("   cargo build");
            println!("   cargo run");
        }
        
        Commands::Validate { input } => {
            println!("📄 Validating IR file: {}", input.display());
            
            // Parse and validate IR file
            let model = IRParser::parse_file(&input)?;
            
            println!("✅ IR file is valid");
            println!("   Bounded Context: {}", model.bounded_context.name);
            println!("   Version: {}", model.version);
        }
    }
    
    Ok(())
}
