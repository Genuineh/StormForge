# StormForge Examples

> Complete working examples demonstrating StormForge capabilities

## Available Examples

### 1. Acme E-commerce

A complete e-commerce domain with multiple bounded contexts:

- **Order Context**: Order management and lifecycle
- **Payment Context**: Payment processing
- **Inventory Context**: Stock management

See: [`ir_schema/examples/ecommerce/`](../../ir_schema/examples/ecommerce/)

### 2. HR Leave System

A simple HR leave management system:

- **Leave Context**: Leave request handling

See: [`ir_schema/examples/hr/`](../../ir_schema/examples/hr/)

## Running Examples

> Note: Examples will be runnable once the generators are implemented.

### Generating Code

```bash
# Generate Rust microservices
stormforge generate --input ir_schema/examples/ecommerce/ --output generated/rust --target rust

# Generate Dart packages
stormforge generate --input ir_schema/examples/ecommerce/ --output generated/dart --target dart
```

### Running Generated Services

```bash
# Run order service
cd generated/rust/acme_order_service
cargo run

# Run payment service
cd generated/rust/acme_payment_service
cargo run
```

### Using Generated Dart Packages

```dart
// In your Flutter app
dependencies:
  acme_order_service:
    path: ../generated/dart/acme_order_service
  acme_payment_service:
    path: ../generated/dart/acme_payment_service
```

## Example Scenarios

### E-commerce: Order Flow

1. Customer creates an order
2. Payment is initiated
3. Stock is reserved
4. Payment is completed
5. Order status updated to PAID
6. Order is shipped
7. Stock is deducted
8. Order is delivered

### HR: Leave Request Flow

1. Employee submits leave request
2. Manager receives notification
3. Manager approves/rejects request
4. Employee receives notification
5. Leave is added to calendar

## Creating Your Own Examples

1. Copy an existing example directory
2. Modify the YAML files to match your domain
3. Run the generator to create code
4. Test the generated services

---

*More examples will be added as the project develops.*
