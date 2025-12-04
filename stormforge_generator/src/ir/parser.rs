use super::types::IRModel;
use anyhow::{Context, Result};
use std::fs;
use std::path::Path;

/// IR Parser for loading and validating IR YAML files
pub struct IRParser;

impl IRParser {
    /// Parse an IR model from a YAML file
    pub fn parse_file<P: AsRef<Path>>(path: P) -> Result<IRModel> {
        let path = path.as_ref();
        let content = fs::read_to_string(path)
            .with_context(|| format!("Failed to read IR file: {}", path.display()))?;

        Self::parse_yaml(&content)
            .with_context(|| format!("Failed to parse IR file: {}", path.display()))
    }

    /// Parse an IR model from YAML string
    pub fn parse_yaml(yaml: &str) -> Result<IRModel> {
        let model: IRModel =
            serde_yaml::from_str(yaml).context("Failed to deserialize YAML to IR model")?;

        Self::validate(&model)?;

        Ok(model)
    }

    /// Validate the IR model
    fn validate(model: &IRModel) -> Result<()> {
        // Validate version format
        if !model.version.contains('.') {
            anyhow::bail!("Invalid version format: {}", model.version);
        }

        // Validate bounded context name
        if model.bounded_context.name.is_empty() {
            anyhow::bail!("Bounded context name cannot be empty");
        }

        // Validate namespace
        if model.bounded_context.namespace.is_empty() {
            anyhow::bail!("Bounded context namespace cannot be empty");
        }

        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse_simple_yaml() {
        let yaml = r#"
version: "1.0"
bounded_context:
  name: "Test"
  namespace: "test.context"
  description: "Test context"
"#;

        let result = IRParser::parse_yaml(yaml);
        assert!(result.is_ok());

        let model = result.unwrap();
        assert_eq!(model.version, "1.0");
        assert_eq!(model.bounded_context.name, "Test");
        assert_eq!(model.bounded_context.namespace, "test.context");
    }
}
