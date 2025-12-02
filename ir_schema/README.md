# StormForge IR Schema

> Intermediate Representation format for domain models

## Overview

The IR (Intermediate Representation) Schema defines the YAML format used to describe domain models in StormForge. This format serves as the bridge between the visual modeler and code generators.

## Key Concepts

- **Model as Code**: All models stored as version-controllable YAML
- **Bounded Context-centric**: Each context is a separate file
- **Generator-agnostic**: Same IR works for all backend languages
- **Human-readable**: Easy to understand and manually edit if needed

## Project Structure

```
ir_schema/
├── schema/               # JSON Schema definitions
│   ├── ir.schema.json    # Main IR schema
│   └── ...               # Component schemas
├── examples/             # Example IR files
│   ├── ecommerce/        # E-commerce domain
│   └── hr/               # HR domain
└── docs/                 # Specification documentation
```

## Schema Overview

### Root Structure

```yaml
version: "1.0"
project:
  name: "Acme E-commerce"
  namespace: "com.acme"

bounded_contexts:
  - name: Order
    # ... context definition
  - name: Payment
    # ... context definition
```

### Bounded Context

```yaml
bounded_context:
  name: Order
  namespace: acme.order
  description: "Order management context"
  
  aggregates:
    - name: Order
      # ... aggregate definition
  
  events:
    - name: OrderCreated
      # ... event definition
  
  commands:
    - name: CreateOrder
      # ... command definition
```

### Aggregate

```yaml
aggregate:
  name: Order
  root_entity:
    name: Order
    properties:
      - name: id
        type: OrderId
        identifier: true
      - name: customerId
        type: CustomerId
      - name: status
        type: OrderStatus
        
  value_objects:
    - name: OrderItem
      properties:
        - name: productId
          type: ProductId
        - name: quantity
          type: Integer
```

## Examples

See the `examples/` directory for complete IR examples:

- `examples/ecommerce/` - E-commerce domain with Order, Payment, Inventory
- `examples/hr/` - HR domain with Leave management

## Validation

Use the JSON Schema files in `schema/` to validate IR files:

```bash
# Using ajv-cli or similar tool
ajv validate -s schema/ir.schema.json -d model.yaml
```

## Development Status

- [x] Project structure defined
- [ ] JSON Schema v1.0
- [ ] Bounded Context schema
- [ ] Aggregate schema
- [ ] Event schema
- [ ] Command schema
- [ ] E-commerce examples
- [ ] HR examples
- [ ] Specification documentation

## License

MIT License - See [LICENSE](../LICENSE) for details.
