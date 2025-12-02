# StormForge Generator

> Rust code generator for microservices from IR models

## Overview

The StormForge Generator is a Rust CLI tool that reads IR (Intermediate Representation) YAML files and generates complete, production-ready Rust microservices using Axum, sqlx, and Event Sourcing patterns.

## Features (Planned)

- **IR Parsing**: Parse YAML-based IR models
- **Axum Generation**: Generate REST API endpoints
- **Event Sourcing**: Built-in event sourcing infrastructure
- **sqlx Integration**: Type-safe database operations
- **OpenAPI Generation**: utoipa-based API documentation
- **Multi-Service**: Generate multiple microservices from one model

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

> This project is in the initialization phase. Code implementation will follow.

### Prerequisites

- Rust 1.75+
- Cargo

### Building

```bash
cd stormforge_generator
cargo build
```

### Usage

```bash
# Generate from IR file
stormforge-generator generate --input model.yaml --output ./services

# Generate specific context
stormforge-generator generate --input model.yaml --context order --output ./services/order
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
- [ ] IR parser implementation
- [ ] Entity generation
- [ ] Command handler generation
- [ ] Event sourcing infrastructure
- [ ] API endpoint generation
- [ ] Template system

## License

MIT License - See [LICENSE](../LICENSE) for details.
