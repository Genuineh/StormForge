# StormForge Generator

> Rust code generator for microservices from IR models

## Overview

The StormForge Generator is a Rust CLI tool that reads IR (Intermediate Representation) YAML files and generates complete, production-ready Rust microservices using Axum, sqlx, and Event Sourcing patterns.

## Features (Planned)

- **IR Parsing**: Parse YAML-based IR models ✅
- **Axum Generation**: Generate REST API endpoints ✅
- **Event Sourcing**: Built-in event sourcing infrastructure ✅
- **sqlx Integration**: Type-safe database operations (foundation ready)
- **OpenAPI Generation**: utoipa-based API documentation ✅
- **Multi-Service**: Generate multiple microservices from one model (planned)

## What Gets Generated

For each IR model, the generator creates a complete Rust microservice with:

### Domain Layer
- **Entities**: Type-safe structs for aggregates and entities
- **Value Objects**: Strongly-typed value objects including enums and identifiers
- **Commands**: CQRS command structures with validation
- **Events**: Domain events with metadata and event envelope
- **Command Handlers**: Trait definition for command processing

### API Layer
- **REST Endpoints**: Axum-based HTTP handlers for commands and queries
- **OpenAPI Documentation**: Auto-generated Swagger UI and API documentation
- **Error Handling**: Structured error responses

### Infrastructure Layer
- **Event Store**: Event sourcing infrastructure with append and replay capabilities
- **Repository Pattern**: Generic repository trait with in-memory implementation

### Project Files
- **Cargo.toml**: Complete dependencies configuration
- **main.rs**: Application entry point with server setup
- **README.md**: Service-specific documentation

## Project Structure

```
stormforge_generator/
├── src/
│   ├── ir/               # IR parser and types
│   ├── generators/       # Code generation logic
│   │   ├── rust/         # Rust-specific generators
│   │   └── common/       # Shared utilities
│   ├── templates/        # Code templates (Tera)
│   │   ├── axum/         # Axum project templates
│   │   └── sqlx/         # Database templates
│   └── output/           # File output handling
└── tests/                # Integration tests
```

## Getting Started

### Prerequisites

- Rust 1.75+
- Cargo

### Building

```bash
cd stormforge_generator
cargo build --release
```

### Usage

```bash
# Generate from IR file
./target/release/stormforge-generator generate --input ../ir_schema/examples/ecommerce/order_context.yaml --output ./generated_service

# Validate IR file without generating code
./target/release/stormforge-generator validate --input model.yaml
```

### Example

Generate a microservice from the example order context:

```bash
# Generate the service
cargo build --release
./target/release/stormforge-generator generate \
  --input ../ir_schema/examples/ecommerce/order_context.yaml \
  --output /tmp/order_service

# Build and run the generated service
cd /tmp/order_service
cargo build
cargo run

# Service will start on http://localhost:3000
# Swagger UI available at http://localhost:3000/swagger-ui
```

## Generated Project Structure

```
generated_service/
├── Cargo.toml
├── src/
│   ├── main.rs
│   ├── api/
│   │   ├── mod.rs
│   │   └── routes.rs
│   ├── domain/
│   │   ├── mod.rs
│   │   ├── entities.rs
│   │   ├── events.rs
│   │   └── commands.rs
│   ├── repository/
│   │   └── mod.rs
│   └── infrastructure/
│       └── mod.rs
└── migrations/
```

## Development Status

- [x] Project structure defined
- [x] IR parser implementation
- [x] Entity generation
- [x] Command handler generation
- [x] Event sourcing infrastructure
- [x] API endpoint generation
- [x] Template system
- [x] Cargo.toml generation with all dependencies
- [x] OpenAPI/Swagger documentation
- [x] Repository pattern
- [x] Event store infrastructure

## License

MIT License - See [LICENSE](../LICENSE) for details.
