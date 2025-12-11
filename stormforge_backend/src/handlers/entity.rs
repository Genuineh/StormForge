use axum::{
    extract::{Path, State},
    http::StatusCode,
    Json,
};
use serde_json::{json, Value};

use crate::{
    middleware::auth::AuthUser,
    models::{
        CreateEntityRequest, EntityDefinition, InvariantRequest, MethodRequest, PropertyRequest,
        UpdateEntityRequest,
    },
    services::EntityService,
};

pub type EntityState = std::sync::Arc<EntityStateInner>;

pub struct EntityStateInner {
    pub entity_service: EntityService,
}

/// Create a new entity
#[utoipa::path(
    post,
    path = "/api/entities",
    request_body = CreateEntityRequest,
    responses(
        (status = 201, description = "Entity created", body = EntityDefinition),
        (status = 400, description = "Invalid request"),
        (status = 409, description = "Entity with same name already exists")
    ),
    tag = "entities"
)]
pub async fn create_entity(
    _auth: AuthUser,
    State(state): State<EntityState>,
    Json(payload): Json<CreateEntityRequest>,
) -> Result<(StatusCode, Json<EntityDefinition>), (StatusCode, Json<Value>)> {
    let entity = state
        .entity_service
        .create_entity(payload)
        .await
        .map_err(|e| {
            (
                StatusCode::CONFLICT,
                Json(json!({ "error": e.to_string() })),
            )
        })?;

    Ok((StatusCode::CREATED, Json(entity)))
}

/// Get entity by ID
#[utoipa::path(
    get,
    path = "/api/entities/{id}",
    params(
        ("id" = String, Path, description = "Entity ID")
    ),
    responses(
        (status = 200, description = "Entity found", body = EntityDefinition),
        (status = 404, description = "Entity not found")
    ),
    tag = "entities"
)]
pub async fn get_entity(
    _auth: AuthUser,
    State(state): State<EntityState>,
    Path(id): Path<String>,
) -> Result<Json<EntityDefinition>, (StatusCode, Json<Value>)> {
    let entity = state.entity_service.find_by_id(&id).await.map_err(|e| {
        (
            StatusCode::NOT_FOUND,
            Json(json!({ "error": e.to_string() })),
        )
    })?;

    Ok(Json(entity))
}

/// List entities for a project
#[utoipa::path(
    get,
    path = "/api/projects/{project_id}/entities",
    params(
        ("project_id" = String, Path, description = "Project ID")
    ),
    responses(
        (status = 200, description = "List of entities", body = Vec<EntityDefinition>)
    ),
    tag = "entities"
)]
pub async fn list_entities_for_project(
    _auth: AuthUser,
    State(state): State<EntityState>,
    Path(project_id): Path<String>,
) -> Result<Json<Vec<EntityDefinition>>, (StatusCode, Json<Value>)> {
    let entities = state
        .entity_service
        .list_for_project(&project_id)
        .await
        .map_err(|e| {
            (
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(json!({ "error": e.to_string() })),
            )
        })?;

    Ok(Json(entities))
}

/// List entities by aggregate
#[utoipa::path(
    get,
    path = "/api/aggregates/{aggregate_id}/entities",
    params(
        ("aggregate_id" = String, Path, description = "Aggregate ID")
    ),
    responses(
        (status = 200, description = "List of entities", body = Vec<EntityDefinition>)
    ),
    tag = "entities"
)]
pub async fn list_entities_by_aggregate(
    _auth: AuthUser,
    State(state): State<EntityState>,
    Path(aggregate_id): Path<String>,
) -> Result<Json<Vec<EntityDefinition>>, (StatusCode, Json<Value>)> {
    let entities = state
        .entity_service
        .list_by_aggregate(&aggregate_id)
        .await
        .map_err(|e| {
            (
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(json!({ "error": e.to_string() })),
            )
        })?;

    Ok(Json(entities))
}

/// Update entity
#[utoipa::path(
    put,
    path = "/api/entities/{id}",
    params(
        ("id" = String, Path, description = "Entity ID")
    ),
    request_body = UpdateEntityRequest,
    responses(
        (status = 200, description = "Entity updated", body = EntityDefinition),
        (status = 404, description = "Entity not found")
    ),
    tag = "entities"
)]
pub async fn update_entity(
    _auth: AuthUser,
    State(state): State<EntityState>,
    Path(id): Path<String>,
    Json(payload): Json<UpdateEntityRequest>,
) -> Result<Json<EntityDefinition>, (StatusCode, Json<Value>)> {
    let entity = state
        .entity_service
        .update_entity(&id, payload)
        .await
        .map_err(|e| {
            (
                StatusCode::BAD_REQUEST,
                Json(json!({ "error": e.to_string() })),
            )
        })?;

    Ok(Json(entity))
}

/// Delete entity
#[utoipa::path(
    delete,
    path = "/api/entities/{id}",
    params(
        ("id" = String, Path, description = "Entity ID")
    ),
    responses(
        (status = 204, description = "Entity deleted"),
        (status = 404, description = "Entity not found")
    ),
    tag = "entities"
)]
pub async fn delete_entity(
    _auth: AuthUser,
    State(state): State<EntityState>,
    Path(id): Path<String>,
) -> Result<StatusCode, (StatusCode, Json<Value>)> {
    state.entity_service.delete_entity(&id).await.map_err(|e| {
        (
            StatusCode::NOT_FOUND,
            Json(json!({ "error": e.to_string() })),
        )
    })?;

    Ok(StatusCode::NO_CONTENT)
}

// Property operations

/// Add property to entity
#[utoipa::path(
    post,
    path = "/api/entities/{entity_id}/properties",
    params(
        ("entity_id" = String, Path, description = "Entity ID")
    ),
    request_body = PropertyRequest,
    responses(
        (status = 200, description = "Property added", body = EntityDefinition),
        (status = 404, description = "Entity not found")
    ),
    tag = "entities"
)]
pub async fn add_property(
    _auth: AuthUser,
    State(state): State<EntityState>,
    Path(entity_id): Path<String>,
    Json(payload): Json<PropertyRequest>,
) -> Result<Json<EntityDefinition>, (StatusCode, Json<Value>)> {
    let entity = state
        .entity_service
        .add_property(&entity_id, payload)
        .await
        .map_err(|e| {
            (
                StatusCode::BAD_REQUEST,
                Json(json!({ "error": e.to_string() })),
            )
        })?;

    Ok(Json(entity))
}

/// Update property of entity
#[utoipa::path(
    put,
    path = "/api/entities/{entity_id}/properties/{property_id}",
    params(
        ("entity_id" = String, Path, description = "Entity ID"),
        ("property_id" = String, Path, description = "Property ID")
    ),
    request_body = PropertyRequest,
    responses(
        (status = 200, description = "Property updated", body = EntityDefinition),
        (status = 404, description = "Entity or property not found")
    ),
    tag = "entities"
)]
pub async fn update_property(
    _auth: AuthUser,
    State(state): State<EntityState>,
    Path((entity_id, property_id)): Path<(String, String)>,
    Json(payload): Json<PropertyRequest>,
) -> Result<Json<EntityDefinition>, (StatusCode, Json<Value>)> {
    let entity = state
        .entity_service
        .update_property(&entity_id, &property_id, payload)
        .await
        .map_err(|e| {
            (
                StatusCode::BAD_REQUEST,
                Json(json!({ "error": e.to_string() })),
            )
        })?;

    Ok(Json(entity))
}

/// Remove property from entity
#[utoipa::path(
    delete,
    path = "/api/entities/{entity_id}/properties/{property_id}",
    params(
        ("entity_id" = String, Path, description = "Entity ID"),
        ("property_id" = String, Path, description = "Property ID")
    ),
    responses(
        (status = 200, description = "Property removed", body = EntityDefinition),
        (status = 404, description = "Entity or property not found")
    ),
    tag = "entities"
)]
pub async fn remove_property(
    _auth: AuthUser,
    State(state): State<EntityState>,
    Path((entity_id, property_id)): Path<(String, String)>,
) -> Result<Json<EntityDefinition>, (StatusCode, Json<Value>)> {
    let entity = state
        .entity_service
        .remove_property(&entity_id, &property_id)
        .await
        .map_err(|e| {
            (
                StatusCode::BAD_REQUEST,
                Json(json!({ "error": e.to_string() })),
            )
        })?;

    Ok(Json(entity))
}

// Method operations

/// Add method to entity
#[utoipa::path(
    post,
    path = "/api/entities/{entity_id}/methods",
    params(
        ("entity_id" = String, Path, description = "Entity ID")
    ),
    request_body = MethodRequest,
    responses(
        (status = 200, description = "Method added", body = EntityDefinition),
        (status = 404, description = "Entity not found")
    ),
    tag = "entities"
)]
pub async fn add_method(
    _auth: AuthUser,
    State(state): State<EntityState>,
    Path(entity_id): Path<String>,
    Json(payload): Json<MethodRequest>,
) -> Result<Json<EntityDefinition>, (StatusCode, Json<Value>)> {
    let entity = state
        .entity_service
        .add_method(&entity_id, payload)
        .await
        .map_err(|e| {
            (
                StatusCode::BAD_REQUEST,
                Json(json!({ "error": e.to_string() })),
            )
        })?;

    Ok(Json(entity))
}

/// Update method of entity
#[utoipa::path(
    put,
    path = "/api/entities/{entity_id}/methods/{method_id}",
    params(
        ("entity_id" = String, Path, description = "Entity ID"),
        ("method_id" = String, Path, description = "Method ID")
    ),
    request_body = MethodRequest,
    responses(
        (status = 200, description = "Method updated", body = EntityDefinition),
        (status = 404, description = "Entity or method not found")
    ),
    tag = "entities"
)]
pub async fn update_method(
    _auth: AuthUser,
    State(state): State<EntityState>,
    Path((entity_id, method_id)): Path<(String, String)>,
    Json(payload): Json<MethodRequest>,
) -> Result<Json<EntityDefinition>, (StatusCode, Json<Value>)> {
    let entity = state
        .entity_service
        .update_method(&entity_id, &method_id, payload)
        .await
        .map_err(|e| {
            (
                StatusCode::BAD_REQUEST,
                Json(json!({ "error": e.to_string() })),
            )
        })?;

    Ok(Json(entity))
}

/// Remove method from entity
#[utoipa::path(
    delete,
    path = "/api/entities/{entity_id}/methods/{method_id}",
    params(
        ("entity_id" = String, Path, description = "Entity ID"),
        ("method_id" = String, Path, description = "Method ID")
    ),
    responses(
        (status = 200, description = "Method removed", body = EntityDefinition),
        (status = 404, description = "Entity or method not found")
    ),
    tag = "entities"
)]
pub async fn remove_method(
    _auth: AuthUser,
    State(state): State<EntityState>,
    Path((entity_id, method_id)): Path<(String, String)>,
) -> Result<Json<EntityDefinition>, (StatusCode, Json<Value>)> {
    let entity = state
        .entity_service
        .remove_method(&entity_id, &method_id)
        .await
        .map_err(|e| {
            (
                StatusCode::BAD_REQUEST,
                Json(json!({ "error": e.to_string() })),
            )
        })?;

    Ok(Json(entity))
}

// Invariant operations

/// Add invariant to entity
#[utoipa::path(
    post,
    path = "/api/entities/{entity_id}/invariants",
    params(
        ("entity_id" = String, Path, description = "Entity ID")
    ),
    request_body = InvariantRequest,
    responses(
        (status = 200, description = "Invariant added", body = EntityDefinition),
        (status = 404, description = "Entity not found")
    ),
    tag = "entities"
)]
pub async fn add_invariant(
    _auth: AuthUser,
    State(state): State<EntityState>,
    Path(entity_id): Path<String>,
    Json(payload): Json<InvariantRequest>,
) -> Result<Json<EntityDefinition>, (StatusCode, Json<Value>)> {
    let entity = state
        .entity_service
        .add_invariant(&entity_id, payload)
        .await
        .map_err(|e| {
            (
                StatusCode::BAD_REQUEST,
                Json(json!({ "error": e.to_string() })),
            )
        })?;

    Ok(Json(entity))
}

/// Update invariant of entity
#[utoipa::path(
    put,
    path = "/api/entities/{entity_id}/invariants/{invariant_id}",
    params(
        ("entity_id" = String, Path, description = "Entity ID"),
        ("invariant_id" = String, Path, description = "Invariant ID")
    ),
    request_body = InvariantRequest,
    responses(
        (status = 200, description = "Invariant updated", body = EntityDefinition),
        (status = 404, description = "Entity or invariant not found")
    ),
    tag = "entities"
)]
pub async fn update_invariant(
    _auth: AuthUser,
    State(state): State<EntityState>,
    Path((entity_id, invariant_id)): Path<(String, String)>,
    Json(payload): Json<InvariantRequest>,
) -> Result<Json<EntityDefinition>, (StatusCode, Json<Value>)> {
    let entity = state
        .entity_service
        .update_invariant(&entity_id, &invariant_id, payload)
        .await
        .map_err(|e| {
            (
                StatusCode::BAD_REQUEST,
                Json(json!({ "error": e.to_string() })),
            )
        })?;

    Ok(Json(entity))
}

/// Remove invariant from entity
#[utoipa::path(
    delete,
    path = "/api/entities/{entity_id}/invariants/{invariant_id}",
    params(
        ("entity_id" = String, Path, description = "Entity ID"),
        ("invariant_id" = String, Path, description = "Invariant ID")
    ),
    responses(
        (status = 200, description = "Invariant removed", body = EntityDefinition),
        (status = 404, description = "Entity or invariant not found")
    ),
    tag = "entities"
)]
pub async fn remove_invariant(
    _auth: AuthUser,
    State(state): State<EntityState>,
    Path((entity_id, invariant_id)): Path<(String, String)>,
) -> Result<Json<EntityDefinition>, (StatusCode, Json<Value>)> {
    let entity = state
        .entity_service
        .remove_invariant(&entity_id, &invariant_id)
        .await
        .map_err(|e| {
            (
                StatusCode::BAD_REQUEST,
                Json(json!({ "error": e.to_string() })),
            )
        })?;

    Ok(Json(entity))
}

/// Find references to entity
#[utoipa::path(
    get,
    path = "/api/entities/{entity_id}/references",
    params(
        ("entity_id" = String, Path, description = "Entity ID")
    ),
    responses(
        (status = 200, description = "List of referencing entities", body = Vec<EntityDefinition>)
    ),
    tag = "entities"
)]
pub async fn find_references(
    _auth: AuthUser,
    State(state): State<EntityState>,
    Path(entity_id): Path<String>,
) -> Result<Json<Vec<EntityDefinition>>, (StatusCode, Json<Value>)> {
    let references = state
        .entity_service
        .find_references(&entity_id)
        .await
        .map_err(|e| {
            (
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(json!({ "error": e.to_string() })),
            )
        })?;

    Ok(Json(references))
}
