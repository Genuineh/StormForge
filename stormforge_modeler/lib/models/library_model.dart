import 'package:equatable/equatable.dart';

/// Library component scope levels
enum LibraryScope {
  enterprise,
  organization,
  project;

  String get displayName {
    switch (this) {
      case LibraryScope.enterprise:
        return 'Enterprise';
      case LibraryScope.organization:
        return 'Organization';
      case LibraryScope.project:
        return 'Project';
    }
  }

  String get description {
    switch (this) {
      case LibraryScope.enterprise:
        return 'Available to all users globally';
      case LibraryScope.organization:
        return 'Available within your organization';
      case LibraryScope.project:
        return 'Available only in this project';
    }
  }

  String toJson() => name;

  static LibraryScope fromJson(String json) {
    return LibraryScope.values.firstWhere((e) => e.name == json);
  }
}

/// Component types that can be stored in the library
enum ComponentType {
  entity,
  valueObject,
  enumType,
  aggregate,
  command,
  event,
  readModel,
  policy,
  interface;

  String get displayName {
    switch (this) {
      case ComponentType.entity:
        return 'Entity';
      case ComponentType.valueObject:
        return 'Value Object';
      case ComponentType.enumType:
        return 'Enum';
      case ComponentType.aggregate:
        return 'Aggregate';
      case ComponentType.command:
        return 'Command';
      case ComponentType.event:
        return 'Event';
      case ComponentType.readModel:
        return 'Read Model';
      case ComponentType.policy:
        return 'Policy';
      case ComponentType.interface:
        return 'Interface';
    }
  }

  String toJson() {
    switch (this) {
      case ComponentType.valueObject:
        return 'valueObject';
      case ComponentType.enumType:
        return 'enumType';
      case ComponentType.readModel:
        return 'readModel';
      default:
        return name;
    }
  }

  static ComponentType fromJson(String json) {
    switch (json) {
      case 'valueObject':
        return ComponentType.valueObject;
      case 'enumType':
        return ComponentType.enumType;
      case 'readModel':
        return ComponentType.readModel;
      default:
        return ComponentType.values.firstWhere((e) => e.name == json);
    }
  }
}

/// Component status in the library
enum ComponentStatus {
  draft,
  active,
  deprecated,
  archived;

  String get displayName {
    switch (this) {
      case ComponentStatus.draft:
        return 'Draft';
      case ComponentStatus.active:
        return 'Active';
      case ComponentStatus.deprecated:
        return 'Deprecated';
      case ComponentStatus.archived:
        return 'Archived';
    }
  }

  String toJson() => name;

  static ComponentStatus fromJson(String json) {
    return ComponentStatus.values.firstWhere((e) => e.name == json);
  }
}

/// Component reference mode
enum ComponentReferenceMode {
  reference,
  copy,
  inherit;

  String get displayName {
    switch (this) {
      case ComponentReferenceMode.reference:
        return 'Reference';
      case ComponentReferenceMode.copy:
        return 'Copy';
      case ComponentReferenceMode.inherit:
        return 'Inherit';
    }
  }

  String get description {
    switch (this) {
      case ComponentReferenceMode.reference:
        return 'Use directly, updates sync';
      case ComponentReferenceMode.copy:
        return 'Make local copy, no sync';
      case ComponentReferenceMode.inherit:
        return 'Inherit and extend';
    }
  }

  String toJson() => name;

  static ComponentReferenceMode fromJson(String json) {
    return ComponentReferenceMode.values.firstWhere((e) => e.name == json);
  }
}

/// Usage statistics for a component
class UsageStats extends Equatable {
  final int projectCount;
  final int referenceCount;
  final DateTime? lastUsed;

  const UsageStats({
    this.projectCount = 0,
    this.referenceCount = 0,
    this.lastUsed,
  });

  factory UsageStats.fromJson(Map<String, dynamic> json) {
    return UsageStats(
      projectCount: json['projectCount'] as int? ?? 0,
      referenceCount: json['referenceCount'] as int? ?? 0,
      lastUsed: json['lastUsed'] != null
          ? DateTime.parse(json['lastUsed'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'projectCount': projectCount,
      'referenceCount': referenceCount,
      if (lastUsed != null) 'lastUsed': lastUsed!.toIso8601String(),
    };
  }

  UsageStats copyWith({
    int? projectCount,
    int? referenceCount,
    DateTime? lastUsed,
  }) {
    return UsageStats(
      projectCount: projectCount ?? this.projectCount,
      referenceCount: referenceCount ?? this.referenceCount,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }

  @override
  List<Object?> get props => [projectCount, referenceCount, lastUsed];
}

/// Library component - reusable domain component
class LibraryComponent extends Equatable {
  final String id;
  final String name;
  final String namespace;
  final LibraryScope scope;
  final ComponentType componentType;
  final String version;
  final String description;
  final String? author;
  final String? organizationId;
  final List<String> tags;
  final Map<String, dynamic> definition;
  final Map<String, dynamic> metadata;
  final ComponentStatus status;
  final UsageStats usageStats;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LibraryComponent({
    required this.id,
    required this.name,
    required this.namespace,
    required this.scope,
    required this.componentType,
    required this.version,
    required this.description,
    this.author,
    this.organizationId,
    this.tags = const [],
    required this.definition,
    this.metadata = const {},
    this.status = ComponentStatus.active,
    required this.usageStats,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LibraryComponent.fromJson(Map<String, dynamic> json) {
    return LibraryComponent(
      id: json['_id'] ?? json['id'] as String,
      name: json['name'] as String,
      namespace: json['namespace'] as String,
      scope: LibraryScope.fromJson(json['scope'] as String),
      componentType: ComponentType.fromJson(json['type'] as String),
      version: json['version'] as String,
      description: json['description'] as String,
      author: json['author'] as String?,
      organizationId: json['organizationId'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      definition: json['definition'] as Map<String, dynamic>,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      status: ComponentStatus.fromJson(json['status'] as String),
      usageStats: UsageStats.fromJson(json['usageStats'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'namespace': namespace,
      'scope': scope.toJson(),
      'type': componentType.toJson(),
      'version': version,
      'description': description,
      if (author != null) 'author': author,
      if (organizationId != null) 'organizationId': organizationId,
      'tags': tags,
      'definition': definition,
      'metadata': metadata,
      'status': status.toJson(),
      'usageStats': usageStats.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  LibraryComponent copyWith({
    String? id,
    String? name,
    String? namespace,
    LibraryScope? scope,
    ComponentType? componentType,
    String? version,
    String? description,
    String? author,
    String? organizationId,
    List<String>? tags,
    Map<String, dynamic>? definition,
    Map<String, dynamic>? metadata,
    ComponentStatus? status,
    UsageStats? usageStats,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LibraryComponent(
      id: id ?? this.id,
      name: name ?? this.name,
      namespace: namespace ?? this.namespace,
      scope: scope ?? this.scope,
      componentType: componentType ?? this.componentType,
      version: version ?? this.version,
      description: description ?? this.description,
      author: author ?? this.author,
      organizationId: organizationId ?? this.organizationId,
      tags: tags ?? this.tags,
      definition: definition ?? this.definition,
      metadata: metadata ?? this.metadata,
      status: status ?? this.status,
      usageStats: usageStats ?? this.usageStats,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        namespace,
        scope,
        componentType,
        version,
        description,
        author,
        organizationId,
        tags,
        definition,
        metadata,
        status,
        usageStats,
        createdAt,
        updatedAt,
      ];
}

/// Component version history entry
class ComponentVersion extends Equatable {
  final String id;
  final String componentId;
  final String version;
  final Map<String, dynamic> definition;
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

  factory ComponentVersion.fromJson(Map<String, dynamic> json) {
    return ComponentVersion(
      id: json['_id'] ?? json['id'] as String,
      componentId: json['componentId'] as String,
      version: json['version'] as String,
      definition: json['definition'] as Map<String, dynamic>,
      changeNotes: json['changeNotes'] as String,
      author: json['author'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'componentId': componentId,
      'version': version,
      'definition': definition,
      'changeNotes': changeNotes,
      'author': author,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        componentId,
        version,
        definition,
        changeNotes,
        author,
        createdAt,
      ];
}

/// Component reference - tracks component usage in projects
class ComponentReference extends Equatable {
  final String id;
  final String projectId;
  final String componentId;
  final String version;
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

  factory ComponentReference.fromJson(Map<String, dynamic> json) {
    return ComponentReference(
      id: json['_id'] ?? json['id'] as String,
      projectId: json['projectId'] as String,
      componentId: json['componentId'] as String,
      version: json['version'] as String,
      mode: ComponentReferenceMode.fromJson(json['mode'] as String),
      addedAt: DateTime.parse(json['addedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'projectId': projectId,
      'componentId': componentId,
      'version': version,
      'mode': mode.toJson(),
      'addedAt': addedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        projectId,
        componentId,
        version,
        mode,
        addedAt,
      ];
}

/// Project impact information for impact analysis
class ProjectImpact extends Equatable {
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

  factory ProjectImpact.fromJson(Map<String, dynamic> json) {
    return ProjectImpact(
      projectId: json['projectId'] as String,
      projectName: json['projectName'] as String,
      currentVersion: json['currentVersion'] as String,
      referenceMode:
          ComponentReferenceMode.fromJson(json['referenceMode'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'projectId': projectId,
      'projectName': projectName,
      'currentVersion': currentVersion,
      'referenceMode': referenceMode.toJson(),
    };
  }

  @override
  List<Object?> get props => [
        projectId,
        projectName,
        currentVersion,
        referenceMode,
      ];
}

/// Impact analysis result
class ImpactAnalysis extends Equatable {
  final String componentId;
  final List<ProjectImpact> affectedProjects;
  final int totalReferences;

  const ImpactAnalysis({
    required this.componentId,
    required this.affectedProjects,
    required this.totalReferences,
  });

  factory ImpactAnalysis.fromJson(Map<String, dynamic> json) {
    return ImpactAnalysis(
      componentId: json['componentId'] as String,
      affectedProjects: (json['affectedProjects'] as List<dynamic>)
          .map((e) => ProjectImpact.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalReferences: json['totalReferences'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'componentId': componentId,
      'affectedProjects': affectedProjects.map((e) => e.toJson()).toList(),
      'totalReferences': totalReferences,
    };
  }

  @override
  List<Object?> get props => [
        componentId,
        affectedProjects,
        totalReferences,
      ];
}
