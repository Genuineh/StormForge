use axum::{
    extract::State,
    http::StatusCode,
    Json,
};
use serde_json::{json, Value};

use crate::{
    models::{CreateUserRequest, LoginRequest, LoginResponse},
    services::{AuthService, UserService},
};

pub type AppState = std::sync::Arc<AppStateInner>;

pub struct AppStateInner {
    pub auth_service: AuthService,
    pub user_service: UserService,
}

/// Register a new user
#[utoipa::path(
    post,
    path = "/api/auth/register",
    request_body = CreateUserRequest,
    responses(
        (status = 201, description = "User created successfully", body = LoginResponse),
        (status = 400, description = "Invalid request"),
        (status = 409, description = "User already exists")
    ),
    tag = "auth"
)]
pub async fn register(
    State(state): State<AppState>,
    Json(payload): Json<CreateUserRequest>,
) -> Result<(StatusCode, Json<LoginResponse>), (StatusCode, Json<Value>)> {
    // Hash password
    let password_hash = state.auth_service
        .hash_password(&payload.password)
        .map_err(|e| {
            (
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(json!({ "error": e.to_string() })),
            )
        })?;

    // Create user
    let user = state.user_service
        .create_user(
            payload.username.clone(),
            payload.email,
            payload.display_name,
            password_hash,
            payload.role,
        )
        .await
        .map_err(|e| {
            (
                StatusCode::CONFLICT,
                Json(json!({ "error": e.to_string() })),
            )
        })?;

    // Generate token
    let token = state.auth_service
        .generate_token(&user.id, &user.username, &user.role.to_string())
        .map_err(|e| {
            (
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(json!({ "error": e.to_string() })),
            )
        })?;

    Ok((
        StatusCode::CREATED,
        Json(LoginResponse { token, user }),
    ))
}

/// Login with username/email and password
#[utoipa::path(
    post,
    path = "/api/auth/login",
    request_body = LoginRequest,
    responses(
        (status = 200, description = "Login successful", body = LoginResponse),
        (status = 401, description = "Invalid credentials")
    ),
    tag = "auth"
)]
pub async fn login(
    State(state): State<AppState>,
    Json(payload): Json<LoginRequest>,
) -> Result<Json<LoginResponse>, (StatusCode, Json<Value>)> {
    // Find user
    let user = state.user_service
        .find_by_username_or_email(&payload.username_or_email)
        .await
        .map_err(|_| {
            (
                StatusCode::UNAUTHORIZED,
                Json(json!({ "error": "Invalid credentials" })),
            )
        })?;

    // Verify password
    let password_hash = user.password_hash.as_ref().ok_or_else(|| {
        (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(json!({ "error": "User password not set" })),
        )
    })?;

    let valid = state.auth_service
        .verify_password(&payload.password, password_hash)
        .map_err(|e| {
            (
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(json!({ "error": e.to_string() })),
            )
        })?;

    if !valid {
        return Err((
            StatusCode::UNAUTHORIZED,
            Json(json!({ "error": "Invalid credentials" })),
        ));
    }

    // Update last login
    let _ = state.user_service.update_last_login(&user.id).await;

    // Generate token
    let token = state.auth_service
        .generate_token(&user.id, &user.username, &user.role.to_string())
        .map_err(|e| {
            (
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(json!({ "error": e.to_string() })),
            )
        })?;

    Ok(Json(LoginResponse { token, user }))
}
