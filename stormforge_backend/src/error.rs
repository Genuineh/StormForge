use axum::{
    http::StatusCode,
    response::{IntoResponse, Response},
    Json,
};
use serde::{Deserialize, Serialize};
use std::fmt;
use thiserror::Error;

/// Application error types
#[derive(Error, Debug)]
pub enum AppError {
    #[error("Database error: {0}")]
    Database(String),

    #[error("Not found: {0}")]
    NotFound(String),

    #[error("Unauthorized: {0}")]
    Unauthorized(String),

    #[error("Forbidden: {0}")]
    Forbidden(String),

    #[error("Invalid input: {0}")]
    InvalidInput(String),

    #[error("Conflict: {0}")]
    Conflict(String),

    #[error("Internal server error: {0}")]
    InternalServerError(String),

    #[error("Service unavailable: {0}")]
    ServiceUnavailable(String),
}

/// Error response structure returned to clients
#[derive(Serialize, Deserialize, Debug)]
pub struct ErrorResponse {
    pub error: String,
    pub message: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub details: Option<serde_json::Value>,
    pub timestamp: String,
}

impl ErrorResponse {
    pub fn new(error: String, message: String) -> Self {
        Self {
            error,
            message,
            details: None,
            timestamp: chrono::Utc::now().to_rfc3339(),
        }
    }

    pub fn with_details(mut self, details: serde_json::Value) -> Self {
        self.details = Some(details);
        self
    }
}

impl IntoResponse for AppError {
    fn into_response(self) -> Response {
        let (status, error_type) = match &self {
            AppError::Database(_) => (StatusCode::INTERNAL_SERVER_ERROR, "database_error"),
            AppError::NotFound(_) => (StatusCode::NOT_FOUND, "not_found"),
            AppError::Unauthorized(_) => (StatusCode::UNAUTHORIZED, "unauthorized"),
            AppError::Forbidden(_) => (StatusCode::FORBIDDEN, "forbidden"),
            AppError::InvalidInput(_) => (StatusCode::BAD_REQUEST, "invalid_input"),
            AppError::Conflict(_) => (StatusCode::CONFLICT, "conflict"),
            AppError::InternalServerError(_) => {
                (StatusCode::INTERNAL_SERVER_ERROR, "internal_server_error")
            }
            AppError::ServiceUnavailable(_) => {
                (StatusCode::SERVICE_UNAVAILABLE, "service_unavailable")
            }
        };

        let body = Json(ErrorResponse::new(
            error_type.to_string(),
            self.to_string(),
        ));

        (status, body).into_response()
    }
}

/// Convert from various error types
impl From<mongodb::error::Error> for AppError {
    fn from(err: mongodb::error::Error) -> Self {
        AppError::Database(err.to_string())
    }
}

impl From<rusqlite::Error> for AppError {
    fn from(err: rusqlite::Error) -> Self {
        AppError::Database(err.to_string())
    }
}

impl From<r2d2::Error> for AppError {
    fn from(err: r2d2::Error) -> Self {
        AppError::Database(err.to_string())
    }
}

impl From<serde_json::Error> for AppError {
    fn from(err: serde_json::Error) -> Self {
        AppError::InvalidInput(err.to_string())
    }
}

impl From<bson::ser::Error> for AppError {
    fn from(err: bson::ser::Error) -> Self {
        AppError::InternalServerError(err.to_string())
    }
}

impl From<bson::de::Error> for AppError {
    fn from(err: bson::de::Error) -> Self {
        AppError::InternalServerError(err.to_string())
    }
}

/// Result type alias for the application
pub type AppResult<T> = Result<T, AppError>;

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_error_display() {
        let err = AppError::NotFound("User not found".to_string());
        assert_eq!(err.to_string(), "Not found: User not found");

        let err = AppError::Unauthorized("Invalid token".to_string());
        assert_eq!(err.to_string(), "Unauthorized: Invalid token");

        let err = AppError::InvalidInput("Missing field".to_string());
        assert_eq!(err.to_string(), "Invalid input: Missing field");
    }

    #[test]
    fn test_error_response_creation() {
        let response = ErrorResponse::new(
            "test_error".to_string(),
            "Test error message".to_string(),
        );

        assert_eq!(response.error, "test_error");
        assert_eq!(response.message, "Test error message");
        assert!(response.details.is_none());
        assert!(!response.timestamp.is_empty());
    }

    #[test]
    fn test_error_response_with_details() {
        let response = ErrorResponse::new(
            "validation_error".to_string(),
            "Validation failed".to_string(),
        )
        .with_details(serde_json::json!({
            "field": "email",
            "reason": "Invalid format"
        }));

        assert!(response.details.is_some());
        let details = response.details.unwrap();
        assert_eq!(details["field"], "email");
    }

    #[test]
    fn test_error_status_codes() {
        let errors = vec![
            (
                AppError::NotFound("test".to_string()),
                StatusCode::NOT_FOUND,
            ),
            (
                AppError::Unauthorized("test".to_string()),
                StatusCode::UNAUTHORIZED,
            ),
            (
                AppError::Forbidden("test".to_string()),
                StatusCode::FORBIDDEN,
            ),
            (
                AppError::InvalidInput("test".to_string()),
                StatusCode::BAD_REQUEST,
            ),
            (
                AppError::Conflict("test".to_string()),
                StatusCode::CONFLICT,
            ),
            (
                AppError::InternalServerError("test".to_string()),
                StatusCode::INTERNAL_SERVER_ERROR,
            ),
            (
                AppError::ServiceUnavailable("test".to_string()),
                StatusCode::SERVICE_UNAVAILABLE,
            ),
        ];

        for (error, expected_status) in errors {
            let response = error.into_response();
            assert_eq!(response.status(), expected_status);
        }
    }

    #[test]
    fn test_error_conversions() {
        // Test that error conversions work (these create AppError from other error types)
        let json_error = serde_json::from_str::<serde_json::Value>("{invalid json");
        assert!(json_error.is_err());
        let app_error: AppError = json_error.unwrap_err().into();
        assert!(matches!(app_error, AppError::InvalidInput(_)));
    }
}
