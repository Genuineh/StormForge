import 'package:equatable/equatable.dart';
import 'package:stormforge_modeler/models/user_model.dart';
import 'package:uuid/uuid.dart';

/// Represents a team member in a project.
class TeamMember extends Equatable {
  /// Creates a team member.
  const TeamMember({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.role,
    this.permissions = const [],
    required this.joinedAt,
  });

  /// Unique identifier for this team membership.
  final String id;

  /// The project this member belongs to.
  final String projectId;

  /// The user ID.
  final String userId;

  /// The role of this member in the project.
  final TeamRole role;

  /// Project-specific permissions (overrides role defaults).
  final List<Permission> permissions;

  /// When this member joined the project.
  final DateTime joinedAt;

  /// Creates a new team member with default values.
  factory TeamMember.create({
    required String projectId,
    required String userId,
    TeamRole role = TeamRole.editor,
    List<Permission>? permissions,
  }) {
    return TeamMember(
      id: const Uuid().v4(),
      projectId: projectId,
      userId: userId,
      role: role,
      permissions: permissions ?? [],
      joinedAt: DateTime.now(),
    );
  }

  /// Creates a copy with the given properties.
  TeamMember copyWith({
    String? id,
    String? projectId,
    String? userId,
    TeamRole? role,
    List<Permission>? permissions,
    DateTime? joinedAt,
  }) {
    return TeamMember(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  /// Gets the effective permissions for this team member.
  List<Permission> getEffectivePermissions() {
    if (permissions.isNotEmpty) {
      return permissions;
    }
    return role.defaultPermissions;
  }

  /// Checks if the team member has a specific permission.
  bool hasPermission(Permission permission) {
    return getEffectivePermissions().contains(permission);
  }

  /// Converts this team member to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'user_id': userId,
      'role': role.name,
      'permissions': permissions.map((p) => p.name).toList(),
      'joined_at': joinedAt.toIso8601String(),
    };
  }

  /// Creates a team member from a JSON map.
  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      id: json['id'] as String? ?? '',
      projectId: json['project_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      role: TeamRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => TeamRole.editor,
      ),
      permissions: (json['permissions'] as List<dynamic>?)
              ?.map((p) => Permission.values.firstWhere(
                    (perm) => perm.name == p,
                    orElse: () => Permission.projectView,
                  ))
              .toList() ??
          [],
      joinedAt: json['joined_at'] != null
          ? DateTime.parse(json['joined_at'] as String)
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        projectId,
        userId,
        role,
        permissions,
        joinedAt,
      ];
}

/// Project team roles.
enum TeamRole {
  /// Owner of the project (full control).
  owner,

  /// Administrator (can manage team and settings).
  admin,

  /// Editor (can edit models and generate code).
  editor,

  /// Viewer (read-only access).
  viewer,
}

/// Extension to provide role-specific properties.
extension TeamRoleExtension on TeamRole {
  /// Default permissions for each role (cached)
  static const _ownerPermissions = [
    Permission.projectEdit,
    Permission.projectDelete,
    Permission.projectView,
    Permission.projectExport,
    Permission.modelEdit,
    Permission.modelView,
    Permission.modelExport,
    Permission.codeGenerate,
    Permission.teamManage,
  ];
  
  static const _adminPermissions = [
    Permission.projectEdit,
    Permission.projectView,
    Permission.projectExport,
    Permission.modelEdit,
    Permission.modelView,
    Permission.modelExport,
    Permission.codeGenerate,
    Permission.teamManage,
  ];
  
  static const _editorPermissions = [
    Permission.projectView,
    Permission.modelEdit,
    Permission.modelView,
    Permission.modelExport,
    Permission.codeGenerate,
  ];
  
  static const _viewerPermissions = [
    Permission.projectView,
    Permission.modelView,
  ];

  /// Display name for this role.
  String get displayName {
    switch (this) {
      case TeamRole.owner:
        return 'Owner';
      case TeamRole.admin:
        return 'Admin';
      case TeamRole.editor:
        return 'Editor';
      case TeamRole.viewer:
        return 'Viewer';
    }
  }

  /// Description of this role.
  String get description {
    switch (this) {
      case TeamRole.owner:
        return 'Full control over the project including deletion';
      case TeamRole.admin:
        return 'Can manage team members and project settings';
      case TeamRole.editor:
        return 'Can edit models and generate code';
      case TeamRole.viewer:
        return 'Read-only access to the project';
    }
  }

  /// Default permissions for this role.
  List<Permission> get defaultPermissions {
    switch (this) {
      case TeamRole.owner:
        return _ownerPermissions;
      case TeamRole.admin:
        return _adminPermissions;
      case TeamRole.editor:
        return _editorPermissions;
      case TeamRole.viewer:
        return _viewerPermissions;
    }
  }

  /// Whether this role can perform administrative actions.
  bool get canAdmin {
    return this == TeamRole.owner || this == TeamRole.admin;
  }

  /// Whether this role can edit content.
  bool get canEdit {
    return this == TeamRole.owner ||
        this == TeamRole.admin ||
        this == TeamRole.editor;
  }
}
