# Entity Modeling System Design

> Detailed design for the dedicated entity modeling system in StormForge Modeler 2.0
> Version: 1.0
> Date: 2025-12-03

---

## Overview

The Entity Modeling System provides a dedicated interface for defining entity objects with their properties, methods, and business rules. This separates the concerns of visual modeling (canvas) from detailed entity definition.

## Key Features

1. **Dedicated Entity Editor** - Separate UI for defining entities with properties, methods, and invariants
2. **Aggregate-Entity Linking** - Canvas aggregates reference detailed entity definitions
3. **Property Management** - Define properties with types, validations, and metadata
4. **Method Definitions** - Define entity methods and behaviors
5. **Business Rules** - Define invariants that must always hold true
6. **Reusability** - Entities can be referenced across multiple aggregates

## Data Model

```dart
class EntityDefinition {
  final String id;
  final String projectId;
  final String name;
  final String? description;
  final String? aggregateId; // Link to canvas aggregate
  final EntityType entityType;
  final List<EntityProperty> properties;
  final List<EntityMethod> methods;
  final List<EntityInvariant> invariants;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class EntityProperty {
  final String id;
  final String name;
  final String type; // Reference to TypeDefinition or global library
  final bool required;
  final bool isIdentifier;
  final bool isReadOnly;
  final dynamic defaultValue;
  final String? description;
  final List<ValidationRule> validations;
}

class ValidationRule {
  final ValidationType type; // required, minLength, maxLength, pattern, etc.
  final dynamic value;
  final String? errorMessage;
}

class EntityMethod {
  final String id;
  final String name;
  final MethodType type; // constructor, command, query, domainLogic
  final String returnType;
  final List<MethodParameter> parameters;
  final String? description;
}

class EntityInvariant {
  final String id;
  final String name;
  final String expression; // Boolean expression
  final String errorMessage;
  final bool enabled;
}
```

## UI Layout

```
┌────────────────────────────────────────────────────────┐
│ Entity Editor                                          │
├───────────────┬────────────────────────────────────────┤
│ Entity Tree   │ Entity Details                         │
│               │                                        │
│ ◉ OrderEntity │ Name: [OrderEntity              ]     │
│   ├─ Properties Description: [Order aggregate root]   │
│   ├─ Methods  │                                        │
│   └─ Invariants Properties:                            │
│ ◎ Customer   │ ┌──────────────────────────────────┐  │
│   └─ Props   │ │ Name     Type      Required  ID  │  │
│ [+ New]      │ │ id       OrderId   ☑         ☑   │  │
│               │ │ items    List<...> ☑         ☐   │  │
│               │ │ status   OrderSt.. ☑         ☐   │  │
│               │ └──────────────────────────────────┘  │
│               │ [+ Add Property]                      │
└───────────────┴────────────────────────────────────────┘
```

## Key Interactions

1. **Create Entity**: Click "+ New" in entity tree
2. **Edit Properties**: Select entity → Edit in property grid
3. **Link to Aggregate**: Double-click aggregate on canvas → Select entity
4. **Add Validation**: Select property → Add validation rule
5. **Define Invariant**: Switch to Invariants tab → Add rule

## Database Schema (MongoDB Collections)

```javascript
// Entities collection
{
  _id: ObjectId,
  project_id: ObjectId,
  name: String,
  description: String,
  aggregate_id: String,  // Canvas aggregate reference
  entity_type: String,  // 'entity' | 'aggregateRoot' | 'valueObject'
  created_at: ISODate,
  updated_at: ISODate
}
// Unique index: { project_id: 1, name: 1 }

// Entity properties collection
{
  _id: ObjectId,
  entity_id: ObjectId,
  name: String,
  type: String,
  required: Boolean,
  is_identifier: Boolean,
  is_read_only: Boolean,
  default_value: Mixed,
  description: String,
  display_order: Number,
  validations: [
    {
      validation_type: String,
      value: Mixed,
      error_message: String
    }
  ]
}
// Unique index: { entity_id: 1, name: 1 }

// Entity methods collection
{
  _id: ObjectId,
  entity_id: ObjectId,
  name: String,
  method_type: String,  // 'constructor' | 'command' | 'query' | 'domainLogic'
  return_type: String,
  description: String,
  parameters: [
    {
      name: String,
      type: String,
      required: Boolean,
      default_value: Mixed
    }
  ]
}
// Unique index: { entity_id: 1, name: 1 }

// Entity invariants collection
{
  _id: ObjectId,
  entity_id: ObjectId,
  name: String,
  expression: String,
  error_message: String,
  enabled: Boolean
}
```

## Integration with Canvas

When an aggregate element is placed on the canvas:

1. User can right-click → "Edit Entity Definition"
2. Opens Entity Editor with linked entity (or creates new one)
3. Changes to entity are reflected in aggregate label
4. Aggregate properties show entity summary

```dart
class AggregateElement extends CanvasElement {
  final String? entityId; // Link to entity definition
  
  @override
  String get label {
    // If linked to entity, show entity name
    if (entityId != null) {
      final entity = entityService.getEntity(entityId);
      return entity?.name ?? super.label;
    }
    return super.label;
  }
}
```

## Service Layer

```dart
class EntityService {
  // CRUD operations
  Future<EntityDefinition> createEntity(CreateEntityRequest request);
  Future<EntityDefinition> updateEntity(String id, UpdateEntityRequest request);
  Future<void> deleteEntity(String id);
  Future<EntityDefinition?> findById(String id);
  Future<List<EntityDefinition>> listForProject(String projectId);
  
  // Property operations
  Future<EntityDefinition> addProperty(String entityId, EntityProperty property);
  Future<EntityDefinition> updateProperty(String entityId, String propId, EntityProperty property);
  Future<EntityDefinition> removeProperty(String entityId, String propId);
  
  // Method operations
  Future<EntityDefinition> addMethod(String entityId, EntityMethod method);
  Future<EntityDefinition> updateMethod(String entityId, String methodId, EntityMethod method);
  Future<EntityDefinition> removeMethod(String entityId, String methodId);
  
  // Invariant operations
  Future<EntityDefinition> addInvariant(String entityId, EntityInvariant invariant);
  Future<EntityDefinition> updateInvariant(String entityId, String invId, EntityInvariant invariant);
  Future<EntityDefinition> removeInvariant(String entityId, String invId);
  
  // Validation
  Future<ValidationResult> validateEntity(EntityDefinition entity);
  Future<List<EntityDefinition>> findReferences(String entityId);
}
```

## Examples

### Example 1: Order Entity

```dart
EntityDefinition(
  name: 'Order',
  entityType: EntityType.aggregateRoot,
  properties: [
    EntityProperty(
      name: 'id',
      type: 'OrderId',
      required: true,
      isIdentifier: true,
    ),
    EntityProperty(
      name: 'customerId',
      type: 'CustomerId',
      required: true,
    ),
    EntityProperty(
      name: 'items',
      type: 'List<OrderItem>',
      required: true,
      validations: [
        ValidationRule(
          type: ValidationType.minLength,
          value: 1,
          errorMessage: 'Order must have at least one item',
        ),
      ],
    ),
    EntityProperty(
      name: 'status',
      type: 'OrderStatus',
      required: true,
      defaultValue: 'CREATED',
    ),
    EntityProperty(
      name: 'totalAmount',
      type: 'Money',
      required: true,
    ),
  ],
  methods: [
    EntityMethod(
      name: 'calculateTotal',
      type: MethodType.query,
      returnType: 'Money',
      description: 'Calculates the total amount from items',
    ),
    EntityMethod(
      name: 'addItem',
      type: MethodType.command,
      returnType: 'void',
      parameters: [
        MethodParameter(name: 'item', type: 'OrderItem', required: true),
      ],
    ),
  ],
  invariants: [
    EntityInvariant(
      name: 'OrderMustHaveItems',
      expression: 'items.length > 0',
      errorMessage: 'Order must have at least one item',
    ),
    EntityInvariant(
      name: 'TotalMustBePositive',
      expression: 'totalAmount.amount > 0',
      errorMessage: 'Total amount must be positive',
    ),
  ],
)
```

## Testing Strategy

### Unit Tests
- Entity validation logic
- Property validation rules
- Method signature validation
- Invariant expression parsing

### Integration Tests
- CRUD operations
- Canvas synchronization
- Reference tracking
- Import/export

### UI Tests
- Entity tree navigation
- Property editor
- Method editor
- Validation rules

---

*This design will be refined during implementation.*
