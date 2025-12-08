use axum::{
    extract::{Path, Query, State},
    http::StatusCode,
    response::{IntoResponse, Response},
    Json,
};
use serde::Deserialize;
use std::sync::Arc;
use utoipa::IntoParams;

use crate::{
    models::{
        AddReferenceRequest, ComponentVersion, ImpactAnalysis, LibraryComponent, LibraryScope,
        PublishComponentRequest, UpdateVersionRequest,
    },
    services::LibraryService,
};

pub struct LibraryStateInner {
    pub library_service: LibraryService,
}

pub type LibraryState = Arc<LibraryStateInner>;

#[derive(Debug, Deserialize, IntoParams)]
pub struct SearchQuery {
    pub q: Option<String>,
    pub scope: Option<String>,
}

/// Publish a new component to the library
#[utoipa::path(
    post,
    path = "/api/library/components",
    request_body = PublishComponentRequest,
    responses(
        (status = 201, description = "Component published successfully", body = LibraryComponent),
        (status = 400, description = "Invalid request"),
        (status = 409, description = "Component with namespace already exists")
    ),
    tag = "Library"
)]
pub async fn publish_component(
    State(state): State<LibraryState>,
    Json(request): Json<PublishComponentRequest>,
) -> Response {
    match state.library_service.publish_component(request).await {
        Ok(component) => (StatusCode::CREATED, Json(component)).into_response(),
        Err(e) => {
            let msg = e.to_string();
            if msg.contains("already exists") {
                (
                    StatusCode::CONFLICT,
                    Json(serde_json::json!({ "error": msg })),
                )
                    .into_response()
            } else {
                (
                    StatusCode::BAD_REQUEST,
                    Json(serde_json::json!({ "error": msg })),
                )
                    .into_response()
            }
        }
    }
}

/// Get a component by ID
#[utoipa::path(
    get,
    path = "/api/library/components/{id}",
    params(
        ("id" = String, Path, description = "Component ID")
    ),
    responses(
        (status = 200, description = "Component found", body = LibraryComponent),
        (status = 404, description = "Component not found")
    ),
    tag = "Library"
)]
pub async fn get_component(
    State(state): State<LibraryState>,
    Path(id): Path<String>,
) -> Response {
    match state.library_service.find_by_id(&id).await {
        Ok(component) => (StatusCode::OK, Json(component)).into_response(),
        Err(_) => (
            StatusCode::NOT_FOUND,
            Json(serde_json::json!({ "error": "Component not found" })),
        )
            .into_response(),
    }
}

/// Search components
#[utoipa::path(
    get,
    path = "/api/library/components",
    params(SearchQuery),
    responses(
        (status = 200, description = "Components found", body = Vec<LibraryComponent>)
    ),
    tag = "Library"
)]
pub async fn search_components(
    State(state): State<LibraryState>,
    Query(query): Query<SearchQuery>,
) -> Response {
    let components = if let Some(scope_str) = &query.scope {
        let scope = match scope_str.as_str() {
            "enterprise" => LibraryScope::Enterprise,
            "organization" => LibraryScope::Organization,
            "project" => LibraryScope::Project,
            _ => {
                return (
                    StatusCode::BAD_REQUEST,
                    Json(serde_json::json!({
                        "error": "Invalid scope. Use: enterprise, organization, or project"
                    })),
                )
                    .into_response()
            }
        };
        state.library_service.list_by_scope(scope).await
    } else if let Some(search_query) = &query.q {
        state.library_service.search(search_query).await
    } else {
        state
            .library_service
            .list_by_scope(LibraryScope::Enterprise)
            .await
    };

    match components {
        Ok(list) => (StatusCode::OK, Json(list)).into_response(),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(serde_json::json!({ "error": e.to_string() })),
        )
            .into_response(),
    }
}

/// Update component version
#[utoipa::path(
    put,
    path = "/api/library/components/{id}/version",
    params(
        ("id" = String, Path, description = "Component ID")
    ),
    request_body = UpdateVersionRequest,
    responses(
        (status = 200, description = "Version updated successfully", body = LibraryComponent),
        (status = 404, description = "Component not found"),
        (status = 400, description = "Invalid version")
    ),
    tag = "Library"
)]
pub async fn update_component_version(
    State(state): State<LibraryState>,
    Path(id): Path<String>,
    Json(request): Json<UpdateVersionRequest>,
) -> Response {
    match state.library_service.update_version(&id, request).await {
        Ok(component) => (StatusCode::OK, Json(component)).into_response(),
        Err(e) => {
            let msg = e.to_string();
            if msg.contains("not found") {
                (
                    StatusCode::NOT_FOUND,
                    Json(serde_json::json!({ "error": msg })),
                )
                    .into_response()
            } else {
                (
                    StatusCode::BAD_REQUEST,
                    Json(serde_json::json!({ "error": msg })),
                )
                    .into_response()
            }
        }
    }
}

/// Delete a component
#[utoipa::path(
    delete,
    path = "/api/library/components/{id}",
    params(
        ("id" = String, Path, description = "Component ID")
    ),
    responses(
        (status = 204, description = "Component deleted successfully"),
        (status = 404, description = "Component not found"),
        (status = 409, description = "Component is in use")
    ),
    tag = "Library"
)]
pub async fn delete_component(
    State(state): State<LibraryState>,
    Path(id): Path<String>,
) -> Response {
    match state.library_service.delete_component(&id).await {
        Ok(_) => StatusCode::NO_CONTENT.into_response(),
        Err(e) => {
            let msg = e.to_string();
            if msg.contains("not found") {
                (
                    StatusCode::NOT_FOUND,
                    Json(serde_json::json!({ "error": msg })),
                )
                    .into_response()
            } else if msg.contains("being used") {
                (
                    StatusCode::CONFLICT,
                    Json(serde_json::json!({ "error": msg })),
                )
                    .into_response()
            } else {
                (
                    StatusCode::INTERNAL_SERVER_ERROR,
                    Json(serde_json::json!({ "error": msg })),
                )
                    .into_response()
            }
        }
    }
}

/// Get component versions
#[utoipa::path(
    get,
    path = "/api/library/components/{id}/versions",
    params(
        ("id" = String, Path, description = "Component ID")
    ),
    responses(
        (status = 200, description = "Versions found", body = Vec<ComponentVersion>),
        (status = 500, description = "Server error")
    ),
    tag = "Library"
)]
pub async fn get_component_versions(
    State(state): State<LibraryState>,
    Path(id): Path<String>,
) -> Response {
    match state.library_service.list_versions(&id).await {
        Ok(versions) => (StatusCode::OK, Json(versions)).into_response(),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(serde_json::json!({ "error": e.to_string() })),
        )
            .into_response(),
    }
}

/// Add component reference to project
#[utoipa::path(
    post,
    path = "/api/projects/{project_id}/library/references",
    params(
        ("project_id" = String, Path, description = "Project ID")
    ),
    request_body = AddReferenceRequest,
    responses(
        (status = 201, description = "Reference added successfully"),
        (status = 404, description = "Component not found"),
        (status = 409, description = "Reference already exists")
    ),
    tag = "Library"
)]
pub async fn add_component_reference(
    State(state): State<LibraryState>,
    Path(project_id): Path<String>,
    Json(request): Json<AddReferenceRequest>,
) -> Response {
    match state
        .library_service
        .add_reference(&project_id, request)
        .await
    {
        Ok(reference) => (StatusCode::CREATED, Json(reference)).into_response(),
        Err(e) => {
            let msg = e.to_string();
            if msg.contains("not found") {
                (
                    StatusCode::NOT_FOUND,
                    Json(serde_json::json!({ "error": msg })),
                )
                    .into_response()
            } else if msg.contains("already exists") {
                (
                    StatusCode::CONFLICT,
                    Json(serde_json::json!({ "error": msg })),
                )
                    .into_response()
            } else {
                (
                    StatusCode::BAD_REQUEST,
                    Json(serde_json::json!({ "error": msg })),
                )
                    .into_response()
            }
        }
    }
}

/// Remove component reference from project
#[utoipa::path(
    delete,
    path = "/api/projects/{project_id}/library/references/{component_id}",
    params(
        ("project_id" = String, Path, description = "Project ID"),
        ("component_id" = String, Path, description = "Component ID")
    ),
    responses(
        (status = 204, description = "Reference removed successfully"),
        (status = 500, description = "Server error")
    ),
    tag = "Library"
)]
pub async fn remove_component_reference(
    State(state): State<LibraryState>,
    Path((project_id, component_id)): Path<(String, String)>,
) -> Response {
    match state
        .library_service
        .remove_reference(&project_id, &component_id)
        .await
    {
        Ok(_) => StatusCode::NO_CONTENT.into_response(),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(serde_json::json!({ "error": e.to_string() })),
        )
            .into_response(),
    }
}

/// Get project component references
#[utoipa::path(
    get,
    path = "/api/projects/{project_id}/library/references",
    params(
        ("project_id" = String, Path, description = "Project ID")
    ),
    responses(
        (status = 200, description = "References found", body = Vec<crate::models::ComponentReference>)
    ),
    tag = "Library"
)]
pub async fn get_project_references(
    State(state): State<LibraryState>,
    Path(project_id): Path<String>,
) -> Response {
    match state
        .library_service
        .find_references_by_project(&project_id)
        .await
    {
        Ok(references) => (StatusCode::OK, Json(references)).into_response(),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(serde_json::json!({ "error": e.to_string() })),
        )
            .into_response(),
    }
}

/// Analyze impact of component changes
#[utoipa::path(
    get,
    path = "/api/library/components/{id}/impact",
    params(
        ("id" = String, Path, description = "Component ID")
    ),
    responses(
        (status = 200, description = "Impact analysis", body = ImpactAnalysis),
        (status = 500, description = "Server error")
    ),
    tag = "Library"
)]
pub async fn analyze_component_impact(
    State(state): State<LibraryState>,
    Path(id): Path<String>,
) -> Response {
    match state.library_service.analyze_impact(&id).await {
        Ok(analysis) => (StatusCode::OK, Json(analysis)).into_response(),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(serde_json::json!({ "error": e.to_string() })),
        )
            .into_response(),
    }
}
