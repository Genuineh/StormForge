# StormForge Modeler Upgrade Plan

> Complete upgrade plan for transforming Modeler into a full-featured project management and modeling software
> Version: 2.0
> Date: 2025-12-03

---

## 📋 Executive Summary

This document outlines the comprehensive upgrade plan for StormForge Modeler to transform it from a simple EventStorming canvas into a complete enterprise-grade modeling and project management platform.

### Key Objectives

1. **Project Management**: Full project lifecycle management with saving, versioning, and user permissions
2. **Component Connectivity**: Visual connection system for EventStorming components
3. **Entity Modeling**: Dedicated entity object modeling with properties and relationships
4. **Read Model Management**: Field selection from entities for read models
5. **Command Data Models**: Proper data model management for commands
6. **Global Library**: Enterprise-level shared library for reusable components

---

## 🎯 Phase 1: Project Management System

### 1.1 Project Structure

```yaml
project:
  id: uuid
  name: string
  description: string
  namespace: string
  owner: User
  team: List<TeamMember>
  created_at: DateTime
  updated_at: DateTime
  settings:
    visibility: public | private | team
    git_integration: GitConfig
    ai_settings: AIConfig
```

### 1.2 User Management

**User Model**:
```yaml
user:
  id: uuid
  username: string
  email: string
  display_name: string
  avatar_url: string
  role: admin | developer | viewer
  permissions: List<Permission>
  created_at: DateTime
```

**Permission System**:
- `project.create` - Create new projects
- `project.edit` - Edit project settings
- `project.delete` - Delete projects
- `project.view` - View projects
- `model.edit` - Edit models/canvas
- `model.view` - View models
- `model.export` - Export models
- `code.generate` - Generate code
- `team.manage` - Manage team members
- `library.edit` - Edit global library
- `library.view` - View global library

**Team Management**:
```yaml
team_member:
  user_id: uuid
  project_id: uuid
  role: owner | admin | editor | viewer
  permissions: List<Permission>
  joined_at: DateTime
```

### 1.3 Project Persistence

**Storage Strategy**:
1. **Local Storage**: SQLite for metadata, file system for models
2. **Cloud Storage**: PostgreSQL for metadata, S3/MinIO for models
3. **Git Integration**: All models stored in Git for versioning

**Database Schema**:
```sql
-- Projects table
CREATE TABLE projects (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    namespace VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    owner_id UUID NOT NULL REFERENCES users(id),
    visibility VARCHAR(20) NOT NULL DEFAULT 'private',
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    settings JSONB
);

-- Project members table
CREATE TABLE project_members (
    id UUID PRIMARY KEY,
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(20) NOT NULL,
    permissions JSONB,
    joined_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE(project_id, user_id)
);

-- Project models table
CREATE TABLE project_models (
    id UUID PRIMARY KEY,
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(50) NOT NULL, -- 'canvas', 'entity', 'command', etc.
    content JSONB NOT NULL,
    version INTEGER NOT NULL DEFAULT 1,
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Model versions table (audit trail)
CREATE TABLE model_versions (
    id UUID PRIMARY KEY,
    model_id UUID NOT NULL REFERENCES project_models(id) ON DELETE CASCADE,
    version INTEGER NOT NULL,
    content JSONB NOT NULL,
    changed_by UUID NOT NULL REFERENCES users(id),
    change_description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);
```

---

## 🔗 Phase 2: Component Connectivity System

### 2.1 Connection Types

EventStorming components need to be visually connected to show relationships:

**Connection Categories**:

1. **Command → Aggregate**: Command targets an aggregate
2. **Aggregate → Event**: Aggregate produces an event
3. **Event → Policy**: Event triggers a policy
4. **Policy → Command**: Policy triggers a command
5. **Event → Read Model**: Event updates a read model
6. **External System → Command**: External system triggers command
7. **UI → Command**: UI triggers command
8. **Read Model → UI**: UI displays read model

### 2.2 Connection Model

```dart
enum ConnectionType {
  commandToAggregate,
  aggregateToEvent,
  eventToPolicy,
  policyToCommand,
  eventToReadModel,
  externalToCommand,
  uiToCommand,
  readModelToUI,
  custom,
}

class Connection extends Equatable {
  final String id;
  final String sourceId;
  final String targetId;
  final ConnectionType type;
  final String label;
  final Map<String, dynamic> metadata;
  final ConnectionStyle style;
  final bool isSelected;
  
  // Validation rules based on connection type
  bool isValid() {
    // Validate source and target element types match connection type
  }
}

class ConnectionStyle {
  final Color color;
  final double strokeWidth;
  final LineStyle lineStyle; // solid, dashed, dotted
  final ArrowStyle arrowStyle;
}
```

### 2.3 Connection UI Features

**Interaction**:
- Click element → Click another element = Create connection
- Connection mode toolbar button
- Right-click connection to edit/delete
- Connection properties panel
- Auto-routing (orthogonal or curved)
- Snap to element edges

**Visual Design**:
- Different colors for different connection types
- Arrow styles indicate direction
- Label positioning (middle, offset)
- Connection validation indicators (red for invalid)

---

## 🏗️ Phase 3: Entity Object Modeling System

### 3.1 Dedicated Entity Editor

**Entity Model**:
```dart
class EntityDefinition {
  final String id;
  final String name;
  final String description;
  final String? aggregateId; // Link to aggregate
  final List<EntityProperty> properties;
  final List<EntityMethod> methods;
  final List<EntityInvariant> invariants;
  final EntityMetadata metadata;
}

class EntityProperty {
  final String id;
  final String name;
  final String type; // Reference to type definition
  final bool required;
  final dynamic defaultValue;
  final List<ValidationRule> validations;
  final bool isIdentifier;
  final bool isReadOnly;
  final String? description;
}

class EntityMethod {
  final String name;
  final String returnType;
  final List<MethodParameter> parameters;
  final String? description;
  final MethodType type; // constructor, command, query
}

class EntityInvariant {
  final String name;
  final String expression;
  final String errorMessage;
}
```

### 3.2 Entity Editor UI

**Features**:
- Tree view of all entities in project
- Property grid for editing entity properties
- Visual property type selector (with global library)
- Validation rule builder
- Method/behavior editor
- Relationship diagram view
- Import/export entities

**Layout**:
```
┌─────────────────────────────────────────────────┐
│ Entity Editor                                    │
├───────────────┬─────────────────────────────────┤
│ Entity List   │ Entity Details                   │
│               │                                  │
│ ┌───────────┐ │ Name: [OrderEntity          ]   │
│ │ □ Order   │ │ Description: [...          ]   │
│ │   ├─ Order│ │                                  │
│ │   └─ Item │ │ Properties:                     │
│ │ □ Payment │ │ ┌──────────────────────────┐   │
│ │   └─ Pay..│ │ │ Name  Type    Required   │   │
│ │ □ Invento.│ │ │ id    OrderId    ✓       │   │
│ └───────────┘ │ │ items List<...>  ✓       │   │
│               │ │ status OrderS... ✓       │   │
│ [+ Add Entity]│ └──────────────────────────┘   │
│               │                                  │
│               │ [Add Property] [Add Method]     │
└───────────────┴─────────────────────────────────┘
```

### 3.3 Aggregate-Entity Relationship

**Linking**:
- Each Aggregate on canvas can reference one or more entities
- Entities can be shared across aggregates (with warnings)
- Canvas aggregate shows entity name as reference
- Double-click aggregate opens entity editor

---

## 📊 Phase 4: Read Model Field Selection

### 4.1 Read Model Designer

**Concept**:
Read models are projections that select specific fields from one or more entities.

**Model**:
```dart
class ReadModelDefinition {
  final String id;
  final String name;
  final String description;
  final List<ReadModelField> fields;
  final List<DataSource> sources;
  final List<TransformRule> transforms;
}

class ReadModelField {
  final String name;
  final String type;
  final FieldSource source;
  final TransformExpression? transform;
  final bool nullable;
}

class FieldSource {
  final String entityId;
  final String propertyPath; // e.g., "order.customer.name"
  final JoinType? joinType;
}

class DataSource {
  final String entityId;
  final String alias;
  final JoinCondition? joinCondition;
}
```

### 4.2 Read Model UI

**Visual Designer**:
```
┌────────────────────────────────────────────────────────┐
│ Read Model: OrderSummary                               │
├────────────────────────────────────────────────────────┤
│ Sources:                                               │
│ ┌──────────────────────────────────────────────────┐  │
│ │ [+] OrderEntity (order)                          │  │
│ │ [+] CustomerEntity (customer) JOIN order.custId  │  │
│ └──────────────────────────────────────────────────┘  │
│                                                        │
│ Fields:                                                │
│ ┌──────────────────────────────────────────────────┐  │
│ │ ☑ orderId       ← order.id                       │  │
│ │ ☑ customerName  ← customer.name                  │  │
│ │ ☑ totalAmount   ← order.totalAmount              │  │
│ │ ☑ itemCount     ← COUNT(order.items)             │  │
│ │ ☑ status        ← order.status                   │  │
│ │ ☐ createdAt     ← order.createdAt                │  │
│ └──────────────────────────────────────────────────┘  │
│                                                        │
│ [Entity Tree]  [Selected Fields]  [Preview]           │
└────────────────────────────────────────────────────────┘
```

**Features**:
- Drag & drop fields from entity tree
- Field transformation expressions
- Field renaming
- Multi-entity joins
- Computed fields
- Real-time preview of generated structure

---

## 📝 Phase 5: Command Data Model Management

### 5.1 Command Model Designer

**Concept**:
Commands carry data that may come from:
- Read models (UI data)
- Other entities (partial data)
- Custom DTOs (Data Transfer Objects)

**Model**:
```dart
class CommandDefinition {
  final String id;
  final String name;
  final String description;
  final String aggregateId;
  final CommandPayload payload;
  final List<ValidationRule> validations;
  final List<Precondition> preconditions;
  final List<String> producedEvents;
}

class CommandPayload {
  final List<CommandField> fields;
  final List<FieldSource> sources;
}

class CommandField {
  final String name;
  final String type;
  final bool required;
  final FieldSource? source; // Where this field comes from
  final dynamic defaultValue;
  final List<ValidationRule> validations;
}
```

### 5.2 Command Designer UI

```
┌────────────────────────────────────────────────────────┐
│ Command: CreateOrder                                   │
├────────────────────────────────────────────────────────┤
│ Target Aggregate: [Order ▼]                           │
│ Description: [...                                   ]  │
│                                                        │
│ Payload Fields:                                        │
│ ┌──────────────────────────────────────────────────┐  │
│ │ Field        Type          Source           Req  │  │
│ │ customerId   CustomerId    UI Input         ☑    │  │
│ │ items        List<Item>    OrderFormRead    ☑    │  │
│ │ totalAmount  Money          Computed        ☑    │  │
│ │ notes        String         UI Input        ☐    │  │
│ └──────────────────────────────────────────────────┘  │
│                                                        │
│ [+ Add Field from Read Model]                         │
│ [+ Add Custom Field]                                   │
│                                                        │
│ Produces Events:                                       │
│ ☑ OrderCreated                                        │
│                                                        │
│ Validations:                                           │
│ ☑ items.length > 0 : "Order must have items"         │
│ [+ Add Validation]                                     │
└────────────────────────────────────────────────────────┘
```

---

## 🌍 Phase 6: Enterprise Global Library

### 6.1 Library Architecture

**Hierarchy**:
```
Global Library
├── Enterprise Library (Shared across all projects)
│   ├── Common Types
│   │   ├── Money
│   │   ├── Address
│   │   ├── Contact
│   │   └── ...
│   ├── Common Entities
│   │   ├── Customer
│   │   ├── Product
│   │   └── ...
│   └── Common Patterns
│       ├── Pagination
│       ├── Error Handling
│       └── ...
├── Organization Library (Shared within organization)
│   └── Company-specific types
└── Project Library (Project-specific)
    └── Domain-specific types
```

### 6.2 Library Component Model

```dart
class LibraryComponent {
  final String id;
  final String name;
  final LibraryScope scope; // enterprise, organization, project
  final ComponentType type; // entity, valueObject, enum, interface
  final String version;
  final String description;
  final String? author;
  final List<String> tags;
  final dynamic definition;
  final Map<String, dynamic> metadata;
}

enum LibraryScope {
  enterprise,   // Available to all
  organization, // Available within org
  project,      // Only this project
}

enum ComponentType {
  entity,
  valueObject,
  enumType,
  interface,
  command,
  event,
  readModel,
  aggregate,
}
```

### 6.3 Library UI

```
┌────────────────────────────────────────────────────────┐
│ Global Library                    [Enterprise ▼]       │
├─────────────────┬──────────────────────────────────────┤
│ Categories      │ Components                           │
│                 │                                      │
│ [📦] Types      │ Search: [____________________] 🔍    │
│   ├─ Money     │                                      │
│   ├─ Address   │ ┌──────────────────────────────────┐ │
│   └─ Contact   │ │ 💰 Money                         │ │
│ [🏗️] Entities   │ │ A value object representing      │ │
│   ├─ Customer  │ │ monetary amounts                 │ │
│   └─ Product   │ │ Version: 1.0.2                   │ │
│ [🎯] Aggregates │ │ [Use in Project] [View Details]  │ │
│ [📊] Read Models│ └──────────────────────────────────┘ │
│ [⚡] Commands   │                                      │
│ [📡] Events     │ ┌──────────────────────────────────┐ │
│                 │ │ 📫 Address                       │ │
│ [+ Create New] │ │ Standard postal address          │ │
│                 │ │ Version: 2.1.0                   │ │
│                 │ │ [Use in Project] [View Details]  │ │
│                 │ └──────────────────────────────────┘ │
└─────────────────┴──────────────────────────────────────┘
```

### 6.4 Library Features

**Management**:
- Version control for library components
- Dependency tracking
- Impact analysis when updating
- Import/export library components
- Publishing to organization library
- Usage statistics

**Usage**:
- Drag & drop from library to project
- Search and filter
- Preview component details
- Copy to project (make local copy)
- Reference (use directly, updates sync)

---

## 📐 Phase 7: Enhanced Canvas Integration

### 7.1 Canvas-Model Synchronization

**Bidirectional Sync**:
- Canvas element → Entity reference
- Entity changes → Canvas update
- Connection → Relationship definition
- Property panel shows entity properties

### 7.2 Enhanced Element Properties

**Aggregate Element**:
```dart
class AggregateElement extends CanvasElement {
  final String? entityId; // Link to entity definition
  final List<String> commandIds; // Incoming commands
  final List<String> eventIds; // Produced events
  // ... existing properties
}
```

**Read Model Element**:
```dart
class ReadModelElement extends CanvasElement {
  final String? readModelId; // Link to read model definition
  final List<String> sourceEntityIds;
  final List<String> eventIds; // Events that update this
  // ... existing properties
}
```

**Command Element**:
```dart
class CommandElement extends CanvasElement {
  final String? commandId; // Link to command definition
  final String? targetAggregateId;
  final String? sourceUIId;
  // ... existing properties
}
```

### 7.3 Context Menu Enhancements

**Right-click Element**:
- Edit Properties
- Edit Entity Definition (for aggregates)
- Edit Read Model (for read models)
- Edit Command (for commands)
- Create Connection
- Duplicate
- Delete
- Add to Library

---

## 🎨 Phase 8: UI/UX Improvements

### 8.1 Multi-Panel Layout

```
┌─────────────────────────────────────────────────────────────┐
│ StormForge Modeler              [Project: E-commerce] [≡]   │
├─────────┬─────────────────────────────────────┬─────────────┤
│ Project │ Canvas                               │ Properties  │
│ Tree    │                                      │             │
│         │  ┌─────┐      ┌─────┐               │ Element:    │
│ ◉ Models│  │Cmd  │─────→│Aggr │               │ CreateOrder │
│   ├ Order│  └─────┘      └──┬──┘               │             │
│   ├ Pay..│                  │                  │ Type: Cmd   │
│   └ Inv..│                  ↓                  │ Target: ... │
│ ◎ Ent...│              ┌─────┐                │             │
│   ├ Order│              │Event│                │ [Edit Def]  │
│   └ Cust.│              └─────┘                │             │
│ ◎ Lib...│                                      │             │
│   └ Money│                                      │             │
│         │                                      │             │
│ [+ New] │                                      │             │
└─────────┴─────────────────────────────────────┴─────────────┘
```

### 8.2 Navigation

**Project Tree**:
- Models (Canvas views)
- Entities
- Commands
- Events
- Read Models
- Global Library References

**Quick Actions**:
- Ctrl+N: New element
- Ctrl+S: Save project
- Ctrl+E: Export IR
- Ctrl+G: Generate code
- Ctrl+F: Find element

---

## 📋 Phase 9: Updated IR Schema v2.0

### 9.1 Enhanced IR Structure

```yaml
version: "2.0"

project:
  id: uuid
  name: string
  namespace: string
  owner: string
  team: List<TeamMember>
  
  # New sections
  entities:
    - $ref: "#/entities/Order"
    - $ref: "#/entities/Customer"
    
  read_models:
    - $ref: "#/read_models/OrderSummary"
    
  library_references:
    - scope: enterprise
      component_id: "common.Money"
    - scope: enterprise
      component_id: "common.Address"

contexts:
  - $ref: "contexts/order_context.yaml"

# Entity definitions with full properties
entities:
  Order:
    id: uuid
    name: "Order"
    description: "Order entity"
    aggregate_id: "agg_order_123" # Link to aggregate
    properties:
      - id: "prop_1"
        name: "id"
        type: "OrderId"
        required: true
        identifier: true
      - id: "prop_2"
        name: "items"
        type: "List<OrderItem>"
        required: true
    methods:
      - name: "calculateTotal"
        return_type: "Money"
    invariants:
      - expression: "items.length > 0"
        message: "Order must have items"

# Read model definitions
read_models:
  OrderSummary:
    id: uuid
    name: "OrderSummary"
    sources:
      - entity_id: "Order"
        alias: "order"
      - entity_id: "Customer"
        alias: "customer"
        join: "order.customerId = customer.id"
    fields:
      - name: "orderId"
        source: "order.id"
      - name: "customerName"
        source: "customer.name"
      - name: "totalAmount"
        source: "order.totalAmount"

# Command definitions with data sources
commands:
  CreateOrder:
    id: uuid
    payload:
      fields:
        - name: "customerId"
          type: "CustomerId"
          source:
            type: "ui_input"
        - name: "items"
          type: "List<OrderItem>"
          source:
            type: "read_model"
            read_model_id: "OrderFormData"

# Canvas metadata (positions, connections)
canvas:
  elements:
    - id: "elem_1"
      type: "aggregate"
      entity_id: "Order"  # Reference to entity
      position: {x: 100, y: 100}
      
  connections:
    - id: "conn_1"
      source: "elem_1"
      target: "elem_2"
      type: "command_to_aggregate"
```

---

## 📊 Implementation Roadmap

### Sprint Breakdown

#### Sprint M1: Project Management Foundation (2 weeks)
- [ ] Database schema setup
- [ ] User authentication system
- [ ] Project CRUD operations
- [ ] Team member management
- [ ] Permission system

#### Sprint M2: Connection System (2 weeks)
- [ ] Connection model implementation
- [ ] Visual connection UI
- [ ] Connection validation
- [ ] Connection properties panel
- [ ] Auto-routing algorithm

#### Sprint M3: Entity Modeling System (3 weeks)
- [ ] Entity definition model
- [ ] Entity editor UI
- [ ] Property editor
- [ ] Entity-aggregate linking
- [ ] Entity tree view

#### Sprint M4: Read Model Designer (2 weeks)
- [ ] Read model definition model
- [ ] Field selection UI
- [ ] Multi-entity joins
- [ ] Transform expressions
- [ ] Preview generation

#### Sprint M5: Command Designer (2 weeks)
- [ ] Command definition model
- [ ] Payload designer UI
- [ ] Data source mapping
- [ ] Validation rules
- [ ] Event linkage

#### Sprint M6: Global Library (3 weeks)
- [ ] Library component model
- [ ] Library storage system
- [ ] Library UI (browse, search)
- [ ] Component publishing
- [ ] Version management
- [ ] Import/export

#### Sprint M7: Canvas Integration (2 weeks)
- [ ] Enhanced element models
- [ ] Canvas-entity sync
- [ ] Property panel upgrades
- [ ] Context menu enhancements
- [ ] Multi-panel layout

#### Sprint M8: IR v2.0 Implementation (2 weeks)
- [ ] Update IR schema
- [ ] Serialization/deserialization
- [ ] Migration from v1.0
- [ ] Validation
- [ ] Generator updates

#### Sprint M9: Testing & Polish (2 weeks)
- [ ] Unit tests
- [ ] Integration tests
- [ ] UI/UX polish
- [ ] Performance optimization
- [ ] Documentation

**Total Duration**: ~18 weeks (4.5 months)

---

## 🎯 Success Criteria

### Functional Requirements
- [x] Users can create and manage projects
- [x] Teams can collaborate with permissions
- [x] Elements can be connected visually
- [x] Entities have dedicated modeling interface
- [x] Read models can select fields from entities
- [x] Commands have proper data models
- [x] Global library is accessible and usable

### Non-Functional Requirements
- Performance: Canvas with 1000+ elements at 60fps
- Scalability: Support 100+ projects per user
- Reliability: Auto-save every 30 seconds
- Usability: Learning curve < 30 minutes
- Security: Role-based access control

---

## 🔧 Technical Considerations

### Technology Stack Updates

**Frontend (Flutter)**:
- State management: Riverpod (for reactive updates)
- Database: Drift (local SQLite)
- Networking: Dio + Retrofit
- Canvas: Custom painter with performance optimizations

**Backend (New)**:
- API Server: Rust + Axum
- Database: PostgreSQL
- Authentication: JWT tokens
- Storage: S3/MinIO for models

### Migration Strategy

**Phase 1**: Add new features alongside existing
**Phase 2**: Migrate existing data to new schema
**Phase 3**: Deprecate old features
**Phase 4**: Remove old code

---

## 📚 Documentation Updates

### New Documentation Needed
1. **User Guide**: Project management, entity modeling, library usage
2. **Admin Guide**: User management, permissions, global library
3. **Developer Guide**: API documentation, plugin development
4. **Migration Guide**: v1.0 to v2.0 upgrade path

---

## 🚀 Next Steps

1. Review and approval of this plan
2. Allocate resources (4-6 developers)
3. Begin Sprint M1 implementation
4. Weekly progress reviews
5. Beta testing after Sprint M7
6. Production release after Sprint M9

---

*This document will be updated as the upgrade progresses.*
