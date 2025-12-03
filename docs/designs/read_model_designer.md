# Read Model Designer Design

> Design specification for the read model field selection and management system
> Version: 1.0
> Date: 2025-12-03

---

## Overview

The Read Model Designer allows users to create read models (projections) by selecting and transforming fields from one or more entity objects. This enables proper separation between write models (entities) and read models (views).

## Concept

**Read Models** are projections that:
- Select specific fields from entities
- Can join multiple entities
- Apply transformations (rename, compute, aggregate)
- Define what data is exposed to the UI
- Are updated by domain events

## Architecture

```
ReadModelDesigner
├── ReadModelDefinition (Data model)
├── FieldSelector (UI for selecting fields)
├── TransformBuilder (UI for field transforms)
├── JoinEditor (UI for multi-entity joins)
├── PreviewGenerator (Shows resulting structure)
└── EventLinker (Links to updating events)
```

## Data Model

```dart
class ReadModelDefinition extends Equatable {
  final String id;
  final String projectId;
  final String name;
  final String? description;
  final List<DataSource> sources;
  final List<ReadModelField> fields;
  final List<String> updatedByEvents; // Event IDs
  final ReadModelMetadata metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Validation
  bool isValid() {
    return name.isNotEmpty &&
           sources.isNotEmpty &&
           fields.isNotEmpty &&
           !hasDuplicateFieldNames();
  }
  
  // Get all entity dependencies
  Set<String> get entityDependencies {
    return sources.map((s) => s.entityId).toSet();
  }
}

class DataSource extends Equatable {
  final String entityId;
  final String alias;
  final JoinCondition? joinCondition; // null for primary source
  final JoinType joinType;
  
  const DataSource({
    required this.entityId,
    required this.alias,
    this.joinCondition,
    this.joinType = JoinType.inner,
  });
}

enum JoinType {
  inner,
  left,
  right,
}

class JoinCondition extends Equatable {
  final String leftProperty;  // e.g., "order.customerId"
  final String rightProperty; // e.g., "customer.id"
  final JoinOperator operator;
  
  const JoinCondition({
    required this.leftProperty,
    required this.rightProperty,
    this.operator = JoinOperator.equals,
  });
}

enum JoinOperator {
  equals,
  notEquals,
  // More operators as needed
}

class ReadModelField extends Equatable {
  final String id;
  final String name;
  final String type;
  final FieldSource source;
  final FieldTransform? transform;
  final bool nullable;
  final String? description;
  
  const ReadModelField({
    required this.id,
    required this.name,
    required this.type,
    required this.source,
    this.transform,
    this.nullable = false,
    this.description,
  });
}

class FieldSource extends Equatable {
  final FieldSourceType type;
  final String path; // e.g., "order.items.length" or "customer.name"
  
  const FieldSource({
    required this.type,
    required this.path,
  });
}

enum FieldSourceType {
  direct,      // Direct property access
  computed,    // Computed from expression
  aggregated,  // Aggregated (COUNT, SUM, etc.)
}

class FieldTransform extends Equatable {
  final TransformType type;
  final String? expression;
  final Map<String, dynamic>? parameters;
  
  const FieldTransform({
    required this.type,
    this.expression,
    this.parameters,
  });
}

enum TransformType {
  rename,      // Simple rename
  format,      // Format (date, number, etc.)
  compute,     // Custom computation
  aggregate,   // COUNT, SUM, AVG, etc.
}
```

## UI Components

### Read Model Editor Layout

```
┌────────────────────────────────────────────────────────┐
│ Read Model: OrderSummary                     [Save][×] │
├────────────────────────────────────────────────────────┤
│                                                        │
│ ┌────────────────────────────────────────────────────┐│
│ │ Sources                                  [+ Add]    ││
│ │ ┌──────────────────────────────────────────────────┤│
│ │ │ 1. OrderEntity (alias: order) [Primary]          ││
│ │ │ 2. CustomerEntity (alias: customer)              ││
│ │ │    JOIN: order.customerId = customer.id          ││
│ │ │    [Edit] [Remove]                               ││
│ │ └──────────────────────────────────────────────────┘│
│ └────────────────────────────────────────────────────┘│
│                                                        │
│ ┌──────────────┬─────────────────────────────────────┐│
│ │ Entity Tree  │ Selected Fields                     ││
│ │              │                                     ││
│ │ ◉ order      │ ┌─────────────────────────────────┐││
│ │   ☐ id       │ │Field     Source      Transform  │││
│ │   ☑ status   │ │orderId   order.id    -          │││
│ │   ☐ items    │ │customer  customer... Rename     │││
│ │   ☑ total... │ │status    order.st... -          │││
│ │ ◉ customer   │ │total     order.to... -          │││
│ │   ☐ id       │ │itemCount order.it... COUNT      │││
│ │   ☑ name     │ │                                 │││
│ │   ☐ email    │ │ [+ Add Field] [Remove Selected] │││
│ │              │ └─────────────────────────────────┘││
│ └──────────────┴─────────────────────────────────────┘│
│                                                        │
│ ┌────────────────────────────────────────────────────┐│
│ │ Updated By Events                        [+ Add]    ││
│ │ ☑ OrderCreated                                     ││
│ │ ☑ OrderPaid                                        ││
│ │ ☑ CustomerUpdated                                  ││
│ └────────────────────────────────────────────────────┘│
│                                                        │
│ [Preview JSON]  [Generate Code]  [Test Query]         │
└────────────────────────────────────────────────────────┘
```

### Field Transform Dialog

```dart
class FieldTransformDialog extends StatefulWidget {
  final ReadModelField field;
  final ValueChanged<FieldTransform?> onSave;
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Transform Field: ${field.name}'),
            SizedBox(height: 24),
            
            // Transform type selector
            DropdownButton<TransformType>(
              value: field.transform?.type,
              items: TransformType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.name),
                );
              }).toList(),
              onChanged: (type) {
                // Update transform type
              },
            ),
            
            // Expression editor (if needed)
            if (field.transform?.type == TransformType.compute)
              TextField(
                decoration: InputDecoration(
                  labelText: 'Expression',
                  hintText: 'e.g., field1 + field2',
                ),
                maxLines: 3,
              ),
            
            // Parameters editor
            // ...
            
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // Save transform
                    onSave(/* transform */);
                    Navigator.pop(context);
                  },
                  child: Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

## Service Layer

```dart
class ReadModelService {
  final ReadModelRepository _repository;
  final EntityService _entityService;
  final EventBus _eventBus;
  
  // CRUD operations
  Future<ReadModelDefinition> createReadModel(
    CreateReadModelRequest request,
  ) async {
    // Validate sources exist
    for (final source in request.sources) {
      final entity = await _entityService.findById(source.entityId);
      if (entity == null) {
        throw ValidationException(
          'Entity ${source.entityId} not found',
        );
      }
    }
    
    // Create read model
    final readModel = ReadModelDefinition(
      id: Uuid().v4(),
      projectId: request.projectId,
      name: request.name,
      description: request.description,
      sources: request.sources,
      fields: request.fields,
      updatedByEvents: request.updatedByEvents,
      metadata: ReadModelMetadata.defaults(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    // Validate
    if (!readModel.isValid()) {
      throw ValidationException('Invalid read model definition');
    }
    
    // Save
    await _repository.save(readModel);
    
    // Emit event
    _eventBus.fire(ReadModelCreatedEvent(readModel));
    
    return readModel;
  }
  
  // Field operations
  Future<ReadModelDefinition> addField(
    String readModelId,
    AddFieldRequest request,
  ) async {
    final readModel = await _repository.findById(readModelId);
    if (readModel == null) {
      throw NotFoundException('Read model not found');
    }
    
    // Validate field source exists
    await _validateFieldSource(readModel, request.field);
    
    // Add field
    final updated = readModel.copyWith(
      fields: [...readModel.fields, request.field],
      updatedAt: DateTime.now(),
    );
    
    await _repository.save(updated);
    _eventBus.fire(ReadModelUpdatedEvent(updated));
    
    return updated;
  }
  
  Future<void> _validateFieldSource(
    ReadModelDefinition readModel,
    ReadModelField field,
  ) async {
    // Parse source path (e.g., "order.customerId")
    final parts = field.source.path.split('.');
    if (parts.isEmpty) {
      throw ValidationException('Invalid field source path');
    }
    
    final alias = parts.first;
    final source = readModel.sources.firstWhere(
      (s) => s.alias == alias,
      orElse: () => throw ValidationException('Source alias $alias not found'),
    );
    
    // Validate property path exists in entity
    final entity = await _entityService.findById(source.entityId);
    if (entity == null) {
      throw ValidationException('Entity not found');
    }
    
    // Walk property path
    final propertyPath = parts.sublist(1);
    await _validatePropertyPath(entity, propertyPath);
  }
  
  Future<void> _validatePropertyPath(
    EntityDefinition entity,
    List<String> path,
  ) async {
    // TODO: Implement property path validation
  }
  
  // Preview generation
  Future<Map<String, dynamic>> generatePreview(
    String readModelId,
  ) async {
    final readModel = await _repository.findById(readModelId);
    if (readModel == null) {
      throw NotFoundException('Read model not found');
    }
    
    final preview = <String, dynamic>{};
    
    for (final field in readModel.fields) {
      preview[field.name] = _getFieldTypeExample(field.type);
    }
    
    return preview;
  }
  
  dynamic _getFieldTypeExample(String type) {
    // Return example value based on type
    switch (type.toLowerCase()) {
      case 'string':
        return 'example';
      case 'integer':
      case 'int':
        return 123;
      case 'decimal':
      case 'double':
        return 123.45;
      case 'boolean':
      case 'bool':
        return true;
      case 'datetime':
        return DateTime.now().toIso8601String();
      default:
        return null;
    }
  }
  
  // Code generation
  Future<String> generateDartCode(String readModelId) async {
    final readModel = await _repository.findById(readModelId);
    if (readModel == null) {
      throw NotFoundException('Read model not found');
    }
    
    return _generateDartClass(readModel);
  }
  
  String _generateDartClass(ReadModelDefinition readModel) {
    final buffer = StringBuffer();
    
    buffer.writeln('class ${readModel.name} {');
    
    // Properties
    for (final field in readModel.fields) {
      final dartType = _mapTypeToDart(field.type);
      final nullable = field.nullable ? '?' : '';
      buffer.writeln('  final $dartType$nullable ${field.name};');
    }
    
    buffer.writeln();
    
    // Constructor
    buffer.writeln('  ${readModel.name}({');
    for (final field in readModel.fields) {
      final required = !field.nullable ? 'required ' : '';
      buffer.writeln('    ${required}this.${field.name},');
    }
    buffer.writeln('  });');
    
    buffer.writeln();
    
    // fromJson
    buffer.writeln('  factory ${readModel.name}.fromJson(Map<String, dynamic> json) {');
    buffer.writeln('    return ${readModel.name}(');
    for (final field in readModel.fields) {
      buffer.writeln('      ${field.name}: json[\'${field.name}\'],');
    }
    buffer.writeln('    );');
    buffer.writeln('  }');
    
    buffer.writeln('}');
    
    return buffer.toString();
  }
  
  String _mapTypeToDart(String type) {
    switch (type.toLowerCase()) {
      case 'string':
        return 'String';
      case 'integer':
      case 'int':
        return 'int';
      case 'decimal':
      case 'double':
        return 'double';
      case 'boolean':
      case 'bool':
        return 'bool';
      case 'datetime':
        return 'DateTime';
      default:
        return type;
    }
  }
}
```

## Database Schema

```sql
-- Read models table
CREATE TABLE read_models (
    id UUID PRIMARY KEY,
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    metadata JSONB NOT NULL DEFAULT '{}',
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE(project_id, name)
);

-- Read model sources table
CREATE TABLE read_model_sources (
    id UUID PRIMARY KEY,
    read_model_id UUID NOT NULL REFERENCES read_models(id) ON DELETE CASCADE,
    entity_id UUID NOT NULL REFERENCES entities(id),
    alias VARCHAR(100) NOT NULL,
    join_type VARCHAR(20),
    join_condition JSONB,
    display_order INTEGER NOT NULL DEFAULT 0
);

-- Read model fields table
CREATE TABLE read_model_fields (
    id UUID PRIMARY KEY,
    read_model_id UUID NOT NULL REFERENCES read_models(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(255) NOT NULL,
    source_type VARCHAR(50) NOT NULL,
    source_path TEXT NOT NULL,
    transform JSONB,
    nullable BOOLEAN NOT NULL DEFAULT false,
    description TEXT,
    display_order INTEGER NOT NULL DEFAULT 0,
    UNIQUE(read_model_id, name)
);

-- Read model events table (which events update this read model)
CREATE TABLE read_model_events (
    id UUID PRIMARY KEY,
    read_model_id UUID NOT NULL REFERENCES read_models(id) ON DELETE CASCADE,
    event_id VARCHAR(255) NOT NULL, -- Reference to canvas event
    UNIQUE(read_model_id, event_id)
);

-- Indexes
CREATE INDEX idx_read_models_project ON read_models(project_id);
CREATE INDEX idx_read_model_sources_rm ON read_model_sources(read_model_id);
CREATE INDEX idx_read_model_sources_entity ON read_model_sources(entity_id);
CREATE INDEX idx_read_model_fields_rm ON read_model_fields(read_model_id);
CREATE INDEX idx_read_model_events_rm ON read_model_events(read_model_id);
```

## Integration with Canvas

```dart
// Link read model element on canvas to read model definition
class ReadModelElement extends CanvasElement {
  final String? readModelId; // Link to read model definition
  
  // When user double-clicks read model element, open read model designer
  void onDoubleClick() {
    if (readModelId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReadModelDesignerPage(
            readModelId: readModelId!,
          ),
        ),
      );
    }
  }
}
```

## Examples

### Example 1: Simple Read Model

**OrderSummary** - Shows basic order information

Sources:
- OrderEntity (order)

Fields:
- orderId ← order.id
- status ← order.status
- totalAmount ← order.totalAmount
- itemCount ← COUNT(order.items)

### Example 2: Joined Read Model

**OrderWithCustomer** - Shows order with customer details

Sources:
- OrderEntity (order)
- CustomerEntity (customer) JOIN order.customerId = customer.id

Fields:
- orderId ← order.id
- orderDate ← order.createdAt
- customerName ← customer.name
- customerEmail ← customer.email
- totalAmount ← order.totalAmount

### Example 3: Computed Fields

**OrderAnalytics** - Shows computed analytics

Sources:
- OrderEntity (order)

Fields:
- orderId ← order.id
- totalAmount ← order.totalAmount
- discount ← COMPUTE: totalAmount * 0.1
- finalAmount ← COMPUTE: totalAmount - discount
- statusLabel ← FORMAT: status (CREATED → "New Order")

---

## Testing

### Unit Tests
- Field source validation
- Join condition validation
- Transform expression parsing
- Code generation

### Integration Tests
- Creating read models from UI
- Adding/removing fields
- Multi-entity joins
- Preview generation

---

*This design will be refined during implementation.*
