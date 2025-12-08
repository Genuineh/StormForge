use serde::{Deserialize, Serialize};
use mongodb::bson::{DateTime as BsonDateTime, oid::ObjectId};
use utoipa::ToSchema;

/// Library component scope levels
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema, PartialEq, Eq)]
#[serde(rename_all = "lowercase")]
pub enum LibraryScope {
    #[serde(rename = "enterprise")]
    Enterprise,
    #[serde(rename = "organization")]
    Organization,
    #[serde(rename = "project")]
    Project,
}

/// Component types that can be stored in the library
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub enum ComponentType {
    Entity,
    ValueObject,
    EnumType,
    Aggregate,
    Command,
    Event,
    ReadModel,
    Policy,
    Interface,
}

/// Component status in the library
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema, PartialEq, Eq)]
#[serde(rename_all = "lowercase")]
pub enum ComponentStatus {
    Draft,
    Active,
    Deprecated,
    Archived,
}

/// Usage statistics for a component
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct UsageStats {
    pub project_count: i32,
    pub reference_count: i32,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub last_used: Option<BsonDateTime>,
}

impl Default for UsageStats {
    fn default() -> Self {
        Self {
            project_count: 0,
            reference_count: 0,
            last_used: None,
        }
    }
}

/// Library component - reusable domain component
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct LibraryComponent {
    #[serde(rename = "_id", skip_serializing_if = "Option::is_none")]
    pub id: Option<ObjectId>,
    pub name: String,
    pub namespace: String,
    pub scope: LibraryScope,
    #[serde(rename = "type")]
    pub component_type: ComponentType,
    pub version: String,
    pub description: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub author: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub organization_id: Option<String>,
    #[serde(default)]
    pub tags: Vec<String>,
    pub definition: serde_json::Value,
    #[serde(default)]
    pub metadata: serde_json::Value,
    pub status: ComponentStatus,
    pub usage_stats: UsageStats,
    pub created_at: BsonDateTime,
    pub updated_at: BsonDateTime,
}

/// Component version history entry
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct ComponentVersion {
    #[serde(rename = "_id", skip_serializing_if = "Option::is_none")]
    pub id: Option<ObjectId>,
    pub component_id: String,
    pub version: String,
    pub definition: serde_json::Value,
    pub change_notes: String,
    pub author: String,
    pub created_at: BsonDateTime,
}

/// Component reference mode
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema, PartialEq, Eq)]
#[serde(rename_all = "lowercase")]
pub enum ComponentReferenceMode {
    Reference,  // Use directly, updates sync
    Copy,       // Make local copy, no sync
    Inherit,    // Inherit and extend
}

/// Component reference - tracks component usage in projects
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct ComponentReference {
    #[serde(rename = "_id", skip_serializing_if = "Option::is_none")]
    pub id: Option<ObjectId>,
    pub project_id: String,
    pub component_id: String,
    pub version: String,
    pub mode: ComponentReferenceMode,
    pub added_at: BsonDateTime,
}

/// Request to publish a new component
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct PublishComponentRequest {
    pub name: String,
    pub namespace: String,
    pub scope: LibraryScope,
    #[serde(rename = "type")]
    pub component_type: ComponentType,
    pub version: String,
    pub description: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub author: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub organization_id: Option<String>,
    #[serde(default)]
    pub tags: Vec<String>,
    pub definition: serde_json::Value,
}

/// Request to update component version
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct UpdateVersionRequest {
    pub new_version: String,
    pub definition: serde_json::Value,
    pub change_notes: String,
    pub author: String,
}

/// Request to add a component reference to a project
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct AddReferenceRequest {
    pub component_id: String,
    pub mode: ComponentReferenceMode,
}

/// Project impact information for impact analysis
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct ProjectImpact {
    pub project_id: String,
    pub project_name: String,
    pub current_version: String,
    pub reference_mode: ComponentReferenceMode,
}

/// Impact analysis result
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct ImpactAnalysis {
    pub component_id: String,
    pub affected_projects: Vec<ProjectImpact>,
    pub total_references: i32,
}
