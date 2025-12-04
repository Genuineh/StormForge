use axum::{
    extract::{Path, State},
    http::StatusCode,
    Json,
};
use serde_json::{json, Value};

use crate::{
    models::{AddTeamMemberRequest, TeamMember, UpdateTeamMemberRequest},
    services::TeamMemberService,
};

pub type TeamState = std::sync::Arc<TeamStateInner>;

pub struct TeamStateInner {
    pub team_member_service: TeamMemberService,
}

/// Add team member to project
#[utoipa::path(
    post,
    path = "/api/projects/{project_id}/members",
    params(
        ("project_id" = String, Path, description = "Project ID")
    ),
    request_body = AddTeamMemberRequest,
    responses(
        (status = 201, description = "Member added", body = TeamMember),
        (status = 409, description = "Member already exists")
    ),
    tag = "team"
)]
pub async fn add_team_member(
    State(state): State<TeamState>,
    Path(project_id): Path<String>,
    Json(payload): Json<AddTeamMemberRequest>,
) -> Result<(StatusCode, Json<TeamMember>), (StatusCode, Json<Value>)> {
    // TODO: SECURITY - Implement authentication middleware to extract invited_by from JWT token
    // This placeholder creates audit trail gaps and security issues
    // Solution: Add JWT verification middleware that extracts user_id from token claims
    let invited_by = Some("placeholder_inviter_id".to_string());

    let member = state
        .team_member_service
        .add_member(project_id, payload.user_id, payload.role, invited_by)
        .await
        .map_err(|e| {
            (
                StatusCode::CONFLICT,
                Json(json!({ "error": e.to_string() })),
            )
        })?;

    Ok((StatusCode::CREATED, Json(member)))
}

/// List project team members
#[utoipa::path(
    get,
    path = "/api/projects/{project_id}/members",
    params(
        ("project_id" = String, Path, description = "Project ID")
    ),
    responses(
        (status = 200, description = "List of team members", body = Vec<TeamMember>)
    ),
    tag = "team"
)]
pub async fn list_team_members(
    State(state): State<TeamState>,
    Path(project_id): Path<String>,
) -> Result<Json<Vec<TeamMember>>, (StatusCode, Json<Value>)> {
    let members = state
        .team_member_service
        .list_project_members(&project_id)
        .await
        .map_err(|e| {
            (
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(json!({ "error": e.to_string() })),
            )
        })?;

    Ok(Json(members))
}

/// Update team member role
#[utoipa::path(
    put,
    path = "/api/projects/{project_id}/members/{user_id}",
    params(
        ("project_id" = String, Path, description = "Project ID"),
        ("user_id" = String, Path, description = "User ID")
    ),
    request_body = UpdateTeamMemberRequest,
    responses(
        (status = 200, description = "Member updated", body = TeamMember),
        (status = 404, description = "Member not found")
    ),
    tag = "team"
)]
pub async fn update_team_member(
    State(state): State<TeamState>,
    Path((project_id, user_id)): Path<(String, String)>,
    Json(payload): Json<UpdateTeamMemberRequest>,
) -> Result<Json<TeamMember>, (StatusCode, Json<Value>)> {
    let member = state
        .team_member_service
        .update_member(&project_id, &user_id, payload.role)
        .await
        .map_err(|e| {
            (
                StatusCode::BAD_REQUEST,
                Json(json!({ "error": e.to_string() })),
            )
        })?;

    Ok(Json(member))
}

/// Remove team member from project
#[utoipa::path(
    delete,
    path = "/api/projects/{project_id}/members/{user_id}",
    params(
        ("project_id" = String, Path, description = "Project ID"),
        ("user_id" = String, Path, description = "User ID")
    ),
    responses(
        (status = 204, description = "Member removed"),
        (status = 404, description = "Member not found")
    ),
    tag = "team"
)]
pub async fn remove_team_member(
    State(state): State<TeamState>,
    Path((project_id, user_id)): Path<(String, String)>,
) -> Result<StatusCode, (StatusCode, Json<Value>)> {
    state
        .team_member_service
        .remove_member(&project_id, &user_id)
        .await
        .map_err(|e| {
            (
                StatusCode::NOT_FOUND,
                Json(json!({ "error": e.to_string() })),
            )
        })?;

    Ok(StatusCode::NO_CONTENT)
}
