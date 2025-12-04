use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use utoipa::ToSchema;
use uuid::Uuid;

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, ToSchema)]
#[serde(rename_all = "lowercase")]
pub enum ProjectVisibility {
    Private,
    Team,
    Public,
}

impl Default for ProjectVisibility {
    fn default() -> Self {
        Self::Private
    }
}

#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct GitSettings {
    pub enabled: bool,
    pub auto_commit: bool,
    pub commit_message: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub repository_url: Option<String>,
    pub branch: String,
}

impl Default for GitSettings {
    fn default() -> Self {
        Self {
            enabled: false,
            auto_commit: false,
            commit_message: "Auto-commit: Model updated".to_string(),
            repository_url: None,
            branch: "main".to_string(),
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct AiSettings {
    pub enabled: bool,
    pub provider: String,
    pub model: String,
    pub temperature: f32,
}

impl Default for AiSettings {
    fn default() -> Self {
        Self {
            enabled: false,
            provider: "claude".to_string(),
            model: "claude-3-5-sonnet-20241022".to_string(),
            temperature: 0.7,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize, ToSchema, Default)]
#[serde(rename_all = "camelCase")]
pub struct ProjectSettings {
    pub git_integration: GitSettings,
    pub ai_settings: AiSettings,
}

#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct Project {
    pub id: String,
    pub name: String,
    pub namespace: String,
    pub description: String,
    pub owner_id: String,
    pub visibility: ProjectVisibility,
    pub settings: ProjectSettings,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

impl Project {
    pub fn new(
        name: String,
        namespace: String,
        description: String,
        owner_id: String,
        visibility: ProjectVisibility,
    ) -> Self {
        let now = Utc::now();
        Self {
            id: Uuid::new_v4().to_string(),
            name,
            namespace,
            description,
            owner_id,
            visibility,
            settings: ProjectSettings::default(),
            created_at: now,
            updated_at: now,
        }
    }
}

#[derive(Debug, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct CreateProjectRequest {
    pub name: String,
    pub namespace: String,
    pub description: String,
    #[serde(default)]
    pub visibility: ProjectVisibility,
}

#[derive(Debug, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct UpdateProjectRequest {
    pub name: Option<String>,
    pub description: Option<String>,
    pub visibility: Option<ProjectVisibility>,
    pub settings: Option<ProjectSettings>,
}
