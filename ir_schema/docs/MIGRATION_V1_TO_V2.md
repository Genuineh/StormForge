# IR Schema v1.0 to v2.0 Migration Guide

> Migration guide for upgrading StormForge IR from v1.0 to v2.0
> Date: 2026-04-08
> Sprint: M8

---

## Overview

IR Schema v2.0 introduces significant enhancements to support the Modeler 2.0 upgrade features completed in Sprints M1-M7. This guide helps you migrate existing v1.0 IR files to the new v2.0 format.

## What's New in v2.0

### 1. Entity Definitions
**New Section**: `entities`

Detailed entity modeling with:
- Properties with enhanced metadata
- Methods and behaviors
- Business invariants
- Entity types (entity, aggregate_root, value_object)
- Library references

### 2. Read Model Definitions
**New Section**: `read_models`

Projection definitions with:
- Data sources (multiple entities with joins)
- Field sources (tracking where data comes from)
- Field transformations
- Event subscriptions

### 3. Enhanced Command Definitions
**Enhanced Section**: `commands`

Commands now include:
- Field-level source tracking
- Enhanced payload definitions
- Links to canvas elements
- Data model management

### 4. Connections
**New Section**: `connections`

Visual connections between canvas elements:
- 8 connection types (command→aggregate, aggregate→event, etc.)
- Connection styling
- Source and target references
- Labels and metadata

### 5. Policies
**New Section**: `policies`

Policy definitions:
- Event triggers
- Command actions
- Execution conditions
- Canvas references

### 6. Library References
**New Section**: `library_references`

Track components from global library:
- Enterprise/Organization/Project scope
- Version tracking
- Reference vs Copy usage
- Local ID mapping

### 7. Canvas Metadata
**New Section**: `canvas_metadata`

Canvas visual information:
- Element positions and sizes
- Viewport state (zoom, pan)
- Swimlanes
- Visual styling

### 8. Project Metadata
**New Section**: `project`

Project-level information:
- Project ID and name
- Root namespace
- Version tracking
- Timestamps

---

## Migration Steps

### Step 1: Update Version Number

**v1.0:**
```yaml
version: "1.0"
```

**v2.0:**
```yaml
version: "2.0"
```

### Step 2: Add Project Metadata (Optional)

Add project information at the top level:

```yaml
project:
  id: "my-project-id"
  name: "My Project"
  namespace: "com.example.myproject"
  description: "Project description"
  version: "1.0.0"
  created_at: "2026-03-26T00:00:00Z"
  updated_at: "2026-04-08T00:00:00Z"
```

### Step 3: Create Entity Definitions

Extract entity information from aggregates and create detailed entity definitions:

**v1.0:**
```yaml
aggregates:
  Order:
    name: "Order"
    root_entity:
      name: "Order"
      properties:
        - name: "id"
          type: "OrderId"
          identifier: true
        - name: "status"
          type: "OrderStatus"
    invariants:
      - name: "OrderMustHaveItems"
        expression: "items.length > 0"
```

**v2.0:**
```yaml
entities:
  OrderEntity:
    id: "entity-order-001"
    name: "OrderEntity"
    entity_type: "aggregate_root"
    aggregate_id: "agg-order-001"
    properties:
      - id: "prop-001"
        name: "id"
        type: "OrderId"
        identifier: true
        required: true
        read_only: true
      - id: "prop-002"
        name: "status"
        type: "OrderStatus"
        required: true
    methods:
      - id: "method-001"
        name: "create"
        method_type: "constructor"
        parameters:
          - name: "customerId"
            type: "CustomerId"
    invariants:
      - id: "inv-001"
        name: "OrderMustHaveItems"
        expression: "items.length > 0"
        error_message: "Order must have at least one item"
        enabled: true

aggregates:
  Order:
    name: "Order"
    entity_id: "entity-order-001"  # Reference to EntityDefinition
```

### Step 4: Create Read Models

Define read models for your queries:

```yaml
read_models:
  OrderSummary:
    id: "rm-order-summary-001"
    name: "OrderSummary"
    description: "Summary view of orders"
    sources:
      - entity_id: "entity-order-001"
        alias: "order"
      - entity_id: "entity-customer-001"
        alias: "customer"
        join_type: "left"
        join_condition:
          left_property: "order.customerId"
          right_property: "customer.id"
    fields:
      - name: "orderId"
        type: "OrderId"
        source:
          type: "entity_property"
          entity_id: "entity-order-001"
          property_path: "order.id"
      - name: "customerName"
        type: "String"
        source:
          type: "entity_property"
          entity_id: "entity-customer-001"
          property_path: "customer.name"
    updated_by_events:
      - "OrderCreated"
      - "OrderPaid"
```

### Step 5: Enhance Command Definitions

Add field sources and enhanced metadata:

**v1.0:**
```yaml
commands:
  CreateOrder:
    name: "CreateOrder"
    aggregate: "Order"
    payload:
      - name: "customerId"
        type: "CustomerId"
        required: true
      - name: "items"
        type: "List<OrderItem>"
        required: true
```

**v2.0:**
```yaml
commands:
  CreateOrder:
    id: "cmd-create-order-001"
    name: "CreateOrder"
    aggregate: "Order"
    canvas_element_id: "canvas-cmd-001"
    payload:
      - name: "customerId"
        type: "CustomerId"
        required: true
        source:
          type: "custom"  # UI input
      - name: "items"
        type: "List<OrderItem>"
        required: true
        source:
          type: "custom"  # Shopping cart
```

### Step 6: Add Connections

Define visual connections between components:

```yaml
connections:
  - id: "conn-001"
    type: "command_to_aggregate"
    source_id: "canvas-cmd-001"
    target_id: "agg-order-001"
    label: "Handles"
    
  - id: "conn-002"
    type: "aggregate_to_event"
    source_id: "agg-order-001"
    target_id: "canvas-event-001"
    label: "Produces"
    
  - id: "conn-003"
    type: "event_to_read_model"
    source_id: "canvas-event-001"
    target_id: "canvas-rm-001"
    label: "Updates"
```

### Step 7: Add Policies (if applicable)

Define policies that react to events:

```yaml
policies:
  - id: "policy-001"
    name: "AutoShipWhenPaid"
    triggers:
      - "OrderPaid"
    actions:
      - "ShipOrder"
    conditions:
      - expression: "order.items.all(inStock)"
        message: "All items in stock"
```

### Step 8: Add Library References

Document components from global library:

```yaml
library_references:
  - library_id: "lib-money-v1"
    component_type: "value_object"
    namespace: "com.stormforge.common.Money"
    version: "1.0.0"
    scope: "enterprise"
    usage_type: "reference"
    local_id: "Money"
```

### Step 9: Add Canvas Metadata

Define canvas layout:

```yaml
canvas_metadata:
  viewport:
    zoom: 1.0
    pan_x: 0
    pan_y: 0
  elements:
    - id: "canvas-cmd-001"
      type: "command"
      name: "CreateOrder"
      position:
        x: 100
        y: 200
      size:
        width: 150
        height: 80
      color: "#3399FF"
      definition_id: "cmd-create-order-001"
```

---

## Backward Compatibility

### v1.0 Compatibility

IR v2.0 is designed to be **backward compatible** with v1.0. You can:

1. **Keep v1.0 sections**: All v1.0 sections are still supported
2. **Gradual migration**: Add v2.0 features incrementally
3. **Mixed format**: Use v1.0 and v2.0 features together

### What Works Without Changes

These v1.0 sections work as-is in v2.0:
- `bounded_context`
- `aggregates` (simple form)
- `value_objects`
- `events`
- `commands` (basic form)
- `queries`
- `external_events`

### Required Changes

Only one required change:
- Update `version: "1.0"` to `version: "2.0"`

---

## Migration Checklist

- [ ] Update version to "2.0"
- [ ] Add project metadata (optional)
- [ ] Create entity definitions from aggregates
- [ ] Update aggregate references to entities
- [ ] Create read model definitions
- [ ] Enhance command definitions with sources
- [ ] Add connections between components
- [ ] Add policies (if applicable)
- [ ] Document library references
- [ ] Add canvas metadata
- [ ] Validate against JSON Schema
- [ ] Test with code generators

---

## Validation

Validate your v2.0 IR file using the JSON Schema:

```bash
# Using ajv-cli
ajv validate -s ir_schema/schema/ir_v2.schema.json -d my_context.yaml

# Using online validators
# Upload to: https://www.jsonschemavalidator.net/
```

---

## Code Generator Updates

### Generator Compatibility

Code generators must be updated to support v2.0:

1. **Read entity definitions** for detailed property information
2. **Use read models** for query generation
3. **Track field sources** in command handlers
4. **Generate based on connections** for proper flow
5. **Respect library references** for shared components

### Fallback Behavior

Generators should:
- Support both v1.0 and v2.0 formats
- Fall back to v1.0 behavior when v2.0 features are absent
- Provide warnings for deprecated patterns

---

## Example Migration

See the complete example:
- **v1.0**: `examples/ecommerce/order_context.yaml`
- **v2.0**: `examples/ecommerce/order_context_v2.yaml`

Compare these files to understand the full migration path.

---

## FAQ

### Q: Do I need to migrate immediately?

No. v1.0 files continue to work. Migrate when you need v2.0 features like entity modeling or read models.

### Q: Can I mix v1.0 and v2.0 features?

Yes. Use v2.0 features where needed and keep v1.0 sections unchanged.

### Q: Will my existing generators break?

Generators that only read v1.0 sections will continue to work. They can ignore v2.0 sections they don't understand.

### Q: How do I validate my migration?

1. Use JSON Schema validation
2. Test with updated code generators
3. Review the canvas in Modeler 2.0

### Q: What if I don't use the canvas?

Canvas metadata is optional. You can use v2.0 for entity modeling and read models without canvas features.

---

## Support

For help with migration:
- Check examples in `ir_schema/examples/`
- Review design docs in `docs/designs/`
- See JSON Schema: `ir_schema/schema/ir_v2.schema.json`

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-11-19 | Initial IR schema |
| 2.0 | 2026-04-08 | Entity modeling, read models, connections, policies, library references, canvas metadata |

---

*Last Updated: 2026-04-08*
*Sprint: M8*
