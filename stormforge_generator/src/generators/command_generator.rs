use crate::generators::utils::*;
use crate::ir::{Command, IRModel};
use anyhow::Result;

pub struct CommandGenerator;

impl CommandGenerator {
    /// Generate Rust code for all commands in the model
    pub fn generate(model: &IRModel) -> Result<String> {
        let mut code = String::new();

        // Add imports
        code.push_str(&Self::generate_imports());
        code.push_str("\n\n");

        // Generate command structs
        for (name, command) in &model.commands {
            code.push_str(&Self::generate_command(name, command)?);
            code.push_str("\n\n");
        }

        // Generate command handler trait
        code.push_str(&Self::generate_command_handler_trait(model)?);

        Ok(code)
    }

    fn generate_imports() -> String {
        r#"use serde::{Deserialize, Serialize};
use chrono::{DateTime, Utc};
use uuid::Uuid;
use rust_decimal::Decimal;
use async_trait::async_trait;
use crate::domain::entities::*;
use crate::domain::events::*;

pub type CommandResult<T> = Result<T, CommandError>;

#[derive(Debug, thiserror::Error)]
pub enum CommandError {
    #[error("Validation error: {0}")]
    ValidationError(String),
    
    #[error("Precondition failed: {0}")]
    PreconditionFailed(String),
    
    #[error("Aggregate not found: {0}")]
    AggregateNotFound(String),
    
    #[error("Internal error: {0}")]
    InternalError(String),
}"#
        .to_string()
    }

    fn generate_command(name: &str, command: &Command) -> Result<String> {
        let mut code = String::new();

        // Add documentation
        if let Some(desc) = &command.description {
            code.push_str(&format!("/// {}\n", desc));
        }

        code.push_str("#[derive(Debug, Clone, Serialize, Deserialize)]\n");
        code.push_str(&format!("pub struct {} {{\n", name));

        for prop in &command.payload {
            if let Some(desc) = &prop.description {
                code.push_str(&format!("    /// {}\n", desc));
            }

            let rust_type = to_rust_type(&prop.prop_type);
            let field_type = if !prop.required {
                format!("Option<{}>", rust_type)
            } else {
                rust_type
            };

            code.push_str(&format!(
                "    pub {}: {},\n",
                to_snake_case(&prop.name),
                field_type
            ));
        }

        code.push_str("}\n\n");

        // Generate command implementation with validation
        code.push_str(&format!("impl {} {{\n", name));
        code.push_str("    /// Validate the command\n");
        code.push_str("    pub fn validate(&self) -> CommandResult<()> {\n");

        // Add validation logic
        for validation in &command.validation {
            // Simple validation - in production this would be more sophisticated
            code.push_str(&format!("        // Validation: {}\n", validation.message));
        }

        code.push_str("        Ok(())\n");
        code.push_str("    }\n");
        code.push_str("}");

        Ok(code)
    }

    fn generate_command_handler_trait(model: &IRModel) -> Result<String> {
        let mut code = String::new();

        code.push_str("/// Command handler trait for processing commands\n");
        code.push_str("#[async_trait]\n");
        code.push_str("pub trait CommandHandler: Send + Sync {\n");

        for (name, command) in &model.commands {
            let handler_name = format!("handle_{}", to_snake_case(name));
            let events: Vec<String> = command.produces.iter().map(|e| e.clone()).collect();
            let event_types = if events.is_empty() {
                "Vec<DomainEvent>".to_string()
            } else {
                "Vec<DomainEvent>".to_string()
            };

            if let Some(desc) = &command.description {
                code.push_str(&format!("    /// {}\n", desc));
            }
            code.push_str(&format!(
                "    async fn {}(&self, command: {}) -> CommandResult<{}>;\n\n",
                handler_name, name, event_types
            ));
        }

        code.push_str("}");

        Ok(code)
    }
}
