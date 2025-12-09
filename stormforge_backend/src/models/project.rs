use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use utoipa::ToSchema;
use uuid::Uuid;

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, ToSchema, Default)]
#[serde(rename_all = "lowercase")]
pub enum ProjectVisibility {
    #[default]
    Private,
    Team,
    Public,
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

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_project_visibility_default() {
        assert_eq!(ProjectVisibility::default(), ProjectVisibility::Private);
    }

    #[test]
    fn test_git_settings_default() {
        let settings = GitSettings::default();
        assert!(!settings.enabled);
        assert!(!settings.auto_commit);
        assert_eq!(settings.commit_message, "Auto-commit: Model updated");
        assert!(settings.repository_url.is_none());
        assert_eq!(settings.branch, "main");
    }

    #[test]
    fn test_ai_settings_default() {
        let settings = AiSettings::default();
        assert!(!settings.enabled);
        assert_eq!(settings.provider, "claude");
        assert_eq!(settings.model, "claude-3-5-sonnet-20241022");
        assert_eq!(settings.temperature, 0.7);
    }

    #[test]
    fn test_project_settings_default() {
        let settings = ProjectSettings::default();
        assert!(!settings.git_integration.enabled);
        assert!(!settings.ai_settings.enabled);
    }

    #[test]
    fn test_project_new() {
        let project = Project::new(
            "Test Project".to_string(),
            "com.example.test".to_string(),
            "A test project".to_string(),
            "owner-123".to_string(),
            ProjectVisibility::Private,
        );

        assert!(!project.id.is_empty());
        assert_eq!(project.name, "Test Project");
        assert_eq!(project.namespace, "com.example.test");
        assert_eq!(project.description, "A test project");
        assert_eq!(project.owner_id, "owner-123");
        assert_eq!(project.visibility, ProjectVisibility::Private);
        assert!(!project.settings.git_integration.enabled);
        assert!(!project.settings.ai_settings.enabled);
    }

    #[test]
    fn test_project_timestamps() {
        let before = Utc::now();
        let project = Project::new(
            "Test Project".to_string(),
            "com.example.test".to_string(),
            "A test project".to_string(),
            "owner-123".to_string(),
            ProjectVisibility::Team,
        );
        let after = Utc::now();

        assert!(project.created_at >= before && project.created_at <= after);
        assert!(project.updated_at >= before && project.updated_at <= after);
        assert_eq!(project.created_at, project.updated_at);
    }

    #[test]
    fn test_project_with_all_visibility_types() {
        let private_project = Project::new(
            "Private".to_string(),
            "com.example.private".to_string(),
            "Private project".to_string(),
            "owner-1".to_string(),
            ProjectVisibility::Private,
        );
        assert_eq!(private_project.visibility, ProjectVisibility::Private);

        let team_project = Project::new(
            "Team".to_string(),
            "com.example.team".to_string(),
            "Team project".to_string(),
            "owner-2".to_string(),
            ProjectVisibility::Team,
        );
        assert_eq!(team_project.visibility, ProjectVisibility::Team);

        let public_project = Project::new(
            "Public".to_string(),
            "com.example.public".to_string(),
            "Public project".to_string(),
            "owner-3".to_string(),
            ProjectVisibility::Public,
        );
        assert_eq!(public_project.visibility, ProjectVisibility::Public);
    }
}
