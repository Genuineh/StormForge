use crate::ir::{IRModel, Event};
use crate::generators::utils::*;
use anyhow::Result;

pub struct EventGenerator;

impl EventGenerator {
    /// Generate Rust code for all events in the model
    pub fn generate(model: &IRModel) -> Result<String> {
        let mut code = String::new();
        
        // Add imports
        code.push_str(&Self::generate_imports());
        code.push_str("\n\n");
        
        // Generate base event envelope
        code.push_str(&Self::generate_domain_event_enum(model)?);
        code.push_str("\n\n");
        
        // Generate individual event structs
        for (name, event) in &model.events {
            code.push_str(&Self::generate_event(name, event)?);
            code.push_str("\n\n");
        }
        
        // Generate event metadata
        code.push_str(&Self::generate_event_metadata());
        
        Ok(code)
    }
    
    fn generate_imports() -> String {
        r#"use serde::{Deserialize, Serialize};
use chrono::{DateTime, Utc};
use uuid::Uuid;
use rust_decimal::Decimal;
use crate::domain::entities::*;"#.to_string()
    }
    
    fn generate_domain_event_enum(model: &IRModel) -> Result<String> {
        let mut code = String::new();
        
        code.push_str("/// Domain event enum containing all events in this bounded context\n");
        code.push_str("#[derive(Debug, Clone, Serialize, Deserialize)]\n");
        code.push_str("#[serde(tag = \"type\")]\n");
        code.push_str("pub enum DomainEvent {\n");
        
        for (name, _) in &model.events {
            code.push_str(&format!("    {}({}),\n", name, name));
        }
        
        code.push_str("}");
        
        Ok(code)
    }
    
    fn generate_event(name: &str, event: &Event) -> Result<String> {
        let mut code = String::new();
        
        // Add documentation
        if let Some(desc) = &event.description {
            code.push_str(&format!("/// {}\n", desc));
        }
        
        code.push_str("#[derive(Debug, Clone, Serialize, Deserialize)]\n");
        code.push_str(&format!("pub struct {} {{\n", name));
        
        // Add event metadata fields
        code.push_str("    /// Unique event identifier\n");
        code.push_str("    pub event_id: Uuid,\n");
        code.push_str("    /// Timestamp when the event occurred\n");
        code.push_str("    pub occurred_at: DateTime<Utc>,\n");
        
        // Add aggregate ID if specified
        if event.aggregate.is_some() {
            code.push_str("    /// ID of the aggregate that produced this event\n");
            code.push_str("    pub aggregate_id: String,\n");
        }
        
        // Add event payload fields
        for prop in &event.payload {
            if let Some(desc) = &prop.description {
                code.push_str(&format!("    /// {}\n", desc));
            }
            
            let rust_type = to_rust_type(&prop.prop_type);
            let field_type = if !prop.required {
                format!("Option<{}>", rust_type)
            } else {
                rust_type
            };
            
            code.push_str(&format!("    pub {}: {},\n", to_snake_case(&prop.name), field_type));
        }
        
        code.push_str("}\n\n");
        
        // Generate constructor
        code.push_str(&format!("impl {} {{\n", name));
        code.push_str("    /// Create a new event instance\n");
        
        let params: Vec<String> = event.payload.iter()
            .map(|p| {
                let rust_type = to_rust_type(&p.prop_type);
                let param_type = if !p.required {
                    format!("Option<{}>", rust_type)
                } else {
                    rust_type
                };
                format!("{}: {}", to_snake_case(&p.name), param_type)
            })
            .collect();
        
        let aggregate_param = if event.aggregate.is_some() {
            "aggregate_id: String, "
        } else {
            ""
        };
        
        let params_str = if params.is_empty() {
            String::new()
        } else if aggregate_param.is_empty() {
            params.join(", ")
        } else {
            format!("{}", params.join(", "))
        };
        
        code.push_str(&format!("    pub fn new({}{}) -> Self {{\n", aggregate_param, params_str));
        code.push_str("        Self {\n");
        code.push_str("            event_id: Uuid::new_v4(),\n");
        code.push_str("            occurred_at: Utc::now(),\n");
        
        if event.aggregate.is_some() {
            code.push_str("            aggregate_id,\n");
        }
        
        for prop in &event.payload {
            code.push_str(&format!("            {},\n", to_snake_case(&prop.name)));
        }
        
        code.push_str("        }\n");
        code.push_str("    }\n");
        code.push_str("}");
        
        Ok(code)
    }
    
    fn generate_event_metadata() -> String {
        r#"/// Event store metadata
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EventMetadata {
    pub event_id: Uuid,
    pub event_type: String,
    pub aggregate_id: String,
    pub aggregate_type: String,
    pub sequence_number: i64,
    pub occurred_at: DateTime<Utc>,
    pub stored_at: DateTime<Utc>,
    pub correlation_id: Option<Uuid>,
    pub causation_id: Option<Uuid>,
}"#.to_string()
    }
}
