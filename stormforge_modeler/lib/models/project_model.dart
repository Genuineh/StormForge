import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

/// Represents a StormForge project.
class Project extends Equatable {
  /// Creates a project.
  const Project({
    required this.id,
    required this.name,
    required this.namespace,
    this.description = '',
    required this.ownerId,
    required this.visibility,
    required this.createdAt,
    required this.updatedAt,
    this.settings = const ProjectSettings(),
  });

  /// Unique identifier for this project.
  final String id;

  /// The name of this project.
  final String name;

  /// The namespace for generated code (must be unique).
  final String namespace;

  /// Optional description.
  final String description;

  /// The user ID of the project owner.
  final String ownerId;

  /// Project visibility setting.
  final ProjectVisibility visibility;

  /// When this project was created.
  final DateTime createdAt;

  /// When this project was last updated.
  final DateTime updatedAt;

  /// Project-specific settings.
  final ProjectSettings settings;

  /// Creates a new project with default values.
  factory Project.create({
    required String name,
    required String namespace,
    required String ownerId,
    String description = '',
    ProjectVisibility visibility = ProjectVisibility.private,
  }) {
    final now = DateTime.now();
    return Project(
      id: const Uuid().v4(),
      name: name,
      namespace: namespace,
      description: description,
      ownerId: ownerId,
      visibility: visibility,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Creates a copy with the given properties.
  Project copyWith({
    String? id,
    String? name,
    String? namespace,
    String? description,
    String? ownerId,
    ProjectVisibility? visibility,
    DateTime? createdAt,
    DateTime? updatedAt,
    ProjectSettings? settings,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      namespace: namespace ?? this.namespace,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      visibility: visibility ?? this.visibility,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      settings: settings ?? this.settings,
    );
  }

  /// Converts this project to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'namespace': namespace,
      'description': description,
      'owner_id': ownerId,
      'visibility': visibility.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'settings': settings.toJson(),
    };
  }

  /// Creates a project from a JSON map.
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      namespace: json['namespace'] as String? ?? '',
      description: json['description'] as String? ?? '',
      ownerId: json['owner_id'] as String? ?? '',
      visibility: ProjectVisibility.values.firstWhere(
        (v) => v.name == json['visibility'],
        orElse: () => ProjectVisibility.private,
      ),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      settings: json['settings'] != null
          ? ProjectSettings.fromJson(json['settings'] as Map<String, dynamic>)
          : const ProjectSettings(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        namespace,
        description,
        ownerId,
        visibility,
        createdAt,
        updatedAt,
        settings,
      ];
}

/// Project visibility settings.
enum ProjectVisibility {
  /// Only the owner can see this project.
  private,

  /// Only team members can see this project.
  team,

  /// Anyone can see this project.
  public,
}

/// Project-specific settings.
class ProjectSettings extends Equatable {
  /// Creates project settings.
  const ProjectSettings({
    this.gitIntegration = const GitIntegrationSettings(),
    this.aiSettings = const AISettings(),
  });

  /// Git integration configuration.
  final GitIntegrationSettings gitIntegration;

  /// AI generation settings.
  final AISettings aiSettings;

  /// Converts to JSON.
  Map<String, dynamic> toJson() {
    return {
      'git_integration': gitIntegration.toJson(),
      'ai_settings': aiSettings.toJson(),
    };
  }

  /// Creates from JSON.
  factory ProjectSettings.fromJson(Map<String, dynamic> json) {
    return ProjectSettings(
      gitIntegration: json['git_integration'] != null
          ? GitIntegrationSettings.fromJson(
              json['git_integration'] as Map<String, dynamic>)
          : const GitIntegrationSettings(),
      aiSettings: json['ai_settings'] != null
          ? AISettings.fromJson(json['ai_settings'] as Map<String, dynamic>)
          : const AISettings(),
    );
  }

  @override
  List<Object?> get props => [gitIntegration, aiSettings];
}

/// Git integration settings.
class GitIntegrationSettings extends Equatable {
  /// Creates git integration settings.
  const GitIntegrationSettings({
    this.enabled = false,
    this.autoCommit = true,
    this.commitMessage = 'Auto-save',
    this.repositoryUrl = '',
    this.branch = 'main',
  });

  /// Whether Git integration is enabled.
  final bool enabled;

  /// Whether to auto-commit on save.
  final bool autoCommit;

  /// Default commit message.
  final String commitMessage;

  /// Repository URL.
  final String repositoryUrl;

  /// Default branch name.
  final String branch;

  /// Converts to JSON.
  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'auto_commit': autoCommit,
      'commit_message': commitMessage,
      'repository_url': repositoryUrl,
      'branch': branch,
    };
  }

  /// Creates from JSON.
  factory GitIntegrationSettings.fromJson(Map<String, dynamic> json) {
    return GitIntegrationSettings(
      enabled: json['enabled'] as bool? ?? false,
      autoCommit: json['auto_commit'] as bool? ?? true,
      commitMessage: json['commit_message'] as String? ?? 'Auto-save',
      repositoryUrl: json['repository_url'] as String? ?? '',
      branch: json['branch'] as String? ?? 'main',
    );
  }

  @override
  List<Object?> get props =>
      [enabled, autoCommit, commitMessage, repositoryUrl, branch];
}

/// AI generation settings.
class AISettings extends Equatable {
  /// Creates AI settings.
  const AISettings({
    this.enabled = false,
    this.provider = 'claude',
    this.model = 'claude-3-5-sonnet',
    this.temperature = 0.7,
  });

  /// Whether AI generation is enabled.
  final bool enabled;

  /// AI provider name.
  final String provider;

  /// Model name.
  final String model;

  /// Temperature for generation.
  final double temperature;

  /// Converts to JSON.
  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'provider': provider,
      'model': model,
      'temperature': temperature,
    };
  }

  /// Creates from JSON.
  factory AISettings.fromJson(Map<String, dynamic> json) {
    return AISettings(
      enabled: json['enabled'] as bool? ?? false,
      provider: json['provider'] as String? ?? 'claude',
      model: json['model'] as String? ?? 'claude-3-5-sonnet',
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
    );
  }

  @override
  List<Object?> get props => [enabled, provider, model, temperature];
}
