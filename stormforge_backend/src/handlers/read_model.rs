use axum::{
    extract::{Path, State},
    http::StatusCode,
    response::IntoResponse,
    Json,
};
use serde_json::json;

use crate::{
    models::{
        CreateReadModelRequest, DataSourceRequest, FieldRequest, UpdateReadModelRequest,
    },
    services::ReadModelService,
};

pub type _ReadModelStateInner = ReadModelService;

/// Create a new read model
#[utoipa::path(
    post,
    path = "/api/read-models",
    tag = "read-models",
    request_body = CreateReadModelRequest,
    responses(
        (status = 201, description = "Read model created successfully", body = ReadModelDefinition),
        (status = 400, description = "Invalid request"),
        (status = 409, description = "Read model already exists")
    )
)]
pub async fn create_read_model(
    State(service): State<ReadModelService>,
    Json(request): Json<CreateReadModelRequest>,
) -> impl IntoResponse {
    match service.create_read_model(request).await {
        Ok(read_model) => (StatusCode::CREATED, Json(read_model)).into_response(),
        Err(e) => (
            StatusCode::BAD_REQUEST,
            Json(json!({ "error": e.to_string() })),
        )
            .into_response(),
    }
}

/// Get a read model by ID
#[utoipa::path(
    get,
    path = "/api/read-models/{id}",
    tag = "read-models",
    params(
        ("id" = String, Path, description = "Read model ID")
    ),
    responses(
        (status = 200, description = "Read model found", body = ReadModelDefinition),
        (status = 404, description = "Read model not found")
    )
)]
pub async fn get_read_model(
    State(service): State<ReadModelService>,
    Path(id): Path<String>,
) -> impl IntoResponse {
    match service.find_by_id(&id).await {
        Ok(read_model) => (StatusCode::OK, Json(read_model)).into_response(),
        Err(e) => (
            StatusCode::NOT_FOUND,
            Json(json!({ "error": e.to_string() })),
        )
            .into_response(),
    }
}

/// List read models for a project
#[utoipa::path(
    get,
    path = "/api/projects/{project_id}/read-models",
    tag = "read-models",
    params(
        ("project_id" = String, Path, description = "Project ID")
    ),
    responses(
        (status = 200, description = "List of read models", body = Vec<ReadModelDefinition>),
        (status = 500, description = "Internal server error")
    )
)]
pub async fn list_read_models_for_project(
    State(service): State<ReadModelService>,
    Path(project_id): Path<String>,
) -> impl IntoResponse {
    match service.list_for_project(&project_id).await {
        Ok(read_models) => (
            StatusCode::OK,
            Json(json!({ "readModels": read_models })),
        )
            .into_response(),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(json!({ "error": e.to_string() })),
        )
            .into_response(),
    }
}

/// Update a read model
#[utoipa::path(
    put,
    path = "/api/read-models/{id}",
    tag = "read-models",
    params(
        ("id" = String, Path, description = "Read model ID")
    ),
    request_body = UpdateReadModelRequest,
    responses(
        (status = 200, description = "Read model updated", body = ReadModelDefinition),
        (status = 404, description = "Read model not found")
    )
)]
pub async fn update_read_model(
    State(service): State<ReadModelService>,
    Path(id): Path<String>,
    Json(request): Json<UpdateReadModelRequest>,
) -> impl IntoResponse {
    match service.update_read_model(&id, request).await {
        Ok(read_model) => (StatusCode::OK, Json(read_model)).into_response(),
        Err(e) => (
            StatusCode::NOT_FOUND,
            Json(json!({ "error": e.to_string() })),
        )
            .into_response(),
    }
}

/// Delete a read model
#[utoipa::path(
    delete,
    path = "/api/read-models/{id}",
    tag = "read-models",
    params(
        ("id" = String, Path, description = "Read model ID")
    ),
    responses(
        (status = 204, description = "Read model deleted"),
        (status = 404, description = "Read model not found")
    )
)]
pub async fn delete_read_model(
    State(service): State<ReadModelService>,
    Path(id): Path<String>,
) -> impl IntoResponse {
    match service.delete_read_model(&id).await {
        Ok(_) => StatusCode::NO_CONTENT.into_response(),
        Err(e) => (
            StatusCode::NOT_FOUND,
            Json(json!({ "error": e.to_string() })),
        )
            .into_response(),
    }
}

/// Add a data source to a read model
#[utoipa::path(
    post,
    path = "/api/read-models/{read_model_id}/sources",
    tag = "read-models",
    params(
        ("read_model_id" = String, Path, description = "Read model ID")
    ),
    request_body = DataSourceRequest,
    responses(
        (status = 200, description = "Source added", body = ReadModelDefinition),
        (status = 404, description = "Read model not found")
    )
)]
pub async fn add_source(
    State(service): State<ReadModelService>,
    Path(read_model_id): Path<String>,
    Json(request): Json<DataSourceRequest>,
) -> impl IntoResponse {
    match service.add_source(&read_model_id, request).await {
        Ok(read_model) => (StatusCode::OK, Json(read_model)).into_response(),
        Err(e) => (
            StatusCode::NOT_FOUND,
            Json(json!({ "error": e.to_string() })),
        )
            .into_response(),
    }
}

/// Update a data source in a read model
#[utoipa::path(
    put,
    path = "/api/read-models/{read_model_id}/sources/{source_index}",
    tag = "read-models",
    params(
        ("read_model_id" = String, Path, description = "Read model ID"),
        ("source_index" = usize, Path, description = "Source index")
    ),
    request_body = DataSourceRequest,
    responses(
        (status = 200, description = "Source updated", body = ReadModelDefinition),
        (status = 404, description = "Read model or source not found")
    )
)]
pub async fn update_source(
    State(service): State<ReadModelService>,
    Path((read_model_id, source_index)): Path<(String, usize)>,
    Json(request): Json<DataSourceRequest>,
) -> impl IntoResponse {
    match service
        .update_source(&read_model_id, source_index, request)
        .await
    {
        Ok(read_model) => (StatusCode::OK, Json(read_model)).into_response(),
        Err(e) => (
            StatusCode::NOT_FOUND,
            Json(json!({ "error": e.to_string() })),
        )
            .into_response(),
    }
}

/// Remove a data source from a read model
#[utoipa::path(
    delete,
    path = "/api/read-models/{read_model_id}/sources/{source_index}",
    tag = "read-models",
    params(
        ("read_model_id" = String, Path, description = "Read model ID"),
        ("source_index" = usize, Path, description = "Source index")
    ),
    responses(
        (status = 200, description = "Source removed", body = ReadModelDefinition),
        (status = 404, description = "Read model or source not found")
    )
)]
pub async fn remove_source(
    State(service): State<ReadModelService>,
    Path((read_model_id, source_index)): Path<(String, usize)>,
) -> impl IntoResponse {
    match service.remove_source(&read_model_id, source_index).await {
        Ok(read_model) => (StatusCode::OK, Json(read_model)).into_response(),
        Err(e) => (
            StatusCode::NOT_FOUND,
            Json(json!({ "error": e.to_string() })),
        )
            .into_response(),
    }
}

/// Add a field to a read model
#[utoipa::path(
    post,
    path = "/api/read-models/{read_model_id}/fields",
    tag = "read-models",
    params(
        ("read_model_id" = String, Path, description = "Read model ID")
    ),
    request_body = FieldRequest,
    responses(
        (status = 200, description = "Field added", body = ReadModelDefinition),
        (status = 404, description = "Read model not found")
    )
)]
pub async fn add_field(
    State(service): State<ReadModelService>,
    Path(read_model_id): Path<String>,
    Json(request): Json<FieldRequest>,
) -> impl IntoResponse {
    match service.add_field(&read_model_id, request).await {
        Ok(read_model) => (StatusCode::OK, Json(read_model)).into_response(),
        Err(e) => (
            StatusCode::NOT_FOUND,
            Json(json!({ "error": e.to_string() })),
        )
            .into_response(),
    }
}

/// Update a field in a read model
#[utoipa::path(
    put,
    path = "/api/read-models/{read_model_id}/fields/{field_id}",
    tag = "read-models",
    params(
        ("read_model_id" = String, Path, description = "Read model ID"),
        ("field_id" = String, Path, description = "Field ID")
    ),
    request_body = FieldRequest,
    responses(
        (status = 200, description = "Field updated", body = ReadModelDefinition),
        (status = 404, description = "Read model or field not found")
    )
)]
pub async fn update_field(
    State(service): State<ReadModelService>,
    Path((read_model_id, field_id)): Path<(String, String)>,
    Json(request): Json<FieldRequest>,
) -> impl IntoResponse {
    match service.update_field(&read_model_id, &field_id, request).await {
        Ok(read_model) => (StatusCode::OK, Json(read_model)).into_response(),
        Err(e) => (
            StatusCode::NOT_FOUND,
            Json(json!({ "error": e.to_string() })),
        )
            .into_response(),
    }
}

/// Remove a field from a read model
#[utoipa::path(
    delete,
    path = "/api/read-models/{read_model_id}/fields/{field_id}",
    tag = "read-models",
    params(
        ("read_model_id" = String, Path, description = "Read model ID"),
        ("field_id" = String, Path, description = "Field ID")
    ),
    responses(
        (status = 200, description = "Field removed", body = ReadModelDefinition),
        (status = 404, description = "Read model or field not found")
    )
)]
pub async fn remove_field(
    State(service): State<ReadModelService>,
    Path((read_model_id, field_id)): Path<(String, String)>,
) -> impl IntoResponse {
    match service.remove_field(&read_model_id, &field_id).await {
        Ok(read_model) => (StatusCode::OK, Json(read_model)).into_response(),
        Err(e) => (
            StatusCode::NOT_FOUND,
            Json(json!({ "error": e.to_string() })),
        )
            .into_response(),
    }
}
