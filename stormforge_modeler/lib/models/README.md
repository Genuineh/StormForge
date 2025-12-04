# StormForge Modeler - Data Models

> Core data models for the StormForge Modeler application
> Sprint M1: Project Management Foundation

---

## Overview

This directory contains the core data models for StormForge Modeler, including project management, user management, team collaboration, and canvas modeling.

## Model Architecture

### Canvas Models (Existing - Phase 0)

**Purpose**: EventStorming canvas and domain modeling

- `element_model.dart` - Canvas elements (sticky notes, connections)
- `canvas_model.dart` - Canvas state, bounded contexts, viewport

### Project Management Models (New - Sprint M1)

**Purpose**: Enterprise project management and collaboration

- `project_model.dart` - Project metadata and settings
- `user_model.dart` - User accounts and global roles
- `team_member_model.dart` - Team membership and project roles

---

## Model Details

### Project Model

**File**: `project_model.dart`

**Purpose**: Represents a StormForge project with metadata, settings, and ownership.

**Key Classes**:
- `Project` - Main project entity
- `ProjectSettings` - Project-specific configuration
- `GitIntegrationSettings` - Git integration config
- `AISettings` - AI generation settings

**Enums**:
- `ProjectVisibility` - private, team, public

**Features**:
- Unique namespace validation
- Git integration settings
- AI settings management
- JSON serialization/deserialization
- Factory methods for creation

**Example**:
```dart
final project = Project.create(
  name: 'E-Commerce Platform',
  namespace: 'ecommerce',
  ownerId: userId,
  visibility: ProjectVisibility.team,
);
```

---

### User Model

**File**: `user_model.dart`

**Purpose**: User accounts with global roles and permissions.

**Key Classes**:
- `User` - User account entity

**Enums**:
- `UserRole` - admin, developer, viewer
- `Permission` - 12 granular permissions

**Permission System**:
```dart
enum Permission {
  // Project permissions
  projectCreate, projectEdit, projectDelete, 
  projectView, projectExport,
  
  // Model permissions
  modelEdit, modelView, modelExport,
  
  // Other permissions
  codeGenerate, teamManage,
  libraryEdit, libraryView,
}
```

**Global Roles**:
- **Admin**: All permissions
- **Developer**: Most permissions (create, edit, generate)
- **Viewer**: Read-only (view only)

**Features**:
- Role-based default permissions
- Custom permission overrides
- Permission checking utilities
- JSON serialization/deserialization

**Example**:
```dart
final user = User.create(
  username: 'john_doe',
  email: 'john@example.com',
  displayName: 'John Doe',
  role: UserRole.developer,
);

if (user.hasPermission(Permission.projectCreate)) {
  // Allow project creation
}
```

---

### Team Member Model

**File**: `team_member_model.dart`

**Purpose**: Project-specific team membership and roles.

**Key Classes**:
- `TeamMember` - Team membership entity

**Enums**:
- `TeamRole` - owner, admin, editor, viewer

**Team Roles**:
- **Owner**: Full project control (including deletion)
- **Admin**: Team management + editing
- **Editor**: Content editing + code generation
- **Viewer**: Read-only access

**Features**:
- Project-specific roles
- Permission override system
- Effective permission calculation
- Role capability checks
- JSON serialization/deserialization

**Example**:
```dart
final member = TeamMember.create(
  projectId: projectId,
  userId: userId,
  role: TeamRole.editor,
);

if (member.hasPermission(Permission.modelEdit)) {
  // Allow model editing
}
```

---

## Permission System

### Permission Hierarchy

```
Global Level (User)
├── UserRole.admin → All Permissions
├── UserRole.developer → Most Permissions
└── UserRole.viewer → View Only

Project Level (TeamMember)
├── TeamRole.owner → Full Control
├── TeamRole.admin → Manage + Edit
├── TeamRole.editor → Edit + Generate
└── TeamRole.viewer → View Only
```

### Permission Check Flow

1. Check if user has global permission (from UserRole)
2. Check if team member has project permission (from TeamRole)
3. Check custom permission overrides
4. Allow/Deny action

### Example Permission Usage

```dart
// User level
final user = User(...);
if (user.hasPermission(Permission.projectCreate)) {
  // User can create projects globally
}

// Team member level
final member = TeamMember(...);
if (member.hasPermission(Permission.modelEdit)) {
  // Team member can edit models in this project
}

// Check role capabilities
if (member.role.canAdmin) {
  // Team member can perform admin actions
}
```

---

## Data Persistence

### Storage Strategy

**Offline-First Architecture**:
1. All operations performed on local SQLite first
2. Changes queued for cloud synchronization
3. Background sync when online
4. Conflict resolution with version tracking

### Database Schema

See [docs/DATABASE_SCHEMA.md](../../docs/DATABASE_SCHEMA.md) for detailed schema.

**MongoDB Collections**:
- `users` - User accounts
- `projects` - Project metadata
- `project_members` - Team membership
- `project_models` - Model data
- `model_versions` - Version history
- `project_activities` - Activity log

**SQLite Tables**:
- Local mirror of MongoDB collections
- `sync_queue` - Pending sync operations

---

## Serialization

All models support JSON serialization for:
- Database storage
- API communication
- File export/import

**Pattern**:
```dart
// To JSON
final json = model.toJson();

// From JSON
final model = Model.fromJson(json);
```

---

## Design Principles

### 1. Immutability

All models are immutable (using `copyWith` for updates):

```dart
final updatedProject = project.copyWith(
  name: 'New Name',
);
```

### 2. Value Equality

All models use `Equatable` for value-based equality:

```dart
if (project1 == project2) {
  // Same values, not same instance
}
```

### 3. Type Safety

Strong typing throughout:
- Enums for fixed values (roles, permissions, visibility)
- Required fields enforced
- No nullable abuse

### 4. Factory Methods

Convenient creation methods:

```dart
Project.create(...)
User.create(...)
TeamMember.create(...)
```

### 5. Clear Naming

- Classes: PascalCase (Project, User)
- Properties: camelCase (projectId, userId)
- Enums: lowercase (ProjectVisibility.private)

---

## Future Enhancements

### Sprint M2-M9 (Modeler 2.0)

**Connection System** (M2):
- Connection model with 8 types
- Visual connection data

**Entity Modeling** (M3):
- Entity definition model
- Property and method models
- Invariant system

**Read Model Designer** (M4):
- Read model definition
- Field selection and joins

**Command Designer** (M5):
- Command data model
- Data source mapping

**Global Library** (M6):
- Library component model
- Version management

**IR v2.0** (M8):
- Enhanced IR schema
- Migration support

---

## Testing

### Unit Tests (To be implemented in M9)

```dart
test('Project creation with valid data', () {
  final project = Project.create(
    name: 'Test Project',
    namespace: 'test',
    ownerId: 'user123',
  );
  
  expect(project.name, 'Test Project');
  expect(project.namespace, 'test');
});

test('User permission check', () {
  final user = User.create(
    username: 'test',
    email: 'test@example.com',
    displayName: 'Test User',
    role: UserRole.developer,
  );
  
  expect(user.hasPermission(Permission.projectCreate), true);
  expect(user.hasPermission(Permission.projectDelete), false);
});
```

---

## Related Documentation

- [DATABASE_SCHEMA.md](../../docs/DATABASE_SCHEMA.md) - Complete database design
- [sprint_m1_completion.md](../../docs/sprint_m1_completion.md) - Sprint M1 report
- [MODELER_UPGRADE_PLAN.md](../../docs/MODELER_UPGRADE_PLAN.md) - Modeler 2.0 plan
- [ARCHITECTURE.md](../../docs/ARCHITECTURE.md) - System architecture

---

## Questions?

For questions or issues with these models:
1. Check the design documents in `docs/`
2. Review the Sprint M1 completion report
3. See the MODELER_UPGRADE_PLAN for context

---

*Models are the foundation of great software. These models provide a solid foundation for StormForge's enterprise-grade project management system.*
