use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use utoipa::ToSchema;
use uuid::Uuid;

/// Source of a command field
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, ToSchema)]
#[serde(rename_all = "camelCase")]
pub enum FieldSource {
    /// Field comes from UI input
    UiInput,
    /// Field comes from a read model
    ReadModel { read_model_id: String, field_path: String },
    /// Field comes from an entity
    Entity { entity_id: String, field_path: String },
    /// Field is computed from other fields
    Computed { expression: String },
    /// Custom DTO field
    Custom,
}

impl Default for FieldSource {
    fn default() -> Self {
        FieldSource::UiInput
    }
}

/// Validation operator
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, ToSchema)]
#[serde(rename_all = "camelCase")]
pub enum ValidationOperator {
    Equals,
    NotEquals,
    GreaterThan,
    LessThan,
    GreaterThanOrEqual,
    LessThanOrEqual,
    In,
    NotIn,
    Matches,
    MinLength,
    MaxLength,
    Range,
}

/// Validation rule for command fields
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct CommandValidationRule {
    pub field_name: String,
    pub operator: ValidationOperator,
    pub value: serde_json::Value,
    pub error_message: String,
}

impl CommandValidationRule {
    /// Creates a new validation rule
    pub fn new(field_name: String, operator: ValidationOperator, value: serde_json::Value, error_message: String) -> Self {
        Self {
            field_name,
            operator,
            value,
            error_message,
        }
    }
}

/// Precondition operator
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, ToSchema)]
#[serde(rename_all = "camelCase")]
pub enum PreconditionOperator {
    Equals,
    NotEquals,
    GreaterThan,
    LessThan,
    Exists,
    NotExists,
    Custom,
}

/// Precondition for command execution
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct Precondition {
    pub description: String,
    pub expression: String,
    pub operator: PreconditionOperator,
    pub error_message: String,
}

impl Precondition {
    /// Creates a new precondition
    pub fn new(description: String, expression: String, operator: PreconditionOperator, error_message: String) -> Self {
        Self {
            description,
            expression,
            operator,
            error_message,
        }
    }
}

/// Command field definition
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct CommandField {
    pub id: String,
    pub name: String,
    pub field_type: String,
    pub required: bool,
    pub source: FieldSource,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub default_value: Option<serde_json::Value>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub description: Option<String>,
    pub validations: Vec<CommandValidationRule>,
    pub display_order: i32,
}

impl CommandField {
    /// Creates a new command field with default source
    pub fn new(name: String, field_type: String, required: bool) -> Self {
        Self {
            id: Uuid::new_v4().to_string(),
            name,
            field_type,
            required,
            source: FieldSource::UiInput,
            default_value: None,
            description: None,
            validations: Vec::new(),
            display_order: 0,
        }
    }
}

/// Command payload definition
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema, Default)]
#[serde(rename_all = "camelCase")]
pub struct CommandPayload {
    pub fields: Vec<CommandField>,
}

impl CommandPayload {
    /// Creates an empty command payload
    pub fn new() -> Self {
        Self {
            fields: Vec::new(),
        }
    }

    /// Checks if there are duplicate field names
    pub fn has_duplicate_field_names(&self) -> bool {
        let mut names = std::collections::HashSet::new();
        for field in &self.fields {
            if !names.insert(&field.name) {
                return true;
            }
        }
        false
    }
}

/// Command metadata
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema, Default)]
#[serde(rename_all = "camelCase")]
pub struct CommandMetadata {
    pub version: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub tags: Option<Vec<String>>,
}

impl CommandMetadata {
    /// Creates default metadata with version 1.0.0
    pub fn new() -> Self {
        Self {
            version: "1.0.0".to_string(),
            tags: None,
        }
    }
}

/// Command definition
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct CommandDefinition {
    #[serde(rename = "_id")]
    pub id: String,
    pub project_id: String,
    pub name: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub description: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub aggregate_id: Option<String>,
    pub payload: CommandPayload,
    pub validations: Vec<CommandValidationRule>,
    pub preconditions: Vec<Precondition>,
    pub produced_events: Vec<String>,
    pub metadata: CommandMetadata,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

impl CommandDefinition {
    /// Creates a new command with default values
    pub fn new(project_id: String, name: String) -> Self {
        Self {
            id: Uuid::new_v4().to_string(),
            project_id,
            name,
            description: None,
            aggregate_id: None,
            payload: CommandPayload::new(),
            validations: Vec::new(),
            preconditions: Vec::new(),
            produced_events: Vec::new(),
            metadata: CommandMetadata::new(),
            created_at: Utc::now(),
            updated_at: Utc::now(),
        }
    }

    /// Validates if the command is complete and valid
    pub fn is_valid(&self) -> bool {
        !self.name.is_empty()
            && !self.payload.has_duplicate_field_names()
    }
}

/// Request to create a command
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct CreateCommandRequest {
    pub project_id: String,
    pub name: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub description: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub aggregate_id: Option<String>,
}

/// Request to update a command
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct UpdateCommandRequest {
    pub name: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub description: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub aggregate_id: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub produced_events: Option<Vec<String>>,
}

/// Request to add a field to command payload
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct CommandFieldRequest {
    pub name: String,
    pub field_type: String,
    pub required: bool,
    pub source: FieldSource,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub default_value: Option<serde_json::Value>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub description: Option<String>,
}

/// Request to add a validation rule
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct CommandValidationRuleRequest {
    pub field_name: String,
    pub operator: ValidationOperator,
    pub value: serde_json::Value,
    pub error_message: String,
}

/// Request to add a precondition
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct PreconditionRequest {
    pub description: String,
    pub expression: String,
    pub operator: PreconditionOperator,
    pub error_message: String,
}
