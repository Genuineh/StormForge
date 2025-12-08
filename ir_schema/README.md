# StormForge IR Schema

> Intermediate Representation format for domain models

## Overview

The IR (Intermediate Representation) Schema defines the YAML format used to describe domain models in StormForge. This format serves as the bridge between the visual modeler and code generators.

### Current Version: 2.0

**Version 2.0** (Released: 2026-04-08) adds support for:
- Detailed entity modeling with properties, methods, and invariants
- Read model definitions with field sources and multi-entity joins
- Enhanced command data models with source tracking
- Visual connections between canvas components
- Event-driven policies
- Global library component references
- Canvas metadata and layout information

**Version 1.0** continues to be supported for backward compatibility.

## Key Concepts

- **Model as Code**: All models stored as version-controllable YAML
- **Bounded Context-centric**: Each context is a separate file
- **Generator-agnostic**: Same IR works for all backend languages
- **Human-readable**: Easy to understand and manually edit if needed
- **Entity-First**: Detailed entity modeling separates concerns from canvas
- **Traceable**: Field sources make data flow explicit

## Project Structure

```
ir_schema/
├── schema/                      # JSON Schema definitions
│   ├── ir.schema.json           # IR v1.0 schema
│   ├── ir_v2.schema.json        # IR v2.0 schema (NEW)
│   └── ...                      # Component schemas
├── examples/                    # Example IR files
│   ├── ecommerce/
│   │   ├── order_context.yaml       # v1.0 example
│   │   ├── order_context_v2.yaml    # v2.0 example (NEW)
│   │   ├── payment_context.yaml
│   │   └── inventory_context.yaml
│   └── hr/
│       └── leave_context.yaml
└── docs/                        # Specification documentation
    ├── ir_specification.md      # v1.0 specification
    ├── ir_v2_specification.md   # v2.0 specification (NEW)
    └── MIGRATION_V1_TO_V2.md    # Migration guide (NEW)
```

## Schema Overview

### Version 2.0 Root Structure (Recommended)

```yaml
version: "2.0"

project:
  id: "project-id"
  name: "Acme E-commerce"
  namespace: "com.acme"

bounded_context:
  name: Order
  namespace: acme.order
  description: "Order management"

# NEW in v2.0: Detailed entity modeling
entities:
  OrderEntity:
    name: "OrderEntity"
    entity_type: "aggregate_root"
    properties:
      - name: id
        type: OrderId
        identifier: true
      - name: status
        type: OrderStatus
    methods:
      - name: create
        method_type: constructor
    invariants:
      - name: "OrderMustHaveItems"
        expression: "items.length > 0"

# NEW in v2.0: Read model definitions
read_models:
  OrderSummary:
    sources:
      - entity_id: "OrderEntity"
        alias: "order"
    fields:
      - name: orderId
        source:
          type: entity_property
          property_path: "order.id"

# NEW in v2.0: Enhanced commands with sources
commands:
  CreateOrder:
    payload:
      - name: customerId
        type: CustomerId
        source:
          type: custom  # From UI

# NEW in v2.0: Visual connections
connections:
  - type: command_to_aggregate
    source_id: "cmd-create-order"
    target_id: "agg-order"

# NEW in v2.0: Canvas metadata
canvas_metadata:
  elements:
    - id: "cmd-create-order"
      type: command
      position: { x: 100, y: 200 }
```

### Version 1.0 (Still Supported)

```yaml
version: "1.0"

bounded_context:
  name: Order
  namespace: acme.order

aggregates:
  Order:
    root_entity:
      name: Order
      properties:
        - name: id
          type: OrderId

commands:
  CreateOrder:
    payload:
      - name: customerId
        type: CustomerId
```

## Examples

See the `examples/` directory for complete IR examples:

### Version 2.0 Examples
- `examples/ecommerce/order_context_v2.yaml` - Full v2.0 example with entities, read models, connections

### Version 1.0 Examples
- `examples/ecommerce/order_context.yaml` - Order context
- `examples/ecommerce/payment_context.yaml` - Payment context
- `examples/ecommerce/inventory_context.yaml` - Inventory context
- `examples/hr/leave_context.yaml` - HR Leave management

## Validation

Use the JSON Schema files in `schema/` to validate IR files:

```bash
# Validate v2.0 IR file
ajv validate -s schema/ir_v2.schema.json -d model_v2.yaml

# Validate v1.0 IR file
ajv validate -s schema/ir.schema.json -d model_v1.yaml
```

## Version Status

### Version 2.0 (Current) ✅
- [x] JSON Schema v2.0
- [x] Entity definitions with properties, methods, invariants
- [x] Read model definitions with field sources
- [x] Enhanced command data models
- [x] Visual connections between components
- [x] Policy definitions
- [x] Library component references
- [x] Canvas metadata and layout
- [x] Project metadata
- [x] Complete v2.0 example
- [x] Migration guide from v1.0
- [x] v2.0 specification documentation

### Version 1.0 (Stable) ✅
- [x] JSON Schema v1.0
- [x] Bounded Context schema
- [x] Aggregate schema
- [x] Event schema
- [x] Command schema
- [x] Query schema
- [x] E-commerce examples
- [x] HR examples
- [x] Specification documentation

## Documentation

- **v2.0 Specification**: [docs/ir_v2_specification.md](docs/ir_v2_specification.md)
- **v1.0 Specification**: [docs/ir_specification.md](docs/ir_specification.md)
- **Migration Guide**: [docs/MIGRATION_V1_TO_V2.md](docs/MIGRATION_V1_TO_V2.md)
- **Design Documents**: [../docs/designs/](../docs/designs/)
  - [Entity Modeling System](../docs/designs/entity_modeling_system.md)
  - [Read Model Designer](../docs/designs/read_model_designer.md)
  - [Connection System](../docs/designs/connection_system.md)
  - [Global Library](../docs/designs/global_library.md)

## Getting Started

### For New Projects
Use IR v2.0 for full feature support:
```bash
# Start with v2.0 template
cp examples/ecommerce/order_context_v2.yaml my_context.yaml
# Edit your context
# Validate
ajv validate -s schema/ir_v2.schema.json -d my_context.yaml
```

### For Existing v1.0 Projects
Migrate gradually:
1. Review [Migration Guide](docs/MIGRATION_V1_TO_V2.md)
2. Update version to "2.0"
3. Add new features as needed (optional)
4. Validate with v2.0 schema

## License

MIT License - See [LICENSE](../LICENSE) for details.
