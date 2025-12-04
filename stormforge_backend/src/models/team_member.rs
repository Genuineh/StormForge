use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use utoipa::ToSchema;
use uuid::Uuid;

use super::Permission;

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, ToSchema, Default)]
#[serde(rename_all = "lowercase")]
pub enum TeamRole {
    Owner,
    Admin,
    #[default]
    Editor,
    Viewer,
}

impl TeamRole {
    pub fn default_permissions(&self) -> Vec<Permission> {
        match self {
            TeamRole::Owner => vec![
                Permission::ProjectEdit,
                Permission::ProjectDelete,
                Permission::ProjectView,
                Permission::ProjectExport,
                Permission::ModelEdit,
                Permission::ModelView,
                Permission::ModelExport,
                Permission::CodeGenerate,
                Permission::TeamManage,
            ],
            TeamRole::Admin => vec![
                Permission::ProjectEdit,
                Permission::ProjectView,
                Permission::ProjectExport,
                Permission::ModelEdit,
                Permission::ModelView,
                Permission::ModelExport,
                Permission::CodeGenerate,
                Permission::TeamManage,
            ],
            TeamRole::Editor => vec![
                Permission::ProjectView,
                Permission::ModelEdit,
                Permission::ModelView,
                Permission::CodeGenerate,
            ],
            TeamRole::Viewer => vec![Permission::ProjectView, Permission::ModelView],
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct TeamMember {
    pub id: String,
    pub project_id: String,
    pub user_id: String,
    pub role: TeamRole,
    pub permissions: Vec<Permission>,
    pub joined_at: DateTime<Utc>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub invited_by: Option<String>,
}

impl TeamMember {
    pub fn new(
        project_id: String,
        user_id: String,
        role: TeamRole,
        invited_by: Option<String>,
    ) -> Self {
        let permissions = role.default_permissions();
        Self {
            id: Uuid::new_v4().to_string(),
            project_id,
            user_id,
            role,
            permissions,
            joined_at: Utc::now(),
            invited_by,
        }
    }

    #[allow(dead_code)]
    pub fn has_permission(&self, permission: &Permission) -> bool {
        self.permissions.contains(permission)
    }

    #[allow(dead_code)]
    pub fn can_manage_team(&self) -> bool {
        self.has_permission(&Permission::TeamManage)
    }

    #[allow(dead_code)]
    pub fn can_edit_project(&self) -> bool {
        self.has_permission(&Permission::ProjectEdit)
    }

    #[allow(dead_code)]
    pub fn can_delete_project(&self) -> bool {
        matches!(self.role, TeamRole::Owner) && self.has_permission(&Permission::ProjectDelete)
    }
}

#[derive(Debug, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct AddTeamMemberRequest {
    pub user_id: String,
    #[serde(default)]
    pub role: TeamRole,
}

#[derive(Debug, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct UpdateTeamMemberRequest {
    pub role: Option<TeamRole>,
    #[allow(dead_code)]
    pub permissions: Option<Vec<Permission>>,
}
