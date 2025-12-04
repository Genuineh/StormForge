mod db;
mod handlers;
mod models;
mod services;

use anyhow::Result;
use axum::{
    routing::{delete, get, post, put},
    Router,
};
use std::sync::Arc;
use tower_http::cors::{Any, CorsLayer};
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};
use utoipa::OpenApi;
use utoipa_swagger_ui::SwaggerUi;

use crate::{
    db::{MongoDbService, SqliteService},
    handlers::{
        auth::{login, register, AppStateInner},
        entity::{
            add_invariant, add_method, add_property, create_entity, delete_entity, find_references,
            get_entity, list_entities_by_aggregate, list_entities_for_project, remove_invariant,
            remove_method, remove_property, update_entity, update_invariant, update_method,
            update_property, EntityStateInner,
        },
        project::{
            create_project, delete_project, get_project, list_projects_by_owner, update_project,
            ProjectStateInner,
        },
        team_member::{
            add_team_member, list_team_members, remove_team_member, update_team_member,
            TeamStateInner,
        },
        user::{get_user, list_users, update_user},
    },
    models::*,
    services::{
        AuthService, ConnectionService, EntityService, ProjectService, TeamMemberService,
        UserService,
    },
};

#[derive(OpenApi)]
#[openapi(
    paths(
        handlers::auth::register,
        handlers::auth::login,
        handlers::user::get_user,
        handlers::user::list_users,
        handlers::user::update_user,
        handlers::project::create_project,
        handlers::project::get_project,
        handlers::project::list_projects_by_owner,
        handlers::project::update_project,
        handlers::project::delete_project,
        handlers::team_member::add_team_member,
        handlers::team_member::list_team_members,
        handlers::team_member::update_team_member,
        handlers::team_member::remove_team_member,
        handlers::connection::create_connection,
        handlers::connection::get_connection,
        handlers::connection::list_connections,
        handlers::connection::list_element_connections,
        handlers::connection::update_connection,
        handlers::connection::delete_connection,
        handlers::entity::create_entity,
        handlers::entity::get_entity,
        handlers::entity::list_entities_for_project,
        handlers::entity::list_entities_by_aggregate,
        handlers::entity::update_entity,
        handlers::entity::delete_entity,
        handlers::entity::add_property,
        handlers::entity::update_property,
        handlers::entity::remove_property,
        handlers::entity::add_method,
        handlers::entity::update_method,
        handlers::entity::remove_method,
        handlers::entity::add_invariant,
        handlers::entity::update_invariant,
        handlers::entity::remove_invariant,
        handlers::entity::find_references,
    ),
    components(
        schemas(
            User, UserRole, Permission, CreateUserRequest, LoginRequest, LoginResponse, UpdateUserRequest,
            Project, ProjectVisibility, GitSettings, AiSettings, ProjectSettings, CreateProjectRequest, UpdateProjectRequest,
            TeamMember, TeamRole, AddTeamMemberRequest, UpdateTeamMemberRequest,
            Connection, ConnectionType, LineStyle, ArrowStyle, ConnectionStyle,
            CreateConnectionRequest, UpdateConnectionRequest,
            EntityDefinition, EntityType, EntityProperty, EntityMethod, EntityInvariant,
            MethodType, MethodParameter, ValidationType, ValidationRule,
            CreateEntityRequest, UpdateEntityRequest, PropertyRequest, MethodRequest, InvariantRequest,
        )
    ),
    tags(
        (name = "auth", description = "Authentication endpoints"),
        (name = "users", description = "User management endpoints"),
        (name = "projects", description = "Project management endpoints"),
        (name = "team", description = "Team member management endpoints"),
        (name = "connections", description = "Connection management endpoints"),
        (name = "entities", description = "Entity modeling endpoints")
    )
)]
struct ApiDoc;

#[tokio::main]
async fn main() -> Result<()> {
    // Initialize tracing
    tracing_subscriber::registry()
        .with(
            tracing_subscriber::EnvFilter::try_from_default_env()
                .unwrap_or_else(|_| "stormforge_backend=debug,tower_http=debug".into()),
        )
        .with(tracing_subscriber::fmt::layer())
        .init();

    // Load environment variables
    dotenv::dotenv().ok();

    // Get configuration from environment
    let mongodb_uri =
        std::env::var("MONGODB_URI").unwrap_or_else(|_| "mongodb://localhost:27017".to_string());
    let database_name = std::env::var("DATABASE_NAME").unwrap_or_else(|_| "stormforge".to_string());
    let sqlite_path =
        std::env::var("SQLITE_PATH").unwrap_or_else(|_| "./stormforge.db".to_string());
    let jwt_secret = std::env::var("JWT_SECRET")
        .unwrap_or_else(|_| "your-secret-key-change-in-production".to_string());
    let port = std::env::var("PORT")
        .unwrap_or_else(|_| "3000".to_string())
        .parse::<u16>()
        .unwrap_or(3000);

    tracing::info!("Starting StormForge Backend Server...");

    // Initialize databases
    tracing::info!("Connecting to MongoDB at {}...", mongodb_uri);
    let mongodb = MongoDbService::new(&mongodb_uri, &database_name).await?;
    mongodb.initialize_collections().await?;
    tracing::info!("MongoDB connected and initialized");

    tracing::info!("Initializing SQLite at {}...", sqlite_path);
    let _sqlite = SqliteService::new(&sqlite_path)?;
    tracing::info!("SQLite initialized");

    // Initialize services
    let auth_service = AuthService::new(jwt_secret);
    let user_service = UserService::new(mongodb.db());
    let project_service = ProjectService::new(mongodb.db());
    let team_member_service = TeamMemberService::new(mongodb.db());
    let connection_service = ConnectionService::new(mongodb.db());
    let entity_service = EntityService::new(mongodb.db());

    // Create application states
    let auth_state = Arc::new(AppStateInner {
        auth_service: auth_service.clone(),
        user_service: user_service.clone(),
    });

    let project_state = Arc::new(ProjectStateInner {
        project_service: project_service.clone(),
    });

    let team_state = Arc::new(TeamStateInner {
        team_member_service: team_member_service.clone(),
    });

    let entity_state = Arc::new(EntityStateInner {
        entity_service: entity_service.clone(),
    });

    // Configure CORS
    let cors = CorsLayer::new()
        .allow_origin(Any)
        .allow_methods(Any)
        .allow_headers(Any);

    // Build router
    let app = Router::new()
        // Auth routes
        .route("/api/auth/register", post(register))
        .route("/api/auth/login", post(login))
        .with_state(auth_state.clone())
        // User routes
        .route("/api/users", get(list_users))
        .route("/api/users/:id", get(get_user))
        .route("/api/users/:id", put(update_user))
        .with_state(auth_state)
        // Project routes
        .route("/api/projects", post(create_project))
        .route("/api/projects/:id", get(get_project))
        .route("/api/projects/:id", put(update_project))
        .route("/api/projects/:id", delete(delete_project))
        .route("/api/projects/owner/:owner_id", get(list_projects_by_owner))
        .with_state(project_state)
        // Team member routes
        .route("/api/projects/:project_id/members", post(add_team_member))
        .route("/api/projects/:project_id/members", get(list_team_members))
        .route(
            "/api/projects/:project_id/members/:user_id",
            put(update_team_member),
        )
        .route(
            "/api/projects/:project_id/members/:user_id",
            delete(remove_team_member),
        )
        .with_state(team_state)
        // Connection routes
        .route(
            "/api/projects/:project_id/connections",
            post(handlers::connection::create_connection),
        )
        .route(
            "/api/projects/:project_id/connections",
            get(handlers::connection::list_connections),
        )
        .route(
            "/api/projects/:project_id/connections/:connection_id",
            get(handlers::connection::get_connection),
        )
        .route(
            "/api/projects/:project_id/connections/:connection_id",
            put(handlers::connection::update_connection),
        )
        .route(
            "/api/projects/:project_id/connections/:connection_id",
            delete(handlers::connection::delete_connection),
        )
        .route(
            "/api/projects/:project_id/elements/:element_id/connections",
            get(handlers::connection::list_element_connections),
        )
        .with_state(connection_service)
        // Entity routes
        .route("/api/entities", post(create_entity))
        .route("/api/entities/:id", get(get_entity))
        .route("/api/entities/:id", put(update_entity))
        .route("/api/entities/:id", delete(delete_entity))
        .route(
            "/api/projects/:project_id/entities",
            get(list_entities_for_project),
        )
        .route(
            "/api/aggregates/:aggregate_id/entities",
            get(list_entities_by_aggregate),
        )
        .route("/api/entities/:entity_id/properties", post(add_property))
        .route(
            "/api/entities/:entity_id/properties/:property_id",
            put(update_property),
        )
        .route(
            "/api/entities/:entity_id/properties/:property_id",
            delete(remove_property),
        )
        .route("/api/entities/:entity_id/methods", post(add_method))
        .route(
            "/api/entities/:entity_id/methods/:method_id",
            put(update_method),
        )
        .route(
            "/api/entities/:entity_id/methods/:method_id",
            delete(remove_method),
        )
        .route("/api/entities/:entity_id/invariants", post(add_invariant))
        .route(
            "/api/entities/:entity_id/invariants/:invariant_id",
            put(update_invariant),
        )
        .route(
            "/api/entities/:entity_id/invariants/:invariant_id",
            delete(remove_invariant),
        )
        .route("/api/entities/:entity_id/references", get(find_references))
        .with_state(entity_state)
        // Swagger UI
        .merge(SwaggerUi::new("/swagger-ui").url("/api-docs/openapi.json", ApiDoc::openapi()))
        // Health check
        .route("/health", get(|| async { "OK" }))
        .layer(cors);

    // Start server
    let addr = format!("0.0.0.0:{}", port);
    tracing::info!("Server listening on {}", addr);
    tracing::info!(
        "Swagger UI available at http://localhost:{}/swagger-ui",
        port
    );

    let listener = tokio::net::TcpListener::bind(&addr).await?;
    axum::serve(listener, app).await?;

    Ok(())
}
