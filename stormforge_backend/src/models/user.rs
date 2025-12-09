use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use std::fmt;
use utoipa::ToSchema;
use uuid::Uuid;

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, ToSchema, Default)]
#[serde(rename_all = "lowercase")]
pub enum UserRole {
    Admin,
    #[default]
    Developer,
    Viewer,
}

impl fmt::Display for UserRole {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            UserRole::Admin => write!(f, "admin"),
            UserRole::Developer => write!(f, "developer"),
            UserRole::Viewer => write!(f, "viewer"),
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, ToSchema)]
#[serde(rename_all = "camelCase")]
pub enum Permission {
    ProjectCreate,
    ProjectEdit,
    ProjectDelete,
    ProjectView,
    ProjectExport,
    ModelEdit,
    ModelView,
    ModelExport,
    CodeGenerate,
    TeamManage,
    LibraryEdit,
    LibraryView,
}

impl UserRole {
    pub fn default_permissions(&self) -> Vec<Permission> {
        match self {
            UserRole::Admin => vec![
                Permission::ProjectCreate,
                Permission::ProjectEdit,
                Permission::ProjectDelete,
                Permission::ProjectView,
                Permission::ProjectExport,
                Permission::ModelEdit,
                Permission::ModelView,
                Permission::ModelExport,
                Permission::CodeGenerate,
                Permission::TeamManage,
                Permission::LibraryEdit,
                Permission::LibraryView,
            ],
            UserRole::Developer => vec![
                Permission::ProjectCreate,
                Permission::ProjectEdit,
                Permission::ProjectView,
                Permission::ProjectExport,
                Permission::ModelEdit,
                Permission::ModelView,
                Permission::ModelExport,
                Permission::CodeGenerate,
                Permission::LibraryView,
            ],
            UserRole::Viewer => vec![
                Permission::ProjectView,
                Permission::ModelView,
                Permission::LibraryView,
            ],
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct User {
    pub id: String,
    pub username: String,
    pub email: String,
    pub display_name: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub avatar_url: Option<String>,
    pub role: UserRole,
    pub permissions: Vec<Permission>,
    #[serde(skip_serializing)]
    pub password_hash: Option<String>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub last_login_at: Option<DateTime<Utc>>,
    pub is_active: bool,
}

impl User {
    pub fn new(username: String, email: String, display_name: String, role: UserRole) -> Self {
        let now = Utc::now();
        let permissions = role.default_permissions();
        Self {
            id: Uuid::new_v4().to_string(),
            username,
            email,
            display_name,
            avatar_url: None,
            role,
            permissions,
            password_hash: None,
            created_at: now,
            updated_at: now,
            last_login_at: None,
            is_active: true,
        }
    }

    #[allow(dead_code)]
    pub fn has_permission(&self, permission: &Permission) -> bool {
        self.permissions.contains(permission)
    }
}

#[derive(Debug, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct CreateUserRequest {
    pub username: String,
    pub email: String,
    pub display_name: String,
    pub password: String,
    #[serde(default)]
    pub role: UserRole,
}

#[derive(Debug, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct LoginRequest {
    pub username_or_email: String,
    pub password: String,
}

#[derive(Debug, Serialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct LoginResponse {
    pub token: String,
    pub user: User,
}

#[derive(Debug, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct UpdateUserRequest {
    pub display_name: Option<String>,
    pub avatar_url: Option<String>,
    pub email: Option<String>,
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_user_role_display() {
        assert_eq!(UserRole::Admin.to_string(), "admin");
        assert_eq!(UserRole::Developer.to_string(), "developer");
        assert_eq!(UserRole::Viewer.to_string(), "viewer");
    }

    #[test]
    fn test_user_role_default() {
        assert_eq!(UserRole::default(), UserRole::Developer);
    }

    #[test]
    fn test_admin_permissions() {
        let permissions = UserRole::Admin.default_permissions();
        assert_eq!(permissions.len(), 12);
        assert!(permissions.contains(&Permission::ProjectCreate));
        assert!(permissions.contains(&Permission::ProjectDelete));
        assert!(permissions.contains(&Permission::TeamManage));
    }

    #[test]
    fn test_developer_permissions() {
        let permissions = UserRole::Developer.default_permissions();
        assert_eq!(permissions.len(), 9);
        assert!(permissions.contains(&Permission::ProjectCreate));
        assert!(permissions.contains(&Permission::ModelEdit));
        assert!(!permissions.contains(&Permission::ProjectDelete));
        assert!(!permissions.contains(&Permission::TeamManage));
    }

    #[test]
    fn test_viewer_permissions() {
        let permissions = UserRole::Viewer.default_permissions();
        assert_eq!(permissions.len(), 3);
        assert!(permissions.contains(&Permission::ProjectView));
        assert!(permissions.contains(&Permission::ModelView));
        assert!(permissions.contains(&Permission::LibraryView));
        assert!(!permissions.contains(&Permission::ModelEdit));
    }

    #[test]
    fn test_user_new() {
        let user = User::new(
            "testuser".to_string(),
            "test@example.com".to_string(),
            "Test User".to_string(),
            UserRole::Developer,
        );

        assert!(!user.id.is_empty());
        assert_eq!(user.username, "testuser");
        assert_eq!(user.email, "test@example.com");
        assert_eq!(user.display_name, "Test User");
        assert_eq!(user.role, UserRole::Developer);
        assert!(user.is_active);
        assert_eq!(user.permissions.len(), 9);
        assert!(user.avatar_url.is_none());
        assert!(user.password_hash.is_none());
        assert!(user.last_login_at.is_none());
    }

    #[test]
    fn test_user_has_permission() {
        let user = User::new(
            "admin".to_string(),
            "admin@example.com".to_string(),
            "Admin User".to_string(),
            UserRole::Admin,
        );

        assert!(user.has_permission(&Permission::ProjectCreate));
        assert!(user.has_permission(&Permission::TeamManage));
        
        let viewer = User::new(
            "viewer".to_string(),
            "viewer@example.com".to_string(),
            "Viewer User".to_string(),
            UserRole::Viewer,
        );

        assert!(!viewer.has_permission(&Permission::ProjectCreate));
        assert!(viewer.has_permission(&Permission::ProjectView));
    }

    #[test]
    fn test_user_timestamps() {
        let before = Utc::now();
        let user = User::new(
            "testuser".to_string(),
            "test@example.com".to_string(),
            "Test User".to_string(),
            UserRole::Developer,
        );
        let after = Utc::now();

        assert!(user.created_at >= before && user.created_at <= after);
        assert!(user.updated_at >= before && user.updated_at <= after);
        assert_eq!(user.created_at, user.updated_at);
    }
}
