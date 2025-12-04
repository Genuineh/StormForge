use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use utoipa::ToSchema;
use uuid::Uuid;

/// Join type for data sources
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, ToSchema, Default)]
#[serde(rename_all = "camelCase")]
pub enum JoinType {
    #[default]
    Inner,
    Left,
    Right,
}

/// Join operator for join conditions
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, ToSchema, Default)]
#[serde(rename_all = "camelCase")]
pub enum JoinOperator {
    #[default]
    Equals,
    NotEquals,
}

/// Join condition for multi-entity joins
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct JoinCondition {
    pub left_property: String,
    pub right_property: String,
    pub operator: JoinOperator,
}

impl JoinCondition {
    /// Creates a new join condition with the equals operator
    pub fn new(left_property: String, right_property: String) -> Self {
        Self {
            left_property,
            right_property,
            operator: JoinOperator::Equals,
        }
    }
}

/// Data source for read model
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct DataSource {
    pub entity_id: String,
    pub alias: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub join_condition: Option<JoinCondition>,
    pub join_type: JoinType,
    pub display_order: i32,
}

impl DataSource {
    /// Creates a new data source with default join type
    pub fn new(entity_id: String, alias: String) -> Self {
        Self {
            entity_id,
            alias,
            join_condition: None,
            join_type: JoinType::Inner,
            display_order: 0,
        }
    }
}

/// Field source type
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, ToSchema, Default)]
#[serde(rename_all = "camelCase")]
pub enum FieldSourceType {
    #[default]
    Direct,
    Computed,
    Aggregated,
}

/// Transform type for fields
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, ToSchema)]
#[serde(rename_all = "camelCase")]
pub enum TransformType {
    Rename,
    Format,
    Compute,
    Aggregate,
}

/// Field transform definition
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct FieldTransform {
    pub transform_type: TransformType,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub expression: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub parameters: Option<serde_json::Value>,
}

impl FieldTransform {
    /// Creates a new field transform with the specified type
    pub fn new(transform_type: TransformType) -> Self {
        Self {
            transform_type,
            expression: None,
            parameters: None,
        }
    }
}

/// Read model field definition
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct ReadModelField {
    pub id: String,
    pub name: String,
    pub field_type: String,
    pub source_type: FieldSourceType,
    pub source_path: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub transform: Option<FieldTransform>,
    pub nullable: bool,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub description: Option<String>,
    pub display_order: i32,
}

impl ReadModelField {
    /// Creates a new read model field with default source type
    pub fn new(name: String, field_type: String, source_path: String) -> Self {
        Self {
            id: Uuid::new_v4().to_string(),
            name,
            field_type,
            source_type: FieldSourceType::Direct,
            source_path,
            transform: None,
            nullable: false,
            description: None,
            display_order: 0,
        }
    }
}

/// Read model metadata
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema, Default)]
#[serde(rename_all = "camelCase")]
pub struct ReadModelMetadata {
    pub version: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub tags: Option<Vec<String>>,
}

impl ReadModelMetadata {
    /// Creates default metadata with version 1.0.0
    pub fn new() -> Self {
        Self {
            version: "1.0.0".to_string(),
            tags: None,
        }
    }
}

/// Read model definition
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct ReadModelDefinition {
    #[serde(rename = "_id")]
    pub id: String,
    pub project_id: String,
    pub name: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub description: Option<String>,
    pub sources: Vec<DataSource>,
    pub fields: Vec<ReadModelField>,
    pub updated_by_events: Vec<String>,
    pub metadata: ReadModelMetadata,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

impl ReadModelDefinition {
    /// Creates a new read model with default values
    pub fn new(project_id: String, name: String) -> Self {
        Self {
            id: Uuid::new_v4().to_string(),
            project_id,
            name,
            description: None,
            sources: Vec::new(),
            fields: Vec::new(),
            updated_by_events: Vec::new(),
            metadata: ReadModelMetadata::new(),
            created_at: Utc::now(),
            updated_at: Utc::now(),
        }
    }

    /// Validates if the read model is complete and valid
    pub fn is_valid(&self) -> bool {
        !self.name.is_empty()
            && !self.sources.is_empty()
            && !self.fields.is_empty()
            && !self.has_duplicate_field_names()
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

/// Request to create a read model
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct CreateReadModelRequest {
    pub project_id: String,
    pub name: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub description: Option<String>,
}

/// Request to update a read model
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct UpdateReadModelRequest {
    pub name: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub description: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub updated_by_events: Option<Vec<String>>,
}

/// Request to add a data source
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct DataSourceRequest {
    pub entity_id: String,
    pub alias: String,
    pub join_type: JoinType,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub join_condition: Option<JoinCondition>,
}

/// Request to add a field
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct FieldRequest {
    pub name: String,
    pub field_type: String,
    pub source_type: FieldSourceType,
    pub source_path: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub transform: Option<FieldTransform>,
    pub nullable: bool,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub description: Option<String>,
}
