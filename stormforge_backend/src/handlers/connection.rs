use axum::{
    extract::{Path, State},
    http::StatusCode,
    response::IntoResponse,
    Json,
};
use serde_json::json;

use crate::models::{Connection, CreateConnectionRequest, UpdateConnectionRequest};
use crate::services::ConnectionService;

/// Creates a new connection.
///
/// # Arguments
/// * `project_id` - The ID of the project
/// * `request` - The connection creation request
#[utoipa::path(
    post,
    path = "/api/projects/{project_id}/connections",
    request_body = CreateConnectionRequest,
    responses(
        (status = 201, description = "Connection created successfully", body = Connection),
        (status = 400, description = "Invalid request"),
        (status = 500, description = "Internal server error")
    ),
    tag = "connections"
)]
pub async fn create_connection(
    State(service): State<ConnectionService>,
    Path(project_id): Path<String>,
    Json(request): Json<CreateConnectionRequest>,
) -> impl IntoResponse {
    match service.create_connection(project_id, request).await {
        Ok(connection) => (StatusCode::CREATED, Json(connection)).into_response(),
        Err(e) => (
            StatusCode::BAD_REQUEST,
            Json(json!({ "error": e.to_string() })),
        )
            .into_response(),
    }
}

/// Gets a connection by ID.
///
/// # Arguments
/// * `project_id` - The ID of the project
/// * `connection_id` - The ID of the connection
#[utoipa::path(
    get,
    path = "/api/projects/{project_id}/connections/{connection_id}",
    responses(
        (status = 200, description = "Connection found", body = Connection),
        (status = 404, description = "Connection not found"),
        (status = 500, description = "Internal server error")
    ),
    tag = "connections"
)]
pub async fn get_connection(
    State(service): State<ConnectionService>,
    Path((_project_id, connection_id)): Path<(String, String)>,
) -> impl IntoResponse {
    match service.find_by_id(&connection_id).await {
        Ok(connection) => (StatusCode::OK, Json(connection)).into_response(),
        Err(e) => (
            StatusCode::NOT_FOUND,
            Json(json!({ "error": e.to_string() })),
        )
            .into_response(),
    }
}

/// Lists all connections for a project.
///
/// # Arguments
/// * `project_id` - The ID of the project
#[utoipa::path(
    get,
    path = "/api/projects/{project_id}/connections",
    responses(
        (status = 200, description = "Connections retrieved successfully", body = Vec<Connection>),
        (status = 500, description = "Internal server error")
    ),
    tag = "connections"
)]
pub async fn list_connections(
    State(service): State<ConnectionService>,
    Path(project_id): Path<String>,
) -> impl IntoResponse {
    match service.list_by_project(&project_id).await {
        Ok(connections) => (StatusCode::OK, Json(connections)).into_response(),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(json!({ "error": e.to_string() })),
        )
            .into_response(),
    }
}

/// Lists connections for a specific element.
///
/// # Arguments
/// * `project_id` - The ID of the project
/// * `element_id` - The ID of the element
#[utoipa::path(
    get,
    path = "/api/projects/{project_id}/elements/{element_id}/connections",
    responses(
        (status = 200, description = "Connections retrieved successfully", body = Vec<Connection>),
        (status = 500, description = "Internal server error")
    ),
    tag = "connections"
)]
pub async fn list_element_connections(
    State(service): State<ConnectionService>,
    Path((project_id, element_id)): Path<(String, String)>,
) -> impl IntoResponse {
    match service.list_by_element(&project_id, &element_id).await {
        Ok(connections) => (StatusCode::OK, Json(connections)).into_response(),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(json!({ "error": e.to_string() })),
        )
            .into_response(),
    }
}

/// Updates a connection.
///
/// # Arguments
/// * `project_id` - The ID of the project
/// * `connection_id` - The ID of the connection
/// * `request` - The connection update request
#[utoipa::path(
    put,
    path = "/api/projects/{project_id}/connections/{connection_id}",
    request_body = UpdateConnectionRequest,
    responses(
        (status = 200, description = "Connection updated successfully", body = Connection),
        (status = 404, description = "Connection not found"),
        (status = 500, description = "Internal server error")
    ),
    tag = "connections"
)]
pub async fn update_connection(
    State(service): State<ConnectionService>,
    Path((_project_id, connection_id)): Path<(String, String)>,
    Json(request): Json<UpdateConnectionRequest>,
) -> impl IntoResponse {
    match service.update_connection(&connection_id, request).await {
        Ok(connection) => (StatusCode::OK, Json(connection)).into_response(),
        Err(e) => (
            StatusCode::NOT_FOUND,
            Json(json!({ "error": e.to_string() })),
        )
            .into_response(),
    }
}

/// Deletes a connection.
///
/// # Arguments
/// * `project_id` - The ID of the project
/// * `connection_id` - The ID of the connection
#[utoipa::path(
    delete,
    path = "/api/projects/{project_id}/connections/{connection_id}",
    responses(
        (status = 204, description = "Connection deleted successfully"),
        (status = 404, description = "Connection not found"),
        (status = 500, description = "Internal server error")
    ),
    tag = "connections"
)]
pub async fn delete_connection(
    State(service): State<ConnectionService>,
    Path((_project_id, connection_id)): Path<(String, String)>,
) -> impl IntoResponse {
    match service.delete_connection(&connection_id).await {
        Ok(()) => StatusCode::NO_CONTENT.into_response(),
        Err(e) => (
            StatusCode::NOT_FOUND,
            Json(json!({ "error": e.to_string() })),
        )
            .into_response(),
    }
}
