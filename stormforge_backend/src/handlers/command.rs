use axum::{
    extract::{Path, State},
    http::StatusCode,
    response::IntoResponse,
    Json,
};
use serde_json::json;

use crate::{
    middleware::auth::AuthUser,
    models::{
        CommandFieldRequest, CreateCommandRequest, PreconditionRequest,
        UpdateCommandRequest, CommandValidationRuleRequest,
    },
    services::CommandService,
};

pub type _CommandStateInner = CommandService;

/// Create a new command
#[utoipa::path(
    post,
    path = "/api/commands",
    tag = "commands",
    request_body = CreateCommandRequest,
    responses(
        (status = 201, description = "Command created successfully", body = CommandDefinition),
        (status = 400, description = "Invalid request"),
        (status = 409, description = "Command already exists")
    )
)]
pub async fn create_command(
    _auth: AuthUser,
    State(service): State<CommandService>,
    Json(request): Json<CreateCommandRequest>,
) -> impl IntoResponse {
    match service.create_command(request).await {
        Ok(command) => (StatusCode::CREATED, Json(command)).into_response(),
        Err(e) => (
            StatusCode::BAD_REQUEST,
            Json(json!({ "error": e.to_string() })),
        )
            .into_response(),
    }
}

/// Get a command by ID
#[utoipa::path(
    get,
    path = "/api/commands/{id}",
    tag = "commands",
    params(
        ("id" = String, Path, description = "Command ID")
    ),
    responses(
        (status = 200, description = "Command found", body = CommandDefinition),
        (status = 404, description = "Command not found")
    )
)]
pub async fn get_command(
    _auth: AuthUser,
    State(service): State<CommandService>,
    Path(id): Path<String>,
) -> impl IntoResponse {
    match service.find_by_id(&id).await {
        Ok(command) => (StatusCode::OK, Json(command)).into_response(),
        Err(e) => (
            StatusCode::NOT_FOUND,
            Json(json!({ "error": e.to_string() })),
        )
            .into_response(),
    }
}

/// List commands for a project
#[utoipa::path(
    get,
    path = "/api/projects/{project_id}/commands",
    tag = "commands",
    params(
        ("project_id" = String, Path, description = "Project ID")
    ),
    responses(
        (status = 200, description = "List of commands", body = Vec<CommandDefinition>),
        (status = 500, description = "Internal server error")
    )
)]
pub async fn list_commands_for_project(
    _auth: AuthUser,
    State(service): State<CommandService>,
    Path(project_id): Path<String>,
) -> impl IntoResponse {
    match service.list_for_project(&project_id).await {
        Ok(commands) => (
            StatusCode::OK,
            Json(json!({ "commands": commands })),
        )
            .into_response(),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(json!({ "error": e.to_string() })),
        )
            .into_response(),
    }
}

/// Update a command
#[utoipa::path(
    put,
    path = "/api/commands/{id}",
    tag = "commands",
    params(
        ("id" = String, Path, description = "Command ID")
    ),
    request_body = UpdateCommandRequest,
    responses(
        (status = 200, description = "Command updated successfully", body = CommandDefinition),
        (status = 400, description = "Invalid request"),
        (status = 404, description = "Command not found")
    )
)]
pub async fn update_command(
    _auth: AuthUser,
    State(service): State<CommandService>,
    Path(id): Path<String>,
    Json(request): Json<UpdateCommandRequest>,
) -> impl IntoResponse {
    match service.update_command(&id, request).await {
        Ok(command) => (StatusCode::OK, Json(command)).into_response(),
        Err(e) => (
            StatusCode::BAD_REQUEST,
            Json(json!({ "error": e.to_string() })),
        )
            .into_response(),
    }
}

/// Delete a command
#[utoipa::path(
    delete,
    path = "/api/commands/{id}",
    tag = "commands",
    params(
        ("id" = String, Path, description = "Command ID")
    ),
    responses(
        (status = 204, description = "Command deleted successfully"),
        (status = 404, description = "Command not found")
    )
)]
pub async fn delete_command(
    _auth: AuthUser,
    State(service): State<CommandService>,
    Path(id): Path<String>,
) -> impl IntoResponse {
    match service.delete_command(&id).await {
        Ok(_) => StatusCode::NO_CONTENT.into_response(),
        Err(e) => (
            StatusCode::NOT_FOUND,
            Json(json!({ "error": e.to_string() })),
        )
            .into_response(),
    }
}

/// Add a field to command payload
#[utoipa::path(
    post,
    path = "/api/commands/{id}/fields",
    tag = "commands",
    params(
        ("id" = String, Path, description = "Command ID")
    ),
    request_body = CommandFieldRequest,
    responses(
        (status = 200, description = "Field added successfully", body = CommandDefinition),
        (status = 400, description = "Invalid request"),
        (status = 404, description = "Command not found")
    )
)]
pub async fn add_field(
    _auth: AuthUser,
    State(service): State<CommandService>,
    Path(id): Path<String>,
    Json(request): Json<CommandFieldRequest>,
) -> impl IntoResponse {
    match service.add_field(&id, request).await {
        Ok(command) => (StatusCode::OK, Json(command)).into_response(),
        Err(e) => (
            StatusCode::BAD_REQUEST,
            Json(json!({ "error": e.to_string() })),
        )
            .into_response(),
    }
}

/// Update a field in command payload
#[utoipa::path(
    put,
    path = "/api/commands/{id}/fields/{field_id}",
    tag = "commands",
    params(
        ("id" = String, Path, description = "Command ID"),
        ("field_id" = String, Path, description = "Field ID")
    ),
    request_body = CommandFieldRequest,
    responses(
        (status = 200, description = "Field updated successfully", body = CommandDefinition),
        (status = 400, description = "Invalid request"),
        (status = 404, description = "Command or field not found")
    )
)]
pub async fn update_field(
    _auth: AuthUser,
    State(service): State<CommandService>,
    Path((id, field_id)): Path<(String, String)>,
    Json(request): Json<CommandFieldRequest>,
) -> impl IntoResponse {
    match service.update_field(&id, &field_id, request).await {
        Ok(command) => (StatusCode::OK, Json(command)).into_response(),
        Err(e) => (
            StatusCode::BAD_REQUEST,
            Json(json!({ "error": e.to_string() })),
        )
            .into_response(),
    }
}

/// Remove a field from command payload
#[utoipa::path(
    delete,
    path = "/api/commands/{id}/fields/{field_id}",
    tag = "commands",
    params(
        ("id" = String, Path, description = "Command ID"),
        ("field_id" = String, Path, description = "Field ID")
    ),
    responses(
        (status = 200, description = "Field removed successfully", body = CommandDefinition),
        (status = 404, description = "Command or field not found")
    )
)]
pub async fn remove_field(
    _auth: AuthUser,
    State(service): State<CommandService>,
    Path((id, field_id)): Path<(String, String)>,
) -> impl IntoResponse {
    match service.remove_field(&id, &field_id).await {
        Ok(command) => (StatusCode::OK, Json(command)).into_response(),
        Err(e) => (
            StatusCode::NOT_FOUND,
            Json(json!({ "error": e.to_string() })),
        )
            .into_response(),
    }
}

/// Add a validation rule to command
#[utoipa::path(
    post,
    path = "/api/commands/{id}/validations",
    tag = "commands",
    params(
        ("id" = String, Path, description = "Command ID")
    ),
    request_body = CommandValidationRuleRequest,
    responses(
        (status = 200, description = "Validation rule added successfully", body = CommandDefinition),
        (status = 400, description = "Invalid request"),
        (status = 404, description = "Command not found")
    )
)]
pub async fn add_validation(
    _auth: AuthUser,
    State(service): State<CommandService>,
    Path(id): Path<String>,
    Json(request): Json<CommandValidationRuleRequest>,
) -> impl IntoResponse {
    match service.add_validation(&id, request).await {
        Ok(command) => (StatusCode::OK, Json(command)).into_response(),
        Err(e) => (
            StatusCode::BAD_REQUEST,
            Json(json!({ "error": e.to_string() })),
        )
            .into_response(),
    }
}

/// Remove a validation rule from command
#[utoipa::path(
    delete,
    path = "/api/commands/{id}/validations/{index}",
    tag = "commands",
    params(
        ("id" = String, Path, description = "Command ID"),
        ("index" = usize, Path, description = "Validation rule index")
    ),
    responses(
        (status = 200, description = "Validation rule removed successfully", body = CommandDefinition),
        (status = 404, description = "Command or validation not found")
    )
)]
pub async fn remove_validation(
    _auth: AuthUser,
    State(service): State<CommandService>,
    Path((id, index)): Path<(String, usize)>,
) -> impl IntoResponse {
    match service.remove_validation(&id, index).await {
        Ok(command) => (StatusCode::OK, Json(command)).into_response(),
        Err(e) => (
            StatusCode::NOT_FOUND,
            Json(json!({ "error": e.to_string() })),
        )
            .into_response(),
    }
}

/// Add a precondition to command
#[utoipa::path(
    post,
    path = "/api/commands/{id}/preconditions",
    tag = "commands",
    params(
        ("id" = String, Path, description = "Command ID")
    ),
    request_body = PreconditionRequest,
    responses(
        (status = 200, description = "Precondition added successfully", body = CommandDefinition),
        (status = 400, description = "Invalid request"),
        (status = 404, description = "Command not found")
    )
)]
pub async fn add_precondition(
    _auth: AuthUser,
    State(service): State<CommandService>,
    Path(id): Path<String>,
    Json(request): Json<PreconditionRequest>,
) -> impl IntoResponse {
    match service.add_precondition(&id, request).await {
        Ok(command) => (StatusCode::OK, Json(command)).into_response(),
        Err(e) => (
            StatusCode::BAD_REQUEST,
            Json(json!({ "error": e.to_string() })),
        )
            .into_response(),
    }
}

/// Remove a precondition from command
#[utoipa::path(
    delete,
    path = "/api/commands/{id}/preconditions/{index}",
    tag = "commands",
    params(
        ("id" = String, Path, description = "Command ID"),
        ("index" = usize, Path, description = "Precondition index")
    ),
    responses(
        (status = 200, description = "Precondition removed successfully", body = CommandDefinition),
        (status = 404, description = "Command or precondition not found")
    )
)]
pub async fn remove_precondition(
    _auth: AuthUser,
    State(service): State<CommandService>,
    Path((id, index)): Path<(String, usize)>,
) -> impl IntoResponse {
    match service.remove_precondition(&id, index).await {
        Ok(command) => (StatusCode::OK, Json(command)).into_response(),
        Err(e) => (
            StatusCode::NOT_FOUND,
            Json(json!({ "error": e.to_string() })),
        )
            .into_response(),
    }
}
