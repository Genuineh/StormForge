use axum::{
    extract::{Path, State},
    http::StatusCode,
    Json,
};
use serde_json::{json, Value};

use crate::{
    handlers::auth::AppState,
    middleware::auth::AuthUser,
    models::{UpdateUserRequest, User},
};

/// Get user by ID
#[utoipa::path(
    get,
    path = "/api/users/{id}",
    params(
        ("id" = String, Path, description = "User ID")
    ),
    responses(
        (status = 200, description = "User found", body = User),
        (status = 404, description = "User not found")
    ),
    tag = "users"
)]
pub async fn get_user(
    _auth: AuthUser,
    State(state): State<AppState>,
    Path(id): Path<String>,
) -> Result<Json<User>, (StatusCode, Json<Value>)> {
    let mut user = state.user_service.find_by_id(&id).await.map_err(|e| {
        (
            StatusCode::NOT_FOUND,
            Json(json!({ "error": e.to_string() })),
        )
    })?;

    // Clear password hash before sending response
    user.password_hash = None;

    Ok(Json(user))
}

/// List all users
#[utoipa::path(
    get,
    path = "/api/users",
    responses(
        (status = 200, description = "List of users", body = Vec<User>)
    ),
    tag = "users"
)]
pub async fn list_users(
    _auth: AuthUser,
    State(state): State<AppState>,
) -> Result<Json<Vec<User>>, (StatusCode, Json<Value>)> {
    let mut users = state.user_service.list_users().await.map_err(|e| {
        (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(json!({ "error": e.to_string() })),
        )
    })?;

    // Clear password hashes before sending response
    for user in &mut users {
        user.password_hash = None;
    }

    Ok(Json(users))
}

/// Update user
#[utoipa::path(
    put,
    path = "/api/users/{id}",
    params(
        ("id" = String, Path, description = "User ID")
    ),
    request_body = UpdateUserRequest,
    responses(
        (status = 200, description = "User updated", body = User),
        (status = 404, description = "User not found")
    ),
    tag = "users"
)]
pub async fn update_user(
    auth: AuthUser,
    State(state): State<AppState>,
    Path(id): Path<String>,
    Json(payload): Json<UpdateUserRequest>,
) -> Result<Json<User>, (StatusCode, Json<Value>)> {
    // Authorization: users can only update their own profile unless they are admin
    if auth.0.sub != id && auth.0.role != "admin" {
        return Err((
            StatusCode::FORBIDDEN,
            Json(json!({ "error": "You can only update your own profile" })),
        ));
    }

    let mut user = state
        .user_service
        .update_user(&id, payload.display_name, payload.avatar_url, payload.email)
        .await
        .map_err(|e| {
            (
                StatusCode::BAD_REQUEST,
                Json(json!({ "error": e.to_string() })),
            )
        })?;

    // Clear password hash before sending response
    user.password_hash = None;

    Ok(Json(user))
}
