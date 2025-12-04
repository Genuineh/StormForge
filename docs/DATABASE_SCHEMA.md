# Database Schema Design for StormForge

> Sprint M1: Project Management Foundation
> Date: 2025-12-04
> Version: 1.0

---

## Overview

This document defines the database schema for StormForge's project management system. The system uses a dual-storage approach:

1. **Local Storage**: SQLite for offline-first development and metadata caching
2. **Cloud Storage**: MongoDB for cloud sync and team collaboration

---

## MongoDB Collections

### 1. Users Collection

Stores user account information and global roles.

```javascript
{
  _id: ObjectId,                    // MongoDB object ID
  username: String,                 // Unique username
  email: String,                    // Unique email address
  display_name: String,             // User's display name
  avatar_url: String,               // URL to user's avatar image
  role: String,                     // 'admin' | 'developer' | 'viewer'
  permissions: [String],            // Global permissions array
  password_hash: String,            // Hashed password (bcrypt)
  created_at: ISODate,              // Account creation timestamp
  updated_at: ISODate,              // Last update timestamp
  last_login_at: ISODate,           // Last login timestamp
  is_active: Boolean                // Account active status
}

// Indexes
db.users.createIndex({ "username": 1 }, { unique: true })
db.users.createIndex({ "email": 1 }, { unique: true })
db.users.createIndex({ "role": 1 })
```

### 2. Projects Collection

Stores project metadata and settings.

```javascript
{
  _id: ObjectId,                    // MongoDB object ID
  name: String,                     // Project name
  namespace: String,                // Unique namespace for code generation
  description: String,              // Project description
  owner_id: ObjectId,               // Reference to Users collection
  visibility: String,               // 'private' | 'team' | 'public'
  created_at: ISODate,              // Project creation timestamp
  updated_at: ISODate,              // Last update timestamp
  settings: {
    git_integration: {
      enabled: Boolean,             // Whether Git integration is enabled
      auto_commit: Boolean,         // Auto-commit on save
      commit_message: String,       // Default commit message
      repository_url: String,       // Git repository URL
      branch: String                // Default branch name
    },
    ai_settings: {
      enabled: Boolean,             // Whether AI generation is enabled
      provider: String,             // 'claude' | 'openai' | etc.
      model: String,                // Model name (e.g., 'claude-3-5-sonnet')
      temperature: Number           // Generation temperature (0.0-1.0)
    }
  },
  stats: {
    element_count: Number,          // Total number of elements
    context_count: Number,          // Total number of bounded contexts
    member_count: Number,           // Total number of team members
    last_generated_at: ISODate      // Last code generation timestamp
  }
}

// Indexes
db.projects.createIndex({ "namespace": 1 }, { unique: true })
db.projects.createIndex({ "owner_id": 1 })
db.projects.createIndex({ "visibility": 1 })
db.projects.createIndex({ "created_at": -1 })
```

### 3. Project Members Collection

Stores team membership and project-specific roles.

```javascript
{
  _id: ObjectId,                    // MongoDB object ID
  project_id: ObjectId,             // Reference to Projects collection
  user_id: ObjectId,                // Reference to Users collection
  role: String,                     // 'owner' | 'admin' | 'editor' | 'viewer'
  permissions: [String],            // Project-specific permissions (overrides)
  joined_at: ISODate,               // When user joined the project
  invited_by: ObjectId,             // Reference to Users collection
  invitation_status: String         // 'pending' | 'accepted' | 'rejected'
}

// Indexes
db.project_members.createIndex({ "project_id": 1, "user_id": 1 }, { unique: true })
db.project_members.createIndex({ "user_id": 1 })
db.project_members.createIndex({ "role": 1 })
```

### 4. Project Models Collection

Stores model data (canvas, entities, etc.).

```javascript
{
  _id: ObjectId,                    // MongoDB object ID
  project_id: ObjectId,             // Reference to Projects collection
  name: String,                     // Model name
  type: String,                     // 'canvas' | 'entity' | 'command' | etc.
  content: Object,                  // BSON document (model data)
  version: Number,                  // Current version number
  created_by: ObjectId,             // Reference to Users collection
  created_at: ISODate,              // Model creation timestamp
  updated_at: ISODate,              // Last update timestamp
  updated_by: ObjectId              // Reference to Users collection
}

// Indexes
db.project_models.createIndex({ "project_id": 1, "type": 1 })
db.project_models.createIndex({ "project_id": 1, "name": 1 })
db.project_models.createIndex({ "updated_at": -1 })
```

### 5. Model Versions Collection

Stores version history for audit trail and rollback.

```javascript
{
  _id: ObjectId,                    // MongoDB object ID
  model_id: ObjectId,               // Reference to Project Models collection
  version: Number,                  // Version number
  content: Object,                  // BSON document (snapshot of model)
  changed_by: ObjectId,             // Reference to Users collection
  change_description: String,       // Description of changes
  created_at: ISODate,              // Version creation timestamp
  diff_size: Number                 // Size of changes (for statistics)
}

// Indexes
db.model_versions.createIndex({ "model_id": 1, "version": -1 })
db.model_versions.createIndex({ "created_at": -1 })
```

### 6. Project Activities Collection

Stores activity log for project timeline.

```javascript
{
  _id: ObjectId,                    // MongoDB object ID
  project_id: ObjectId,             // Reference to Projects collection
  user_id: ObjectId,                // Reference to Users collection
  activity_type: String,            // 'created' | 'updated' | 'deleted' | etc.
  entity_type: String,              // 'project' | 'model' | 'member' | etc.
  entity_id: ObjectId,              // Reference to affected entity
  description: String,              // Human-readable description
  metadata: Object,                 // Additional activity metadata
  created_at: ISODate               // Activity timestamp
}

// Indexes
db.project_activities.createIndex({ "project_id": 1, "created_at": -1 })
db.project_activities.createIndex({ "user_id": 1, "created_at": -1 })
```

---

## SQLite Schema (Local Storage)

For offline-first development, a local SQLite database mirrors the cloud schema.

### Users Table

```sql
CREATE TABLE users (
  id TEXT PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  email TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  avatar_url TEXT,
  role TEXT NOT NULL DEFAULT 'developer',
  permissions TEXT,                -- JSON array
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  last_synced_at TEXT
);

CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
```

### Projects Table

```sql
CREATE TABLE projects (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  namespace TEXT UNIQUE NOT NULL,
  description TEXT,
  owner_id TEXT NOT NULL,
  visibility TEXT NOT NULL DEFAULT 'private',
  settings TEXT,                   -- JSON object
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  last_synced_at TEXT,
  FOREIGN KEY (owner_id) REFERENCES users(id)
);

CREATE INDEX idx_projects_namespace ON projects(namespace);
CREATE INDEX idx_projects_owner_id ON projects(owner_id);
CREATE INDEX idx_projects_updated_at ON projects(updated_at DESC);
```

### Project Members Table

```sql
CREATE TABLE project_members (
  id TEXT PRIMARY KEY,
  project_id TEXT NOT NULL,
  user_id TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'editor',
  permissions TEXT,                -- JSON array (overrides)
  joined_at TEXT NOT NULL,
  last_synced_at TEXT,
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id),
  UNIQUE(project_id, user_id)
);

CREATE INDEX idx_project_members_project_id ON project_members(project_id);
CREATE INDEX idx_project_members_user_id ON project_members(user_id);
```

### Project Models Table

```sql
CREATE TABLE project_models (
  id TEXT PRIMARY KEY,
  project_id TEXT NOT NULL,
  name TEXT NOT NULL,
  type TEXT NOT NULL,
  content TEXT NOT NULL,           -- JSON object
  version INTEGER NOT NULL DEFAULT 1,
  created_by TEXT NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  updated_by TEXT NOT NULL,
  last_synced_at TEXT,
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
  FOREIGN KEY (created_by) REFERENCES users(id),
  FOREIGN KEY (updated_by) REFERENCES users(id)
);

CREATE INDEX idx_project_models_project_id ON project_models(project_id);
CREATE INDEX idx_project_models_type ON project_models(type);
```

### Model Versions Table

```sql
CREATE TABLE model_versions (
  id TEXT PRIMARY KEY,
  model_id TEXT NOT NULL,
  version INTEGER NOT NULL,
  content TEXT NOT NULL,           -- JSON object (snapshot)
  changed_by TEXT NOT NULL,
  change_description TEXT,
  created_at TEXT NOT NULL,
  FOREIGN KEY (model_id) REFERENCES project_models(id) ON DELETE CASCADE,
  FOREIGN KEY (changed_by) REFERENCES users(id),
  UNIQUE(model_id, version)
);

CREATE INDEX idx_model_versions_model_id ON model_versions(model_id, version DESC);
```

### Sync Queue Table

Tracks pending changes that need to be synced to cloud.

```sql
CREATE TABLE sync_queue (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  entity_type TEXT NOT NULL,       -- 'project' | 'model' | 'member'
  entity_id TEXT NOT NULL,
  operation TEXT NOT NULL,         -- 'create' | 'update' | 'delete'
  data TEXT,                       -- JSON object
  created_at TEXT NOT NULL,
  retry_count INTEGER DEFAULT 0,
  last_error TEXT
);

CREATE INDEX idx_sync_queue_created_at ON sync_queue(created_at);
CREATE INDEX idx_sync_queue_entity ON sync_queue(entity_type, entity_id);
```

---

## Data Sync Strategy

### Offline-First Approach

1. **Local-First Operations**: All operations are performed on local SQLite first
2. **Background Sync**: Changes are queued and synced to MongoDB when online
3. **Conflict Resolution**: Last-write-wins with version tracking
4. **Pull Updates**: Periodic pull from cloud for team collaboration

### Sync Flow

```
User Action → Local SQLite → Sync Queue → MongoDB (when online)
                   ↓
            Immediate UI Update
            
Cloud Changes → Pull Service → Local SQLite → UI Refresh
```

### Conflict Handling

- **Version Tracking**: Each model has a version number
- **Timestamp Comparison**: Use `updated_at` to detect conflicts
- **Merge Strategy**: Prompt user for conflict resolution on model edits
- **Auto-Merge**: Settings and metadata can auto-merge

---

## Security Considerations

### Authentication

- **JWT Tokens**: Used for API authentication
- **Token Storage**: Secure storage in Flutter secure_storage
- **Token Refresh**: Automatic refresh before expiration
- **Session Management**: Server-side session validation

### Authorization

- **Role-Based Access Control (RBAC)**: Users have global roles
- **Project-Level Permissions**: Team members have project-specific roles
- **Permission Checks**: Both client and server validate permissions
- **Audit Trail**: All changes logged in activities collection

### Data Protection

- **Password Hashing**: bcrypt with salt rounds
- **Encryption at Rest**: MongoDB encryption for sensitive data
- **Encryption in Transit**: TLS/SSL for all network communication
- **API Rate Limiting**: Prevent abuse and DoS attacks

---

## Performance Optimization

### Indexing Strategy

- **Frequent Queries**: Index all foreign keys and frequently queried fields
- **Composite Indexes**: For multi-field queries (e.g., project_id + type)
- **Covering Indexes**: Include commonly projected fields

### Caching

- **User Sessions**: Cache user data in memory
- **Project Metadata**: Cache project list and settings
- **Model Cache**: LRU cache for recently accessed models
- **TTL**: 5-minute TTL for cached data

### Query Optimization

- **Pagination**: Limit results with cursor-based pagination
- **Projection**: Only fetch required fields
- **Aggregation**: Use MongoDB aggregation pipeline for complex queries
- **Batch Operations**: Batch inserts and updates where possible

---

## Migration and Versioning

### Schema Versioning

- **Version Tracking**: Store schema version in metadata table
- **Migration Scripts**: Automated migration on version mismatch
- **Backward Compatibility**: Support N-1 version for gradual rollout
- **Rollback Plan**: Ability to rollback schema changes

### Data Migration

- **IR v1.0 to v2.0**: Migration tool for model format changes
- **User Data**: Preserve all user data during migrations
- **Testing**: Thorough testing on staging before production

---

## Monitoring and Maintenance

### Database Health

- **Monitoring**: Track query performance and slow queries
- **Alerts**: Set up alerts for high error rates or slow responses
- **Backup**: Automated daily backups with point-in-time recovery
- **Retention**: 30-day retention for model versions

### Analytics

- **Usage Metrics**: Track active users, projects, and models
- **Growth Metrics**: Monitor storage growth and plan capacity
- **Performance Metrics**: Query latency, throughput, error rates

---

## Future Enhancements

### Sprint M6: Global Library

Additional collections for enterprise library system:

- **Library Components**: Reusable domain components
- **Component Versions**: Version history for library components
- **Component Usage**: Track where components are used

### Sprint M8: IR Schema v2.0

Model schema updates to support:

- Entity definitions
- Read model definitions
- Command data models
- Library references
- Canvas metadata and connections

---

*This schema document is subject to updates as the project evolves.*
