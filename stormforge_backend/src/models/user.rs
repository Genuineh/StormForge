use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use utoipa::ToSchema;
use uuid::Uuid;

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, ToSchema)]
#[serde(rename_all = "lowercase")]
pub enum UserRole {
    Admin,
    Developer,
    Viewer,
}

impl Default for UserRole {
    fn default() -> Self {
        Self::Developer
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
    pub fn new(
        username: String,
        email: String,
        display_name: String,
        role: UserRole,
    ) -> Self {
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
