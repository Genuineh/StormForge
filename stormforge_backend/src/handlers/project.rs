use axum::{
    extract::{Path, State},
    http::StatusCode,
    Json,
};
use serde_json::{json, Value};

use crate::{
    handlers::AppState,
    models::{CreateProjectRequest, Project, UpdateProjectRequest},
    services::ProjectService,
};

pub type ProjectState = std::sync::Arc<ProjectStateInner>;

pub struct ProjectStateInner {
    pub project_service: ProjectService,
}

/// Create a new project
#[utoipa::path(
    post,
    path = "/api/projects",
    request_body = CreateProjectRequest,
    responses(
        (status = 201, description = "Project created", body = Project),
        (status = 400, description = "Invalid request"),
        (status = 409, description = "Namespace already exists")
    ),
    tag = "projects"
)]
pub async fn create_project(
    State(state): State<ProjectState>,
    Json(payload): Json<CreateProjectRequest>,
) -> Result<(StatusCode, Json<Project>), (StatusCode, Json<Value>)> {
    // TODO: SECURITY - Implement authentication middleware to extract owner_id from JWT token
    // This placeholder creates a security vulnerability - any user can create projects for any owner
    // Solution: Add JWT verification middleware that extracts user_id from token claims
    let owner_id = "placeholder_owner_id".to_string();

    let project = state.project_service
        .create_project(
            payload.name,
            payload.namespace,
            payload.description,
            owner_id,
            payload.visibility,
        )
        .await
        .map_err(|e| {
            (
                StatusCode::CONFLICT,
                Json(json!({ "error": e.to_string() })),
            )
        })?;

    Ok((StatusCode::CREATED, Json(project)))
}

/// Get project by ID
#[utoipa::path(
    get,
    path = "/api/projects/{id}",
    params(
        ("id" = String, Path, description = "Project ID")
    ),
    responses(
        (status = 200, description = "Project found", body = Project),
        (status = 404, description = "Project not found")
    ),
    tag = "projects"
)]
pub async fn get_project(
    State(state): State<ProjectState>,
    Path(id): Path<String>,
) -> Result<Json<Project>, (StatusCode, Json<Value>)> {
    let project = state.project_service
        .find_by_id(&id)
        .await
        .map_err(|e| {
            (
                StatusCode::NOT_FOUND,
                Json(json!({ "error": e.to_string() })),
            )
        })?;

    Ok(Json(project))
}

/// List projects by owner
#[utoipa::path(
    get,
    path = "/api/projects/owner/{owner_id}",
    params(
        ("owner_id" = String, Path, description = "Owner ID")
    ),
    responses(
        (status = 200, description = "List of projects", body = Vec<Project>)
    ),
    tag = "projects"
)]
pub async fn list_projects_by_owner(
    State(state): State<ProjectState>,
    Path(owner_id): Path<String>,
) -> Result<Json<Vec<Project>>, (StatusCode, Json<Value>)> {
    let projects = state.project_service
        .list_by_owner(&owner_id)
        .await
        .map_err(|e| {
            (
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(json!({ "error": e.to_string() })),
            )
        })?;

    Ok(Json(projects))
}

/// Update project
#[utoipa::path(
    put,
    path = "/api/projects/{id}",
    params(
        ("id" = String, Path, description = "Project ID")
    ),
    request_body = UpdateProjectRequest,
    responses(
        (status = 200, description = "Project updated", body = Project),
        (status = 404, description = "Project not found")
    ),
    tag = "projects"
)]
pub async fn update_project(
    State(state): State<ProjectState>,
    Path(id): Path<String>,
    Json(payload): Json<UpdateProjectRequest>,
) -> Result<Json<Project>, (StatusCode, Json<Value>)> {
    let project = state.project_service
        .update_project(
            &id,
            payload.name,
            payload.description,
            payload.visibility,
            payload.settings,
        )
        .await
        .map_err(|e| {
            (
                StatusCode::BAD_REQUEST,
                Json(json!({ "error": e.to_string() })),
            )
        })?;

    Ok(Json(project))
}

/// Delete project
#[utoipa::path(
    delete,
    path = "/api/projects/{id}",
    params(
        ("id" = String, Path, description = "Project ID")
    ),
    responses(
        (status = 204, description = "Project deleted"),
        (status = 404, description = "Project not found")
    ),
    tag = "projects"
)]
pub async fn delete_project(
    State(state): State<ProjectState>,
    Path(id): Path<String>,
) -> Result<StatusCode, (StatusCode, Json<Value>)> {
    state.project_service
        .delete_project(&id)
        .await
        .map_err(|e| {
            (
                StatusCode::NOT_FOUND,
                Json(json!({ "error": e.to_string() })),
            )
        })?;

    Ok(StatusCode::NO_CONTENT)
}
