# Enterprise Global Library Design

> Design specification for the enterprise-level global component library
> Version: 1.0
> Date: 2025-12-03

---

## Overview

The Enterprise Global Library is a three-tier hierarchical system for sharing reusable domain components (entities, value objects, commands, events, etc.) across projects, organizations, and the entire enterprise.

## Goals

1. **Reusability**: Share common patterns and components
2. **Consistency**: Standardize domain models across the organization
3. **Versioning**: Manage component versions safely
4. **Discovery**: Easy to find and use existing components
5. **Governance**: Control who can publish to different scopes

## Architecture

### Three-Tier Hierarchy

```
┌─────────────────────────────────────────────────────────┐
│                 Enterprise Library                       │
│  (Global - All users, curated by platform team)         │
│  - Common types (Money, Address, Email, etc.)           │
│  - Standard patterns (Pagination, ErrorHandling)        │
│  - Industry models (ISO standards, etc.)                │
└─────────────────────────────────────────────────────────┘
                        ↓ references
┌─────────────────────────────────────────────────────────┐
│              Organization Library                        │
│  (Company-wide, managed by org admins)                  │
│  - Company-specific types (EmployeeId, DeptCode)        │
│  - Shared domain models (Customer, Product)             │
│  - Company policies and rules                           │
└─────────────────────────────────────────────────────────┘
                        ↓ references
┌─────────────────────────────────────────────────────────┐
│                  Project Library                         │
│  (Project-specific, managed by project team)            │
│  - Domain-specific entities and value objects           │
│  - Project-specific patterns                            │
└─────────────────────────────────────────────────────────┘
```

## Data Model

```dart
enum LibraryScope {
  enterprise('Enterprise', 'Available to all users globally'),
  organization('Organization', 'Available within your organization'),
  project('Project', 'Available only in this project');
  
  const LibraryScope(this.displayName, this.description);
  final String displayName;
  final String description;
}

enum ComponentType {
  entity('Entity', Icons.layers),
  valueObject('Value Object', Icons.data_object),
  enumType('Enum', Icons.list),
  aggregate('Aggregate', Icons.account_tree),
  command('Command', Icons.play_arrow),
  event('Event', Icons.event_note),
  readModel('Read Model', Icons.visibility),
  policy('Policy', Icons.policy),
  interface('Interface', Icons.integration_instructions);
  
  const ComponentType(this.displayName, this.icon);
  final String displayName;
  final IconData icon;
}

class LibraryComponent extends Equatable {
  final String id;
  final String name;
  final String namespace; // e.g., "com.acme.common.Money"
  final LibraryScope scope;
  final ComponentType type;
  final String version; // Semantic versioning
  final String description;
  final String? author;
  final String? organizationId;
  final List<String> tags;
  final dynamic definition; // The actual component data
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ComponentStatus status;
  final UsageStats usageStats;
  
  const LibraryComponent({
    required this.id,
    required this.name,
    required this.namespace,
    required this.scope,
    required this.type,
    required this.version,
    required this.description,
    this.author,
    this.organizationId,
    this.tags = const [],
    required this.definition,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
    this.status = ComponentStatus.active,
    required this.usageStats,
  });
  
  // Version comparison
  bool isNewerThan(String otherVersion) {
    return _compareVersions(version, otherVersion) > 0;
  }
  
  int _compareVersions(String v1, String v2) {
    final parts1 = v1.split('.').map(int.parse).toList();
    final parts2 = v2.split('.').map(int.parse).toList();
    
    for (int i = 0; i < 3; i++) {
      if (parts1[i] != parts2[i]) {
        return parts1[i] - parts2[i];
      }
    }
    return 0;
  }
}

enum ComponentStatus {
  draft,       // Being developed
  active,      // Published and available
  deprecated,  // Marked for removal
  archived,    // No longer available
}

class UsageStats extends Equatable {
  final int projectCount;    // Number of projects using this
  final int referenceCount;  // Number of references
  final DateTime? lastUsed;
  
  const UsageStats({
    this.projectCount = 0,
    this.referenceCount = 0,
    this.lastUsed,
  });
}

class ComponentVersion extends Equatable {
  final String id;
  final String componentId;
  final String version;
  final dynamic definition;
  final String changeNotes;
  final String author;
  final DateTime createdAt;
  
  const ComponentVersion({
    required this.id,
    required this.componentId,
    required this.version,
    required this.definition,
    required this.changeNotes,
    required this.author,
    required this.createdAt,
  });
}

class ComponentReference extends Equatable {
  final String id;
  final String projectId;
  final String componentId;
  final String version; // Locked version
  final ComponentReferenceMode mode;
  final DateTime addedAt;
  
  const ComponentReference({
    required this.id,
    required this.projectId,
    required this.componentId,
    required this.version,
    required this.mode,
    required this.addedAt,
  });
}

enum ComponentReferenceMode {
  reference,   // Use directly, updates sync
  copy,        // Make local copy, no sync
  inherit,     // Inherit and extend
}
```

## UI Components

### Library Browser

```dart
class LibraryBrowser extends StatefulWidget {
  @override
  _LibraryBrowserState createState() => _LibraryBrowserState();
}

class _LibraryBrowserState extends State<LibraryBrowser> {
  LibraryScope _selectedScope = LibraryScope.enterprise;
  ComponentType? _filterType;
  String _searchQuery = '';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Global Library'),
        actions: [
          IconButton(
            icon: Icon(Icons.publish),
            onPressed: _showPublishDialog,
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar - Categories and filters
          Container(
            width: 250,
            child: _buildSidebar(),
          ),
          
          // Main content - Component grid
          Expanded(
            child: _buildComponentGrid(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSidebar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Scope selector
        Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Scope', style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height: 8),
              ...LibraryScope.values.map((scope) {
                return RadioListTile<LibraryScope>(
                  title: Text(scope.displayName),
                  value: scope,
                  groupValue: _selectedScope,
                  onChanged: (value) {
                    setState(() => _selectedScope = value!);
                  },
                );
              }),
            ],
          ),
        ),
        
        Divider(),
        
        // Type filter
        Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Type', style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height: 8),
              ...ComponentType.values.map((type) {
                return CheckboxListTile(
                  title: Row(
                    children: [
                      Icon(type.icon, size: 16),
                      SizedBox(width: 8),
                      Text(type.displayName),
                    ],
                  ),
                  value: _filterType == type,
                  onChanged: (checked) {
                    setState(() {
                      _filterType = checked! ? type : null;
                    });
                  },
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildComponentGrid() {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search components...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
          ),
        ),
        
        // Component grid
        Expanded(
          child: StreamBuilder<List<LibraryComponent>>(
            stream: _watchComponents(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              
              final components = snapshot.data!;
              
              return GridView.builder(
                padding: EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: components.length,
                itemBuilder: (context, index) {
                  return ComponentCard(
                    component: components[index],
                    onTap: () => _showComponentDetails(components[index]),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
  
  Stream<List<LibraryComponent>> _watchComponents() {
    // TODO: Implement filtering and search
    return context.read<LibraryService>().watchComponents(
      scope: _selectedScope,
      type: _filterType,
      searchQuery: _searchQuery,
    );
  }
  
  void _showComponentDetails(LibraryComponent component) {
    showDialog(
      context: context,
      builder: (context) => ComponentDetailsDialog(component: component),
    );
  }
  
  void _showPublishDialog() {
    // Show dialog to publish new component
  }
}

class ComponentCard extends StatelessWidget {
  final LibraryComponent component;
  final VoidCallback onTap;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and status
              Row(
                children: [
                  Icon(component.type.icon, size: 24),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      component.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (component.status == ComponentStatus.deprecated)
                    Chip(
                      label: Text('Deprecated', style: TextStyle(fontSize: 10)),
                      backgroundColor: Colors.orange,
                    ),
                ],
              ),
              
              SizedBox(height: 8),
              
              // Description
              Text(
                component.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              
              Spacer(),
              
              // Footer with version and usage
              Row(
                children: [
                  Text(
                    'v${component.version}',
                    style: Theme.of(context).textTheme.caption,
                  ),
                  Spacer(),
                  Icon(Icons.projects, size: 12),
                  SizedBox(width: 4),
                  Text(
                    '${component.usageStats.projectCount}',
                    style: Theme.of(context).textTheme.caption,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Component Details Dialog

```dart
class ComponentDetailsDialog extends StatelessWidget {
  final LibraryComponent component;
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 700,
        height: 600,
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
              ),
              child: Row(
                children: [
                  Icon(component.type.icon, size: 48),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          component.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        SizedBox(height: 4),
                        Text(
                          component.namespace,
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // Tabs
            Expanded(
              child: DefaultTabController(
                length: 4,
                child: Column(
                  children: [
                    TabBar(
                      tabs: [
                        Tab(text: 'Overview'),
                        Tab(text: 'Definition'),
                        Tab(text: 'Versions'),
                        Tab(text: 'Usage'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildOverviewTab(component),
                          _buildDefinitionTab(component),
                          _buildVersionsTab(component),
                          _buildUsageTab(component),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Actions
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (component.scope != LibraryScope.enterprise)
                    OutlinedButton.icon(
                      icon: Icon(Icons.content_copy),
                      label: Text('Copy to Project'),
                      onPressed: () => _copyToProject(context, component),
                    ),
                  SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: Icon(Icons.add),
                    label: Text('Use in Project'),
                    onPressed: () => _useInProject(context, component),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOverviewTab(LibraryComponent component) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(component.description),
          SizedBox(height: 24),
          
          // Metadata
          _buildMetadataRow('Type', component.type.displayName),
          _buildMetadataRow('Scope', component.scope.displayName),
          _buildMetadataRow('Version', component.version),
          if (component.author != null)
            _buildMetadataRow('Author', component.author!),
          _buildMetadataRow('Created', _formatDate(component.createdAt)),
          _buildMetadataRow('Updated', _formatDate(component.updatedAt)),
          
          // Tags
          if (component.tags.isNotEmpty) ...[
            SizedBox(height: 16),
            Text('Tags', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: component.tags.map((tag) => Chip(label: Text(tag))).toList(),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildDefinitionTab(LibraryComponent component) {
    // Show component definition based on type
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Definition', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _formatDefinition(component.definition),
              style: TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildVersionsTab(LibraryComponent component) {
    return StreamBuilder<List<ComponentVersion>>(
      stream: context.read<LibraryService>().watchVersions(component.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        
        final versions = snapshot.data!;
        
        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: versions.length,
          itemBuilder: (context, index) {
            final version = versions[index];
            return ListTile(
              leading: Icon(Icons.history),
              title: Text('Version ${version.version}'),
              subtitle: Text(version.changeNotes),
              trailing: Text(_formatDate(version.createdAt)),
            );
          },
        );
      },
    );
  }
  
  Widget _buildUsageTab(LibraryComponent component) {
    return StreamBuilder<List<ProjectUsage>>(
      stream: context.read<LibraryService>().watchUsage(component.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        
        final usage = snapshot.data!;
        
        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: usage.length,
          itemBuilder: (context, index) {
            final project = usage[index];
            return ListTile(
              leading: Icon(Icons.folder),
              title: Text(project.projectName),
              subtitle: Text('Version ${project.version} • ${project.referenceCount} references'),
            );
          },
        );
      },
    );
  }
  
  Widget _buildMetadataRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  String _formatDefinition(dynamic definition) {
    // Format definition based on type
    return jsonEncode(definition);
  }
  
  void _copyToProject(BuildContext context, LibraryComponent component) {
    // Copy component to project library
  }
  
  void _useInProject(BuildContext context, LibraryComponent component) {
    // Add reference to project
  }
}
```

## Service Layer

```dart
class LibraryService {
  final LibraryRepository _repository;
  final EventBus _eventBus;
  
  // Browse and search
  Stream<List<LibraryComponent>> watchComponents({
    required LibraryScope scope,
    ComponentType? type,
    String? searchQuery,
  }) {
    return _repository.watchComponents(
      scope: scope,
      type: type,
      searchQuery: searchQuery,
    );
  }
  
  Future<LibraryComponent?> findById(String id) async {
    return await _repository.findById(id);
  }
  
  Future<List<LibraryComponent>> search(String query) async {
    return await _repository.search(query);
  }
  
  // Publishing
  Future<LibraryComponent> publishComponent(
    PublishComponentRequest request,
  ) async {
    // Validate permissions
    await _validatePublishPermission(request.scope, request.userId);
    
    // Validate component definition
    _validateComponentDefinition(request.type, request.definition);
    
    // Create component
    final component = LibraryComponent(
      id: Uuid().v4(),
      name: request.name,
      namespace: request.namespace,
      scope: request.scope,
      type: request.type,
      version: request.version,
      description: request.description,
      author: request.author,
      organizationId: request.organizationId,
      tags: request.tags,
      definition: request.definition,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      usageStats: UsageStats(),
    );
    
    // Save
    await _repository.save(component);
    
    // Save version history
    await _repository.saveVersion(ComponentVersion(
      id: Uuid().v4(),
      componentId: component.id,
      version: component.version,
      definition: component.definition,
      changeNotes: 'Initial version',
      author: request.author,
      createdAt: DateTime.now(),
    ));
    
    _eventBus.fire(ComponentPublishedEvent(component));
    
    return component;
  }
  
  Future<void> _validatePublishPermission(
    LibraryScope scope,
    String userId,
  ) async {
    switch (scope) {
      case LibraryScope.enterprise:
        // Only platform admins
        if (!await _isEnterpriseAdmin(userId)) {
          throw PermissionException('Only enterprise admins can publish to enterprise library');
        }
        break;
      case LibraryScope.organization:
        // Organization admins
        if (!await _isOrganizationAdmin(userId)) {
          throw PermissionException('Only organization admins can publish to organization library');
        }
        break;
      case LibraryScope.project:
        // Project members
        // No special permission needed
        break;
    }
  }
  
  // Version management
  Future<LibraryComponent> updateVersion(
    String componentId,
    UpdateVersionRequest request,
  ) async {
    final component = await _repository.findById(componentId);
    if (component == null) {
      throw NotFoundException('Component not found');
    }
    
    // Validate new version is higher
    if (!_isNewerVersion(request.newVersion, component.version)) {
      throw ValidationException('New version must be higher than current version');
    }
    
    // Update component
    final updated = component.copyWith(
      version: request.newVersion,
      definition: request.definition,
      updatedAt: DateTime.now(),
    );
    
    await _repository.save(updated);
    
    // Save version history
    await _repository.saveVersion(ComponentVersion(
      id: Uuid().v4(),
      componentId: componentId,
      version: request.newVersion,
      definition: request.definition,
      changeNotes: request.changeNotes,
      author: request.author,
      createdAt: DateTime.now(),
    ));
    
    _eventBus.fire(ComponentUpdatedEvent(updated));
    
    return updated;
  }
  
  // Usage tracking
  Future<ComponentReference> addReference(
    String projectId,
    String componentId,
    ComponentReferenceMode mode,
  ) async {
    final component = await _repository.findById(componentId);
    if (component == null) {
      throw NotFoundException('Component not found');
    }
    
    final reference = ComponentReference(
      id: Uuid().v4(),
      projectId: projectId,
      componentId: componentId,
      version: component.version,
      mode: mode,
      addedAt: DateTime.now(),
    );
    
    await _repository.saveReference(reference);
    
    // Update usage stats
    await _updateUsageStats(componentId);
    
    return reference;
  }
  
  Future<void> _updateUsageStats(String componentId) async {
    final references = await _repository.findReferencesByComponent(componentId);
    final projects = references.map((r) => r.projectId).toSet();
    
    final stats = UsageStats(
      projectCount: projects.length,
      referenceCount: references.length,
      lastUsed: DateTime.now(),
    );
    
    await _repository.updateUsageStats(componentId, stats);
  }
  
  // Impact analysis
  Future<ImpactAnalysis> analyzeImpact(String componentId) async {
    final references = await _repository.findReferencesByComponent(componentId);
    
    final affectedProjects = <ProjectImpact>[];
    
    for (final ref in references) {
      final project = await _getProject(ref.projectId);
      affectedProjects.add(ProjectImpact(
        projectId: project.id,
        projectName: project.name,
        currentVersion: ref.version,
        referenceMode: ref.mode,
      ));
    }
    
    return ImpactAnalysis(
      componentId: componentId,
      affectedProjects: affectedProjects,
      totalReferences: references.length,
    );
  }
  
  bool _isNewerVersion(String v1, String v2) {
    final parts1 = v1.split('.').map(int.parse).toList();
    final parts2 = v2.split('.').map(int.parse).toList();
    
    for (int i = 0; i < 3; i++) {
      if (parts1[i] > parts2[i]) return true;
      if (parts1[i] < parts2[i]) return false;
    }
    return false;
  }
}

class ImpactAnalysis {
  final String componentId;
  final List<ProjectImpact> affectedProjects;
  final int totalReferences;
  
  const ImpactAnalysis({
    required this.componentId,
    required this.affectedProjects,
    required this.totalReferences,
  });
}

class ProjectImpact {
  final String projectId;
  final String projectName;
  final String currentVersion;
  final ComponentReferenceMode referenceMode;
  
  const ProjectImpact({
    required this.projectId,
    required this.projectName,
    required this.currentVersion,
    required this.referenceMode,
  });
}
```

## Standard Library Components

### Enterprise Library - Common Types

```yaml
# Money value object
component:
  name: Money
  namespace: com.stormforge.common.Money
  scope: enterprise
  type: valueObject
  version: "1.0.0"
  description: "Standard money value object with amount and currency"
  definition:
    properties:
      - name: amount
        type: Decimal
        required: true
        validation:
          min: 0
      - name: currency
        type: String
        required: true
        default: "USD"
        validation:
          pattern: "^[A-Z]{3}$"

# Address value object
component:
  name: Address
  namespace: com.stormforge.common.Address
  scope: enterprise
  type: valueObject
  version: "1.0.0"
  description: "Standard postal address"
  definition:
    properties:
      - name: street
        type: String
        required: true
      - name: city
        type: String
        required: true
      - name: state
        type: String
        required: false
      - name: postalCode
        type: String
        required: true
      - name: country
        type: String
        required: true

# Email value object
component:
  name: Email
  namespace: com.stormforge.common.Email
  scope: enterprise
  type: valueObject
  version: "1.0.0"
  description: "Email address with validation"
  definition:
    properties:
      - name: value
        type: String
        required: true
        validation:
          pattern: "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
```

## Database Schema

```sql
-- Library components table
CREATE TABLE library_components (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    namespace VARCHAR(500) NOT NULL UNIQUE,
    scope VARCHAR(20) NOT NULL,
    type VARCHAR(50) NOT NULL,
    version VARCHAR(20) NOT NULL,
    description TEXT NOT NULL,
    author VARCHAR(255),
    organization_id UUID,
    tags TEXT[],
    definition JSONB NOT NULL,
    metadata JSONB NOT NULL DEFAULT '{}',
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Component versions table
CREATE TABLE component_versions (
    id UUID PRIMARY KEY,
    component_id UUID NOT NULL REFERENCES library_components(id) ON DELETE CASCADE,
    version VARCHAR(20) NOT NULL,
    definition JSONB NOT NULL,
    change_notes TEXT NOT NULL,
    author VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE(component_id, version)
);

-- Component references table (project usage)
CREATE TABLE component_references (
    id UUID PRIMARY KEY,
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    component_id UUID NOT NULL REFERENCES library_components(id),
    version VARCHAR(20) NOT NULL,
    mode VARCHAR(20) NOT NULL,
    added_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE(project_id, component_id)
);

-- Usage statistics table
CREATE TABLE component_usage_stats (
    component_id UUID PRIMARY KEY REFERENCES library_components(id) ON DELETE CASCADE,
    project_count INTEGER NOT NULL DEFAULT 0,
    reference_count INTEGER NOT NULL DEFAULT 0,
    last_used TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_library_components_scope ON library_components(scope);
CREATE INDEX idx_library_components_type ON library_components(type);
CREATE INDEX idx_library_components_namespace ON library_components(namespace);
CREATE INDEX idx_library_components_org ON library_components(organization_id);
CREATE INDEX idx_component_references_project ON component_references(project_id);
CREATE INDEX idx_component_references_component ON component_references(component_id);

-- Full text search index
CREATE INDEX idx_library_components_search ON library_components USING gin(to_tsvector('english', name || ' ' || description));
```

---

## Testing

### Unit Tests
- Version comparison logic
- Permission validation
- Component definition validation

### Integration Tests
- Publishing components
- Adding references
- Version updates
- Impact analysis

---

*This design will be refined during implementation.*
