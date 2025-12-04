use crate::generators::{
    api_generator::*, command_generator::*, entity_generator::*, event_generator::*, utils::*,
};
use crate::ir::IRModel;
use anyhow::{Context, Result};
use std::fs;

pub struct RustGenerator {
    output_dir: String,
}

impl RustGenerator {
    pub fn new(output_dir: String) -> Self {
        Self { output_dir }
    }

    /// Generate a complete Rust microservice from an IR model
    pub fn generate(&self, model: &IRModel) -> Result<()> {
        println!(
            "🚀 Generating Rust microservice for '{}'...",
            model.bounded_context.name
        );

        // Create output directory structure
        self.create_directory_structure()?;

        // Generate Cargo.toml
        self.generate_cargo_toml(model)?;

        // Generate source files
        self.generate_domain_entities(model)?;
        self.generate_domain_commands(model)?;
        self.generate_domain_events(model)?;
        self.generate_api_routes(model)?;
        self.generate_main(model)?;
        self.generate_lib(model)?;

        // Generate repository layer
        self.generate_repository(model)?;

        // Generate event store
        self.generate_event_store(model)?;

        // Generate README
        self.generate_readme(model)?;

        println!("✅ Generation complete! Output at: {}", self.output_dir);

        Ok(())
    }

    fn create_directory_structure(&self) -> Result<()> {
        let dirs = vec![
            format!("{}/src", self.output_dir),
            format!("{}/src/domain", self.output_dir),
            format!("{}/src/api", self.output_dir),
            format!("{}/src/infrastructure", self.output_dir),
            format!("{}/src/repository", self.output_dir),
            format!("{}/tests", self.output_dir),
        ];

        for dir in dirs {
            fs::create_dir_all(&dir)
                .with_context(|| format!("Failed to create directory: {}", dir))?;
        }

        Ok(())
    }

    fn generate_cargo_toml(&self, model: &IRModel) -> Result<()> {
        let package_name = to_kebab_case(&model.bounded_context.name);

        let content = format!(
            r#"[package]
name = "{}"
version = "0.1.0"
edition = "2021"
authors = ["StormForge Generator"]

[dependencies]
# Web framework
axum = {{ version = "0.7", features = ["macros"] }}
tokio = {{ version = "1", features = ["full"] }}
tower = "0.4"
tower-http = {{ version = "0.5", features = ["cors", "trace"] }}

# Serialization
serde = {{ version = "1.0", features = ["derive"] }}
serde_json = "1.0"

# Date/Time
chrono = {{ version = "0.4", features = ["serde"] }}

# UUID
uuid = {{ version = "1.10", features = ["v4", "serde"] }}

# Decimal
rust_decimal = {{ version = "1.35", features = ["serde"] }}

# Database (optional)
sqlx = {{ version = "0.7", features = ["runtime-tokio-native-tls", "postgres", "uuid", "chrono"], optional = true }}

# Async
async-trait = "0.1"

# Error handling
thiserror = "1.0"
anyhow = "1.0"

# Logging
tracing = "0.1"
tracing-subscriber = {{ version = "0.3", features = ["env-filter"] }}

# OpenAPI documentation
utoipa = {{ version = "4", features = ["axum_extras"] }}
utoipa-swagger-ui = {{ version = "7", features = ["axum"] }}

[features]
default = []
sqlx = ["dep:sqlx"]

[profile.release]
opt-level = 3
lto = true
codegen-units = 1
"#,
            package_name
        );

        let path = format!("{}/Cargo.toml", self.output_dir);
        fs::write(&path, content)
            .with_context(|| format!("Failed to write Cargo.toml to {}", path))?;

        Ok(())
    }

    fn generate_domain_entities(&self, model: &IRModel) -> Result<()> {
        let code = EntityGenerator::generate(model)?;

        let path = format!("{}/src/domain/entities.rs", self.output_dir);
        fs::write(&path, code).with_context(|| format!("Failed to write entities to {}", path))?;

        Ok(())
    }

    fn generate_domain_commands(&self, model: &IRModel) -> Result<()> {
        let code = CommandGenerator::generate(model)?;

        let path = format!("{}/src/domain/commands.rs", self.output_dir);
        fs::write(&path, code).with_context(|| format!("Failed to write commands to {}", path))?;

        Ok(())
    }

    fn generate_domain_events(&self, model: &IRModel) -> Result<()> {
        let code = EventGenerator::generate(model)?;

        let path = format!("{}/src/domain/events.rs", self.output_dir);
        fs::write(&path, code).with_context(|| format!("Failed to write events to {}", path))?;

        Ok(())
    }

    fn generate_api_routes(&self, model: &IRModel) -> Result<()> {
        let code = ApiGenerator::generate(model)?;

        let path = format!("{}/src/api/routes.rs", self.output_dir);
        fs::write(&path, code)
            .with_context(|| format!("Failed to write API routes to {}", path))?;

        // Generate api mod.rs
        let mod_content = "pub mod routes;\n\npub use routes::*;\n";
        let mod_path = format!("{}/src/api/mod.rs", self.output_dir);
        fs::write(&mod_path, mod_content)?;

        Ok(())
    }

    fn generate_main(&self, model: &IRModel) -> Result<()> {
        let context_name = &model.bounded_context.name;

        let content = format!(
            r#"use axum::Router;
use std::net::SocketAddr;
use tower_http::cors::CorsLayer;
use tracing_subscriber::{{layer::SubscriberExt, util::SubscriberInitExt}};
use utoipa::OpenApi;
use utoipa_swagger_ui::SwaggerUi;

mod api;
mod domain;
mod infrastructure;
mod repository;

use crate::api::{{create_router, ApiDoc}};

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {{
    // Initialize tracing
    tracing_subscriber::registry()
        .with(
            tracing_subscriber::EnvFilter::try_from_default_env()
                .unwrap_or_else(|_| "info".into()),
        )
        .with(tracing_subscriber::fmt::layer())
        .init();

    tracing::info!("Starting {{}} service...", "{}");

    // Create API router
    let api_router = create_router();
    
    // Create Swagger UI
    let swagger = SwaggerUi::new("/swagger-ui")
        .url("/api-docs/openapi.json", ApiDoc::openapi());

    // Build application with middleware
    let app = Router::new()
        .merge(swagger)
        .nest("/api", api_router)
        .layer(CorsLayer::permissive());

    // Start server
    let addr = SocketAddr::from(([0, 0, 0, 0], 3000));
    tracing::info!("Listening on http://{{}}", addr);
    tracing::info!("Swagger UI available at http://{{}}/swagger-ui", addr);

    let listener = tokio::net::TcpListener::bind(addr).await?;
    axum::serve(listener, app).await?;

    Ok(())
}}
"#,
            context_name
        );

        let path = format!("{}/src/main.rs", self.output_dir);
        fs::write(&path, content)
            .with_context(|| format!("Failed to write main.rs to {}", path))?;

        Ok(())
    }

    fn generate_lib(&self, _model: &IRModel) -> Result<()> {
        let content = r#"pub mod api;
pub mod domain;
pub mod infrastructure;
pub mod repository;
"#;

        let path = format!("{}/src/lib.rs", self.output_dir);
        fs::write(&path, content)?;

        Ok(())
    }

    fn generate_repository(&self, _model: &IRModel) -> Result<()> {
        let content = r#"//! Repository layer for data persistence
//!
//! This module provides repository implementations for aggregates.

use async_trait::async_trait;
use anyhow::Result;

use crate::domain::entities::*;

/// Generic repository trait for aggregates
#[async_trait]
pub trait Repository<T>: Send + Sync {
    /// Find an aggregate by ID
    async fn find_by_id(&self, id: &str) -> Result<Option<T>>;
    
    /// Save an aggregate
    async fn save(&self, aggregate: &T) -> Result<()>;
    
    /// Delete an aggregate
    async fn delete(&self, id: &str) -> Result<()>;
}

/// In-memory repository implementation (for development/testing)
pub struct InMemoryRepository<T> {
    _phantom: std::marker::PhantomData<T>,
}

impl<T> InMemoryRepository<T> {
    pub fn new() -> Self {
        Self {
            _phantom: std::marker::PhantomData,
        }
    }
}

#[async_trait]
impl<T: Send + Sync> Repository<T> for InMemoryRepository<T> {
    async fn find_by_id(&self, _id: &str) -> Result<Option<T>> {
        // TODO: Implement in-memory storage
        Ok(None)
    }
    
    async fn save(&self, _aggregate: &T) -> Result<()> {
        // TODO: Implement in-memory storage
        Ok(())
    }
    
    async fn delete(&self, _id: &str) -> Result<()> {
        // TODO: Implement in-memory storage
        Ok(())
    }
}
"#;

        let path = format!("{}/src/repository/mod.rs", self.output_dir);
        fs::write(&path, content)?;

        Ok(())
    }

    fn generate_event_store(&self, _model: &IRModel) -> Result<()> {
        let content = r#"//! Event sourcing infrastructure
//!
//! This module provides event store implementation for event sourcing.

use async_trait::async_trait;
use anyhow::Result;
use chrono::{DateTime, Utc};
use uuid::Uuid;

use crate::domain::events::*;

/// Event store trait
#[async_trait]
pub trait EventStore: Send + Sync {
    /// Append events to the store
    async fn append_events(
        &self,
        aggregate_id: &str,
        aggregate_type: &str,
        events: Vec<DomainEvent>,
        expected_version: Option<i64>,
    ) -> Result<()>;
    
    /// Load events for an aggregate
    async fn load_events(
        &self,
        aggregate_id: &str,
        aggregate_type: &str,
    ) -> Result<Vec<DomainEvent>>;
    
    /// Get all events in order
    async fn get_all_events(&self) -> Result<Vec<DomainEvent>>;
}

/// In-memory event store (for development/testing)
pub struct InMemoryEventStore {
    // TODO: Implement storage
}

impl InMemoryEventStore {
    pub fn new() -> Self {
        Self {}
    }
}

#[async_trait]
impl EventStore for InMemoryEventStore {
    async fn append_events(
        &self,
        _aggregate_id: &str,
        _aggregate_type: &str,
        _events: Vec<DomainEvent>,
        _expected_version: Option<i64>,
    ) -> Result<()> {
        // TODO: Implement event storage
        Ok(())
    }
    
    async fn load_events(
        &self,
        _aggregate_id: &str,
        _aggregate_type: &str,
    ) -> Result<Vec<DomainEvent>> {
        // TODO: Implement event loading
        Ok(vec![])
    }
    
    async fn get_all_events(&self) -> Result<Vec<DomainEvent>> {
        // TODO: Implement event retrieval
        Ok(vec![])
    }
}
"#;

        let path = format!("{}/src/infrastructure/event_store.rs", self.output_dir);
        fs::write(&path, content)?;

        // Generate infrastructure mod.rs
        let mod_content = "pub mod event_store;\n\npub use event_store::*;\n";
        let mod_path = format!("{}/src/infrastructure/mod.rs", self.output_dir);
        fs::write(&mod_path, mod_content)?;

        // Generate domain mod.rs
        let domain_mod = r#"pub mod entities;
pub mod commands;
pub mod events;

pub use entities::*;
pub use commands::*;
pub use events::*;
"#;
        let domain_mod_path = format!("{}/src/domain/mod.rs", self.output_dir);
        fs::write(&domain_mod_path, domain_mod)?;

        Ok(())
    }

    fn generate_readme(&self, model: &IRModel) -> Result<()> {
        let context_name = &model.bounded_context.name;
        let package_name = to_kebab_case(context_name);

        let content = format!(
            r#"# {} Service

Generated by StormForge Generator

## Description

{}

## Getting Started

### Prerequisites

- Rust 1.75+
- Cargo

### Building

```bash
cargo build
```

### Running

```bash
cargo run
```

The service will start on `http://localhost:3000`

### API Documentation

Once the service is running, visit:

- Swagger UI: `http://localhost:3000/swagger-ui`
- OpenAPI JSON: `http://localhost:3000/api-docs/openapi.json`

## Project Structure

```
{}/
├── src/
│   ├── main.rs              # Application entry point
│   ├── lib.rs               # Library root
│   ├── api/                 # API layer
│   │   └── routes.rs        # HTTP routes and handlers
│   ├── domain/              # Domain layer
│   │   ├── entities.rs      # Domain entities and value objects
│   │   ├── commands.rs      # CQRS commands
│   │   └── events.rs        # Domain events
│   ├── infrastructure/      # Infrastructure layer
│   │   └── event_store.rs   # Event sourcing infrastructure
│   └── repository/          # Repository layer
│       └── mod.rs           # Data persistence
└── Cargo.toml
```

## Architecture

This microservice follows:

- **CQRS** (Command Query Responsibility Segregation)
- **Event Sourcing**
- **Domain-Driven Design** (DDD)
- **Clean Architecture**

## Development

### Running Tests

```bash
cargo test
```

### Running with Watch Mode

```bash
cargo install cargo-watch
cargo watch -x run
```

## License

MIT
"#,
            context_name,
            model
                .bounded_context
                .description
                .as_deref()
                .unwrap_or("Microservice generated from IR model"),
            package_name
        );

        let path = format!("{}/README.md", self.output_dir);
        fs::write(&path, content)?;

        Ok(())
    }
}
