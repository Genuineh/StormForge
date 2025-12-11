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
        command::{
            add_field as add_command_field, add_precondition, add_validation,
            create_command, delete_command, get_command, list_commands_for_project,
            remove_field as remove_command_field, remove_precondition, remove_validation,
            update_command, update_field as update_command_field,
        },
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
        read_model::{
            add_field, add_source, create_read_model, delete_read_model, get_read_model,
            list_read_models_for_project, remove_field, remove_source, update_field,
            update_read_model, update_source,
        },
        team_member::{
            add_team_member, list_team_members, remove_team_member, update_team_member,
            TeamStateInner,
        },
        user::{get_user, list_users, update_user},
        library::{
            add_component_reference, analyze_component_impact, delete_component, get_component,
            get_component_versions, get_project_references, publish_component,
            remove_component_reference, search_components, update_component_version,
            LibraryStateInner,
        },
    },
    models::*,
    services::{
        AuthService, CommandService, ConnectionService, EntityService, LibraryService,
        ProjectService, ReadModelService, TeamMemberService, UserService,
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
        handlers::read_model::create_read_model,
        handlers::read_model::get_read_model,
        handlers::read_model::list_read_models_for_project,
        handlers::read_model::update_read_model,
        handlers::read_model::delete_read_model,
        handlers::read_model::add_source,
        handlers::read_model::update_source,
        handlers::read_model::remove_source,
        handlers::read_model::add_field,
        handlers::read_model::update_field,
        handlers::read_model::remove_field,
        handlers::command::create_command,
        handlers::command::get_command,
        handlers::command::list_commands_for_project,
        handlers::command::update_command,
        handlers::command::delete_command,
        handlers::command::add_field,
        handlers::command::update_field,
        handlers::command::remove_field,
        handlers::command::add_validation,
        handlers::command::remove_validation,
        handlers::command::add_precondition,
        handlers::command::remove_precondition,
        handlers::library::publish_component,
        handlers::library::get_component,
        handlers::library::search_components,
        handlers::library::update_component_version,
        handlers::library::delete_component,
        handlers::library::get_component_versions,
        handlers::library::add_component_reference,
        handlers::library::remove_component_reference,
        handlers::library::get_project_references,
        handlers::library::analyze_component_impact,
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
            ReadModelDefinition, ReadModelField, ReadModelMetadata, DataSource, JoinCondition, JoinType, JoinOperator,
            FieldSourceType, TransformType, FieldTransform,
            CreateReadModelRequest, UpdateReadModelRequest, DataSourceRequest, FieldRequest,
            CommandDefinition, CommandPayload, CommandField, CommandMetadata,
            FieldSource, ValidationOperator, CommandValidationRule, PreconditionOperator, Precondition,
            CreateCommandRequest, UpdateCommandRequest, CommandFieldRequest,
            CommandValidationRuleRequest, PreconditionRequest,
            LibraryComponent, ComponentVersion, ComponentReference, ComponentStatus,
            LibraryScope, ComponentType, ComponentReferenceMode, UsageStats,
            PublishComponentRequest, UpdateVersionRequest, AddReferenceRequest,
            ProjectImpact, ImpactAnalysis,
        )
    ),
    tags(
        (name = "auth", description = "Authentication endpoints"),
        (name = "users", description = "User management endpoints"),
        (name = "projects", description = "Project management endpoints"),
        (name = "team", description = "Team member management endpoints"),
        (name = "connections", description = "Connection management endpoints"),
        (name = "entities", description = "Entity modeling endpoints"),
        (name = "read-models", description = "Read model designer endpoints"),
        (name = "commands", description = "Command data model designer endpoints"),
        (name = "Library", description = "Enterprise global library endpoints")
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
    let read_model_service = ReadModelService::new(mongodb.db());
    let command_service = CommandService::new(mongodb.db());
    let library_service = LibraryService::new(mongodb.db());

    // Initialize default admin user if configured
    let init_default_admin = std::env::var("INIT_DEFAULT_ADMIN")
        .unwrap_or_else(|_| "false".to_string())
        .parse::<bool>()
        .unwrap_or(false);

    if init_default_admin {
        let admin_username = std::env::var("DEFAULT_ADMIN_USERNAME")
            .unwrap_or_else(|_| "admin".to_string());
        let admin_email = std::env::var("DEFAULT_ADMIN_EMAIL")
            .unwrap_or_else(|_| "admin@stormforge.local".to_string());
        let admin_display_name = std::env::var("DEFAULT_ADMIN_DISPLAY_NAME")
            .unwrap_or_else(|_| "Administrator".to_string());
        let admin_password = std::env::var("DEFAULT_ADMIN_PASSWORD")
            .unwrap_or_else(|_| "admin123".to_string());

        tracing::info!("Initializing default admin user...");
        let password_hash = auth_service
            .hash_password(&admin_password)
            .expect("Failed to hash default admin password");

        match user_service
            .ensure_default_admin(
                admin_username.clone(),
                admin_email,
                admin_display_name,
                password_hash,
            )
            .await
        {
            Ok(true) => tracing::info!(
                "Default admin user '{}' created successfully",
                admin_username
            ),
            Ok(false) => tracing::info!("Default admin user initialization skipped"),
            Err(e) => tracing::error!("Failed to initialize default admin user: {}", e),
        }
    }

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

    let library_state = Arc::new(LibraryStateInner {
        library_service: library_service.clone(),
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
        // Read model routes
        .route("/api/read-models", post(create_read_model))
        .route("/api/read-models/:id", get(get_read_model))
        .route("/api/read-models/:id", put(update_read_model))
        .route("/api/read-models/:id", delete(delete_read_model))
        .route(
            "/api/projects/:project_id/read-models",
            get(list_read_models_for_project),
        )
        .route(
            "/api/read-models/:read_model_id/sources",
            post(add_source),
        )
        .route(
            "/api/read-models/:read_model_id/sources/:source_index",
            put(update_source),
        )
        .route(
            "/api/read-models/:read_model_id/sources/:source_index",
            delete(remove_source),
        )
        .route("/api/read-models/:read_model_id/fields", post(add_field))
        .route(
            "/api/read-models/:read_model_id/fields/:field_id",
            put(update_field),
        )
        .route(
            "/api/read-models/:read_model_id/fields/:field_id",
            delete(remove_field),
        )
        .with_state(read_model_service)
        // Command routes
        .route("/api/commands", post(create_command))
        .route("/api/commands/:id", get(get_command))
        .route("/api/commands/:id", put(update_command))
        .route("/api/commands/:id", delete(delete_command))
        .route(
            "/api/projects/:project_id/commands",
            get(list_commands_for_project),
        )
        .route("/api/commands/:command_id/fields", post(add_command_field))
        .route(
            "/api/commands/:command_id/fields/:field_id",
            put(update_command_field),
        )
        .route(
            "/api/commands/:command_id/fields/:field_id",
            delete(remove_command_field),
        )
        .route(
            "/api/commands/:command_id/validations",
            post(add_validation),
        )
        .route(
            "/api/commands/:command_id/validations/:validation_index",
            delete(remove_validation),
        )
        .route(
            "/api/commands/:command_id/preconditions",
            post(add_precondition),
        )
        .route(
            "/api/commands/:command_id/preconditions/:precondition_index",
            delete(remove_precondition),
        )
        .with_state(command_service)
        // Library routes
        .route("/api/library/components", post(publish_component))
        .route("/api/library/components", get(search_components))
        .route("/api/library/components/:id", get(get_component))
        .route(
            "/api/library/components/:id/version",
            put(update_component_version),
        )
        .route("/api/library/components/:id", delete(delete_component))
        .route(
            "/api/library/components/:id/versions",
            get(get_component_versions),
        )
        .route(
            "/api/library/components/:id/impact",
            get(analyze_component_impact),
        )
        .route(
            "/api/projects/:project_id/library/references",
            post(add_component_reference),
        )
        .route(
            "/api/projects/:project_id/library/references",
            get(get_project_references),
        )
        .route(
            "/api/projects/:project_id/library/references/:component_id",
            delete(remove_component_reference),
        )
        .with_state(library_state)
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
