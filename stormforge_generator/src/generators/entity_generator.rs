use crate::generators::utils::*;
use crate::ir::{Aggregate, IRModel, ValueObject};
use anyhow::Result;

pub struct EntityGenerator;

impl EntityGenerator {
    /// Generate Rust code for all entities in the model
    pub fn generate(model: &IRModel) -> Result<String> {
        let mut code = String::new();

        // Add imports
        code.push_str(&Self::generate_imports());
        code.push_str("\n\n");

        // Generate value objects first (as they may be used by entities)
        for (name, vo) in &model.value_objects {
            code.push_str(&Self::generate_value_object(name, vo)?);
            code.push_str("\n\n");
        }

        // Generate aggregate root entities
        for (name, aggregate) in &model.aggregates {
            code.push_str(&Self::generate_aggregate(name, aggregate)?);
            code.push_str("\n\n");
        }

        Ok(code)
    }

    fn generate_imports() -> String {
        r#"use serde::{Deserialize, Serialize};
use chrono::{DateTime, Utc, NaiveDate, NaiveTime};
use uuid::Uuid;
use rust_decimal::Decimal;

#[cfg(feature = "sqlx")]
use sqlx::FromRow;"#
            .to_string()
    }

    fn generate_value_object(name: &str, vo: &ValueObject) -> Result<String> {
        let mut code = String::new();

        // Add documentation
        if let Some(desc) = &vo.description {
            code.push_str(&format!("/// {}\n", desc));
        }

        // Check if it's an enum
        if vo.vo_type.as_deref() == Some("enum") {
            return Self::generate_enum(name, vo);
        }

        // Check if it's a simple identifier type
        if vo.vo_type.as_deref() == Some("identifier") {
            return Self::generate_identifier(name, vo);
        }

        // Generate complex value object (struct with properties)
        code.push_str("#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]\n");
        code.push_str(&format!("pub struct {} {{\n", name));

        for prop in &vo.properties {
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

        code.push_str("}");

        Ok(code)
    }

    fn generate_enum(name: &str, vo: &ValueObject) -> Result<String> {
        let mut code = String::new();

        code.push_str(
            "#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq, Hash)]\n",
        );
        code.push_str(&format!("pub enum {} {{\n", name));

        for value in &vo.values {
            if let Some(desc) = &value.description {
                code.push_str(&format!("    /// {}\n", desc));
            }
            code.push_str(&format!("    {},\n", to_pascal_case(&value.name)));
        }

        code.push_str("}");

        Ok(code)
    }

    fn generate_identifier(name: &str, vo: &ValueObject) -> Result<String> {
        let underlying = vo.underlying_type.as_deref().unwrap_or("String");
        let rust_type = to_rust_type(underlying);

        let mut code = String::new();
        code.push_str("#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq, Hash)]\n");
        code.push_str(&format!("pub struct {}(pub {});\n\n", name, rust_type));

        // Add From/Into implementations
        code.push_str(&format!("impl From<{}> for {} {{\n", rust_type, name));
        code.push_str(&format!("    fn from(value: {}) -> Self {{\n", rust_type));
        code.push_str("        Self(value)\n");
        code.push_str("    }\n");
        code.push_str("}\n\n");

        code.push_str(&format!("impl From<{}> for {} {{\n", name, rust_type));
        code.push_str(&format!("    fn from(id: {}) -> Self {{\n", name));
        code.push_str("        id.0\n");
        code.push_str("    }\n");
        code.push_str("}");

        Ok(code)
    }

    fn generate_aggregate(name: &str, aggregate: &Aggregate) -> Result<String> {
        let mut code = String::new();

        // Add documentation
        if let Some(desc) = &aggregate.description {
            code.push_str(&format!("/// {}\n", desc));
        }

        code.push_str("#[derive(Debug, Clone, Serialize, Deserialize)]\n");
        code.push_str("#[cfg_attr(feature = \"sqlx\", derive(FromRow))]\n");
        code.push_str(&format!("pub struct {} {{\n", name));

        for prop in &aggregate.root_entity.properties {
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

        code.push_str("}");

        Ok(code)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_generate_simple_enum() {
        let vo = ValueObject {
            name: "Status".to_string(),
            description: Some("Status enum".to_string()),
            vo_type: Some("enum".to_string()),
            underlying_type: None,
            format: None,
            prefix: None,
            properties: vec![],
            values: vec![crate::ir::EnumValue {
                name: "ACTIVE".to_string(),
                description: Some("Active status".to_string()),
            }],
        };

        let result = EntityGenerator::generate_value_object("Status", &vo);
        assert!(result.is_ok());
        let code = result.unwrap();
        assert!(code.contains("pub enum Status"));
        assert!(code.contains("Active"));
    }
}
