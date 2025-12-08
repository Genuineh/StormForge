# StormForge IR Specification v2.0

> Intermediate Representation Format for Domain-Driven Design Models with Entity Modeling and Read Models
> Version: 2.0
> Date: 2026-04-08
> Sprint: M8

---

## Introduction

The StormForge IR (Intermediate Representation) v2.0 is a YAML-based format for describing domain models created using EventStorming methodology. This version adds support for detailed entity modeling, read models, visual connections, policies, and global library integration.

### Version History

- **v1.0** (2025-11-19): Initial release with basic EventStorming support
- **v2.0** (2026-04-08): Added entity modeling, read models, connections, policies, library references, and canvas metadata

---

## Design Principles

1. **Human-readable**: IR files should be easily understood and edited by developers
2. **Version-controllable**: Works well with Git and other VCS systems
3. **Generator-agnostic**: Same IR can generate code for any backend language
4. **Complete**: Captures all information needed for code generation
5. **Extensible**: Allows for custom extensions without breaking compatibility
6. **Modular**: Separates concerns (entities, read models, canvas) clearly
7. **Traceable**: Field sources and connections make data flow explicit

---

## What's New in v2.0

### Major Additions

1. **Entity Definitions** (`entities`): Detailed entity modeling with properties, methods, and invariants
2. **Read Model Definitions** (`read_models`): Projections with field sources and multi-entity joins
3. **Enhanced Commands** (`commands`): Field-level source tracking and data model management
4. **Connections** (`connections`): Visual connections between canvas components
5. **Policies** (`policies`): Event-driven policy definitions
6. **Library References** (`library_references`): Global library component tracking
7. **Canvas Metadata** (`canvas_metadata`): Visual layout and positioning
8. **Project Metadata** (`project`): Project-level information and settings

### Backward Compatibility

v2.0 is **backward compatible** with v1.0. All v1.0 features continue to work, and v2.0 features are optional additions.

---

## File Organization

### Project Structure

```
project/
├── stormforge.yaml              # Project configuration
├── contexts/
│   ├── order_context.yaml       # Order Bounded Context (v2.0)
│   ├── payment_context.yaml     # Payment Bounded Context (v2.0)
│   └── ...
├── entities/                    # Optional: Separate entity files
│   ├── order_entity.yaml
│   └── customer_entity.yaml
├── read_models/                 # Optional: Separate read model files
│   ├── order_summary.yaml
│   └── order_details.yaml
└── library/                     # Local library components
    └── custom_types.yaml
```

### Naming Conventions

- Context files: `{context_name}_context.yaml`
- Entity files: `{entity_name}_entity.yaml`
- Read model files: `{model_name}.yaml`
- File names: lowercase with underscores
- Type names: PascalCase
- Property names: camelCase
- Enum values: SCREAMING_SNAKE_CASE

---

## Schema Reference

### Root Structure

```yaml
version: "2.0"                   # Required: IR version

project:                         # Optional: Project metadata
  id: "project-uuid"
  name: "Project Name"
  namespace: "com.example"
  description: "..."
  version: "1.0.0"
  created_at: "2026-03-26T00:00:00Z"
  updated_at: "2026-04-08T00:00:00Z"

bounded_context:                 # Required: Context definition
  name: "Order"
  namespace: "acme.order"
  description: "..."

entities: {}                     # Optional: Entity definitions
aggregates: {}                   # Optional: Aggregate definitions
value_objects: {}                # Optional: Value object definitions
events: {}                       # Optional: Event definitions
commands: {}                     # Optional: Command definitions
read_models: {}                  # Optional: Read model definitions
queries: {}                      # Optional: Query definitions
policies: []                     # Optional: Policy definitions
external_events: []              # Optional: External subscriptions
connections: []                  # Optional: Visual connections
library_references: []           # Optional: Library component refs
canvas_metadata: {}              # Optional: Canvas layout
```

---

## Entity Definitions

Detailed entity modeling with properties, methods, and invariants.

### Entity Structure

```yaml
entities:
  OrderEntity:
    id: "entity-order-001"                    # Unique identifier
    name: "OrderEntity"                       # Entity name
    description: "Order aggregate root"       # Description
    entity_type: "aggregate_root"             # Type: entity, aggregate_root, value_object
    aggregate_id: "agg-order-001"             # Link to canvas aggregate
    library_reference: "lib-id"               # Optional: From global library
    
    properties:                               # Entity properties
      - id: "prop-001"
        name: "id"
        type: "OrderId"
        identifier: true                      # Is this the ID?
        required: true                        # Is it required?
        read_only: true                       # Is it read-only?
        description: "Unique identifier"
        validation:                           # Validation rules
          pattern: "^ord_[a-f0-9-]+$"
        
      - id: "prop-002"
        name: "status"
        type: "OrderStatus"
        required: true
        default: "CREATED"
        
      - id: "prop-003"
        name: "totalAmount"
        type: "Money"
        required: true
        computed: "sum(items.subtotal)"       # Computed property
    
    methods:                                  # Entity methods
      - id: "method-001"
        name: "create"
        method_type: "constructor"            # constructor, command, query, domain_logic
        description: "Create new order"
        parameters:
          - name: "customerId"
            type: "CustomerId"
            required: true
        visibility: "public"                  # public, private, protected
        
      - id: "method-002"
        name: "addItem"
        method_type: "domain_logic"
        return_type: "void"
        parameters:
          - name: "item"
            type: "OrderItem"
    
    invariants:                               # Business invariants
      - id: "inv-001"
        name: "OrderMustHaveItems"
        expression: "items.length > 0"
        error_message: "Order must have at least one item"
        enabled: true
```

### Entity Property Types

Properties support these attributes:
- `id`: Unique property identifier
- `name`: Property name (camelCase)
- `type`: Property type (any valid type)
- `identifier`: Boolean - is this the entity ID?
- `required`: Boolean - is it required?
- `read_only`: Boolean - is it read-only?
- `default`: Default value
- `description`: Property description
- `validation`: Validation rules (see Validation section)
- `computed`: Expression for computed properties

### Entity Method Types

- `constructor`: Entity creation methods
- `command`: Methods that change state
- `query`: Methods that query state
- `domain_logic`: Business logic methods

---

## Read Model Definitions

Projections that define what data is exposed to the UI/API.

### Read Model Structure

```yaml
read_models:
  OrderSummary:
    id: "rm-order-summary-001"
    name: "OrderSummary"
    description: "Summary view of orders"
    canvas_element_id: "canvas-rm-001"        # Link to canvas element
    
    sources:                                  # Data sources
      - entity_id: "entity-order-001"         # Entity to pull from
        alias: "order"                        # Alias for queries
        # Primary source has no join
        
      - entity_id: "entity-customer-001"
        alias: "customer"
        join_type: "left"                     # inner, left, right
        join_condition:
          left_property: "order.customerId"
          right_property: "customer.id"
          operator: "equals"                  # equals, not_equals, etc.
    
    fields:                                   # Fields in read model
      - name: "orderId"
        type: "OrderId"
        source:
          type: "entity_property"             # Field source type
          entity_id: "entity-order-001"
          property_path: "order.id"
        description: "Order identifier"
        
      - name: "customerName"
        type: "String"
        source:
          type: "entity_property"
          entity_id: "entity-customer-001"
          property_path: "customer.name"
          
      - name: "itemCount"
        type: "Integer"
        source:
          type: "computed"                    # Computed field
          expression: "order.items.length"
          
      - name: "formattedTotal"
        type: "String"
        source:
          type: "entity_property"
          entity_id: "entity-order-001"
          property_path: "order.totalAmount"
        transformation: "formatMoney(order.totalAmount)"  # Transform
    
    updated_by_events:                        # Events that update this
      - "OrderCreated"
      - "OrderPaid"
      - "OrderShipped"
```

### Field Source Types

- `entity_property`: Field from entity property
- `computed`: Computed from expression
- `constant`: Constant value
- `read_model`: From another read model
- `custom`: Custom source (e.g., from external API)

### Join Types

- `inner`: Inner join (only matching records)
- `left`: Left join (all left + matching right)
- `right`: Right join (all right + matching left)

---

## Enhanced Command Definitions

Commands with field-level source tracking.

### Command Structure

```yaml
commands:
  CreateOrder:
    id: "cmd-create-order-001"
    name: "CreateOrder"
    description: "Create a new order"
    aggregate: "Order"                        # Target aggregate
    canvas_element_id: "canvas-cmd-001"       # Canvas element
    
    payload:                                  # Command payload
      - name: "customerId"
        type: "CustomerId"
        required: true
        description: "Customer placing order"
        source:
          type: "custom"                      # From UI input
        validation:
          pattern: "^cust_[a-f0-9-]+$"
          
      - name: "items"
        type: "List<OrderItem>"
        required: true
        source:
          type: "custom"                      # From shopping cart
        validation:
          minLength: 1
          maxLength: 50
          
      - name: "shippingAddress"
        type: "Address"
        required: true
        source:
          type: "read_model"                  # From saved addresses
          read_model_id: "rm-customer-addresses"
          property_path: "defaultAddress"
    
    produces:                                 # Events produced
      - "OrderCreated"
    
    validation:                               # Command validation
      - expression: "items.length > 0"
        message: "Must have at least one item"
    
    preconditions:                            # Preconditions
      - expression: "customer.isActive"
        message: "Customer must be active"
```

---

## Connections

Visual connections between canvas components.

### Connection Structure

```yaml
connections:
  - id: "conn-001"
    type: "command_to_aggregate"              # Connection type
    source_id: "canvas-cmd-001"               # Source element
    target_id: "agg-order-001"                # Target element
    label: "Handles"                          # Optional label
    style:                                    # Optional styling
      color: "#3399FF"
      stroke_width: 2.0
      line_style: "dashed"                    # solid, dashed, dotted
      arrow_style: "filled"                   # filled, open, none
    metadata: {}                              # Custom metadata
```

### Connection Types

1. `command_to_aggregate`: Command → Aggregate
2. `aggregate_to_event`: Aggregate → Event
3. `event_to_policy`: Event → Policy
4. `policy_to_command`: Policy → Command
5. `event_to_read_model`: Event → Read Model
6. `external_to_command`: External System → Command
7. `ui_to_command`: UI → Command
8. `read_model_to_ui`: Read Model → UI
9. `custom`: Custom connection type

---

## Policies

Event-driven policies that trigger commands.

### Policy Structure

```yaml
policies:
  - id: "policy-auto-ship-001"
    name: "AutoShipWhenPaid"
    description: "Auto ship when order is paid"
    canvas_element_id: "canvas-policy-001"
    
    triggers:                                 # Events that trigger
      - "OrderPaid"
    
    actions:                                  # Commands to execute
      - "PrepareShipment"
    
    conditions:                               # Execution conditions
      - expression: "order.items.all(inStock)"
        message: "All items must be in stock"
```

---

## Library References

Track components imported from global library.

### Library Reference Structure

```yaml
library_references:
  - library_id: "lib-money-v1"                # Library component ID
    component_type: "value_object"            # Component type
    namespace: "com.stormforge.common.Money"  # Full namespace
    version: "1.0.0"                          # Semantic version
    scope: "enterprise"                       # enterprise, organization, project
    usage_type: "reference"                   # reference or copy
    local_id: "Money"                         # Local name/ID
```

### Component Types

- `entity`: Entity definition
- `value_object`: Value object
- `enum`: Enumeration
- `aggregate`: Aggregate
- `command`: Command definition
- `event`: Event definition
- `read_model`: Read model
- `policy`: Policy

### Library Scopes

- `enterprise`: Global - available to all users
- `organization`: Company-wide
- `project`: Project-specific

### Usage Types

- `reference`: Reference to library (stays in sync)
- `copy`: Local copy (independent of library)

---

## Canvas Metadata

Visual layout information for the canvas.

### Canvas Structure

```yaml
canvas_metadata:
  viewport:                                   # Viewport state
    zoom: 1.0
    pan_x: 0
    pan_y: 0
  
  elements:                                   # Canvas elements
    - id: "canvas-cmd-001"
      type: "command"                         # Element type
      name: "CreateOrder"
      position:
        x: 100
        y: 200
      size:
        width: 150
        height: 80
      color: "#3399FF"
      definition_id: "cmd-create-order-001"   # Link to definition
  
  swimlanes:                                  # Swimlanes
    - id: "swimlane-order"
      name: "Order Context"
      bounded_context: "Order"
      position: 0
      height: 600
```

### Canvas Element Types

- `domain_event`: Domain event (orange)
- `command`: Command (blue)
- `aggregate`: Aggregate (yellow)
- `policy`: Policy (purple)
- `read_model`: Read model (green)
- `external_system`: External system (pink)
- `ui`: UI element (white)

---

## Validation Rules

Validation rules for properties and fields.

```yaml
validation:
  # Numeric validations
  min: 0                         # Minimum value
  max: 100                       # Maximum value
  precision: 2                   # Decimal precision
  
  # String validations
  minLength: 1                   # Minimum length
  maxLength: 255                 # Maximum length
  pattern: "^[A-Z]{3}$"          # Regex pattern
  
  # Format validations
  email: true                    # Must be valid email
  url: true                      # Must be valid URL
```

---

## Complete Example

See `examples/ecommerce/order_context_v2.yaml` for a complete v2.0 example demonstrating all features.

---

## Best Practices

### 1. Organize by Bounded Context

One IR file per bounded context. Keep related entities, commands, and events together.

### 2. Use Descriptive Names

- Entities: `OrderEntity`, `CustomerEntity`
- Commands: `CreateOrder`, `ConfirmPayment`
- Events: `OrderCreated`, `OrderPaid`
- Read Models: `OrderSummary`, `OrderDetails`

### 3. Document Field Sources

Always specify where command and read model fields come from for better code generation and understanding.

### 4. Define Entity Methods

Include key methods in entity definitions to guide implementation generation.

### 5. Use Library Components

Leverage global library for common types like Money, Address, Email to maintain consistency.

### 6. Keep Canvas Metadata Separate

Canvas metadata is optional. You can have entity/read model definitions without canvas info.

### 7. Version Everything

Use semantic versioning for library components and track project versions.

---

## Tooling Support

### Validation

```bash
# Validate IR file against JSON Schema
ajv validate -s ir_schema/schema/ir_v2.schema.json -d my_context.yaml
```

### Code Generation

```bash
# Generate Rust microservice
stormforge generate rust --input order_context.yaml --output ./generated/rust

# Generate Dart API package
stormforge generate dart --input order_context.yaml --output ./generated/dart
```

### Visualization

```bash
# Open in Modeler 2.0
stormforge modeler order_context.yaml
```

---

## Migration from v1.0

See `docs/MIGRATION_V1_TO_V2.md` for detailed migration guide.

### Quick Migration

1. Change version: `version: "2.0"`
2. Add project metadata (optional)
3. Create entity definitions
4. Define read models
5. Enhance commands with sources
6. Add connections (optional)
7. Add canvas metadata (optional)

---

## References

- JSON Schema: `schema/ir_v2.schema.json`
- Examples: `examples/ecommerce/order_context_v2.yaml`
- Migration Guide: `docs/MIGRATION_V1_TO_V2.md`
- Design Documents: `../docs/designs/`

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-11-19 | Initial IR schema with EventStorming support |
| 2.0 | 2026-04-08 | Entity modeling, read models, connections, policies, library references, canvas metadata |

---

*Last Updated: 2026-04-08*
*Sprint: M8 - IR Schema v2.0*
