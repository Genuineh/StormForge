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

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_team_role_default() {
        assert_eq!(TeamRole::default(), TeamRole::Editor);
    }

    #[test]
    fn test_owner_permissions() {
        let permissions = TeamRole::Owner.default_permissions();
        assert_eq!(permissions.len(), 9);
        assert!(permissions.contains(&Permission::ProjectDelete));
        assert!(permissions.contains(&Permission::TeamManage));
    }

    #[test]
    fn test_admin_permissions() {
        let permissions = TeamRole::Admin.default_permissions();
        assert_eq!(permissions.len(), 8);
        assert!(permissions.contains(&Permission::TeamManage));
        assert!(!permissions.contains(&Permission::ProjectDelete));
    }

    #[test]
    fn test_editor_permissions() {
        let permissions = TeamRole::Editor.default_permissions();
        assert_eq!(permissions.len(), 4);
        assert!(permissions.contains(&Permission::ModelEdit));
        assert!(!permissions.contains(&Permission::TeamManage));
    }

    #[test]
    fn test_viewer_permissions() {
        let permissions = TeamRole::Viewer.default_permissions();
        assert_eq!(permissions.len(), 2);
        assert!(permissions.contains(&Permission::ProjectView));
        assert!(permissions.contains(&Permission::ModelView));
        assert!(!permissions.contains(&Permission::ModelEdit));
    }

    #[test]
    fn test_team_member_new() {
        let member = TeamMember::new(
            "project-123".to_string(),
            "user-456".to_string(),
            TeamRole::Editor,
            Some("owner-789".to_string()),
        );

        assert!(!member.id.is_empty());
        assert_eq!(member.project_id, "project-123");
        assert_eq!(member.user_id, "user-456");
        assert_eq!(member.role, TeamRole::Editor);
        assert_eq!(member.permissions.len(), 4);
        assert_eq!(member.invited_by.unwrap(), "owner-789");
    }

    #[test]
    fn test_has_permission() {
        let owner = TeamMember::new(
            "project-123".to_string(),
            "user-456".to_string(),
            TeamRole::Owner,
            None,
        );

        assert!(owner.has_permission(&Permission::ProjectDelete));
        assert!(owner.has_permission(&Permission::TeamManage));

        let editor = TeamMember::new(
            "project-123".to_string(),
            "user-789".to_string(),
            TeamRole::Editor,
            None,
        );

        assert!(!editor.has_permission(&Permission::ProjectDelete));
        assert!(editor.has_permission(&Permission::ModelEdit));
    }

    #[test]
    fn test_can_manage_team() {
        let owner = TeamMember::new(
            "project-123".to_string(),
            "user-1".to_string(),
            TeamRole::Owner,
            None,
        );
        assert!(owner.can_manage_team());

        let admin = TeamMember::new(
            "project-123".to_string(),
            "user-2".to_string(),
            TeamRole::Admin,
            None,
        );
        assert!(admin.can_manage_team());

        let editor = TeamMember::new(
            "project-123".to_string(),
            "user-3".to_string(),
            TeamRole::Editor,
            None,
        );
        assert!(!editor.can_manage_team());
    }

    #[test]
    fn test_can_edit_project() {
        let owner = TeamMember::new(
            "project-123".to_string(),
            "user-1".to_string(),
            TeamRole::Owner,
            None,
        );
        assert!(owner.can_edit_project());

        let viewer = TeamMember::new(
            "project-123".to_string(),
            "user-2".to_string(),
            TeamRole::Viewer,
            None,
        );
        assert!(!viewer.can_edit_project());
    }

    #[test]
    fn test_can_delete_project() {
        let owner = TeamMember::new(
            "project-123".to_string(),
            "user-1".to_string(),
            TeamRole::Owner,
            None,
        );
        assert!(owner.can_delete_project());

        let admin = TeamMember::new(
            "project-123".to_string(),
            "user-2".to_string(),
            TeamRole::Admin,
            None,
        );
        assert!(!admin.can_delete_project());
    }

    #[test]
    fn test_team_member_timestamps() {
        let before = Utc::now();
        let member = TeamMember::new(
            "project-123".to_string(),
            "user-456".to_string(),
            TeamRole::Editor,
            None,
        );
        let after = Utc::now();

        assert!(member.joined_at >= before && member.joined_at <= after);
    }
}
