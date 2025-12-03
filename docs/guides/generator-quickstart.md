# StormForge Generator Quick Start Guide

## Installation

### Prerequisites
- Rust 1.75 or higher
- Cargo

### Build from Source

```bash
cd stormforge_generator
cargo build --release
```

The binary will be available at `target/release/stormforge-generator`.

## Basic Usage

### Generate a Microservice

```bash
stormforge-generator generate \
  --input path/to/model.yaml \
  --output path/to/output/directory
```

### Validate an IR File

```bash
stormforge-generator validate \
  --input path/to/model.yaml
```

## Example: E-commerce Order Service

### Step 1: Generate the Service

```bash
cd stormforge_generator

# Build the generator
cargo build --release

# Generate the order service
./target/release/stormforge-generator generate \
  --input ../ir_schema/examples/ecommerce/order_context.yaml \
  --output /tmp/order_service
```

Output:
```
📄 Reading IR file: ../ir_schema/examples/ecommerce/order_context.yaml
✅ IR file parsed successfully
   Bounded Context: Order
   Namespace: acme.order
   Aggregates: 1
   Commands: 5
   Events: 5
   Queries: 3
🚀 Generating Rust microservice for 'Order'...
✅ Generation complete! Output at: /tmp/order_service

🎉 Generation complete!
   Output: /tmp/order_service

📝 Next steps:
   cd /tmp/order_service
   cargo build
   cargo run
```

### Step 2: Build the Generated Service

```bash
cd /tmp/order_service
cargo build
```

This will download dependencies and compile the service (takes ~40 seconds on first build).

### Step 3: Run the Service

```bash
cargo run
```

Output:
```
2025-12-03T01:00:06.634342Z  INFO order: Starting Order service...
2025-12-03T01:00:06.634960Z  INFO order: Listening on http://0.0.0.0:3000
2025-12-03T01:00:06.634988Z  INFO order: Swagger UI available at http://0.0.0.0:3000/swagger-ui
```

### Step 4: Explore the API

Open your browser and navigate to:
- **Swagger UI**: http://localhost:3000/swagger-ui
- **OpenAPI JSON**: http://localhost:3000/api-docs/openapi.json

You'll see automatically generated documentation for all commands and queries:
- POST /api/create-order
- POST /api/confirm-payment
- POST /api/ship-order
- POST /api/deliver-order
- POST /api/cancel-order
- GET /api/get-order
- GET /api/list-orders
- GET /api/get-orders-by-status

## Generated Project Structure

```
order_service/
├── Cargo.toml                 # Dependencies configuration
├── README.md                   # Service documentation
├── src/
│   ├── main.rs                # HTTP server entry point
│   ├── lib.rs                 # Library root
│   ├── api/
│   │   ├── mod.rs
│   │   └── routes.rs          # REST API endpoints
│   ├── domain/
│   │   ├── mod.rs
│   │   ├── entities.rs        # Order, OrderItem, Money, etc.
│   │   ├── commands.rs        # CreateOrder, ShipOrder, etc.
│   │   └── events.rs          # OrderCreated, OrderPaid, etc.
│   ├── infrastructure/
│   │   ├── mod.rs
│   │   └── event_store.rs     # Event sourcing
│   └── repository/
│       └── mod.rs             # Data persistence
└── tests/
```

## Creating Your Own IR Model

### Minimal Example

Create a file `my_model.yaml`:

```yaml
version: "1.0"

bounded_context:
  name: "Product"
  namespace: "myapp.product"
  description: "Product catalog management"

value_objects:
  ProductId:
    name: "ProductId"
    type: "identifier"
    underlying_type: "String"
    format: "uuid"
    prefix: "prod_"

aggregates:
  Product:
    name: "Product"
    description: "Product aggregate"
    root_entity:
      name: "Product"
      properties:
        - name: "id"
          type: "ProductId"
          identifier: true
        - name: "name"
          type: "String"
          required: true
        - name: "price"
          type: "Decimal"
          required: true

events:
  ProductCreated:
    name: "ProductCreated"
    aggregate: "Product"
    payload:
      - name: "productId"
        type: "ProductId"
      - name: "name"
        type: "String"
      - name: "price"
        type: "Decimal"

commands:
  CreateProduct:
    name: "CreateProduct"
    aggregate: "Product"
    payload:
      - name: "name"
        type: "String"
      - name: "price"
        type: "Decimal"
    produces:
      - "ProductCreated"

queries:
  GetProduct:
    name: "GetProduct"
    parameters:
      - name: "productId"
        type: "ProductId"
    returns:
      type: "Product"
```

### Generate and Run

```bash
stormforge-generator generate \
  --input my_model.yaml \
  --output ./my_product_service

cd my_product_service
cargo build
cargo run
```

## Tips

### Development Mode

Use `cargo watch` for automatic recompilation:

```bash
cargo install cargo-watch
cd generated_service
cargo watch -x run
```

### Environment Variables

Configure logging level:

```bash
RUST_LOG=debug cargo run
```

### Testing Generated Code

Run tests in the generated service:

```bash
cd generated_service
cargo test
```

### Production Build

Build optimized binary for production:

```bash
cd generated_service
cargo build --release
./target/release/order  # Run the optimized binary
```

## Common Issues

### Issue: Port 3000 already in use

**Solution**: Change the port in `src/main.rs`:

```rust
let addr = SocketAddr::from(([0, 0, 0, 0], 8080));  // Use port 8080
```

### Issue: Compilation errors in generated code

**Solution**: Check your IR model for:
- Missing value object definitions
- Incorrect type references
- Invalid property names

Use the validate command first:

```bash
stormforge-generator validate --input your_model.yaml
```

## Next Steps

1. **Implement Business Logic**: Add actual command and query handlers
2. **Add Database**: Integrate PostgreSQL with sqlx
3. **Implement Event Store**: Add persistent event storage
4. **Add Tests**: Write unit and integration tests
5. **Deploy**: Package with Docker and deploy to Kubernetes

## More Information

- [Full Documentation](../README.md)
- [IR Schema Reference](../ir_schema/README.md)
- [Architecture Guide](ARCHITECTURE.md)
- [Contributing Guidelines](../CONTRIBUTING.md)
