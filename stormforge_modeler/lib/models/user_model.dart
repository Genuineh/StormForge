import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

/// Represents a user in the StormForge system.
class User extends Equatable {
  /// Creates a user.
  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.displayName,
    this.avatarUrl = '',
    required this.role,
    this.permissions = const [],
    required this.createdAt,
  });

  /// Unique identifier for this user.
  final String id;

  /// Username (unique).
  final String username;

  /// Email address.
  final String email;

  /// Display name.
  final String displayName;

  /// URL to avatar image.
  final String avatarUrl;

  /// Global user role.
  final UserRole role;

  /// Global permissions.
  final List<Permission> permissions;

  /// When this user was created.
  final DateTime createdAt;

  /// Creates a new user with default values.
  factory User.create({
    required String username,
    required String email,
    required String displayName,
    String avatarUrl = '',
    UserRole role = UserRole.developer,
  }) {
    return User(
      id: const Uuid().v4(),
      username: username,
      email: email,
      displayName: displayName,
      avatarUrl: avatarUrl,
      role: role,
      createdAt: DateTime.now(),
    );
  }

  /// Creates a copy with the given properties.
  User copyWith({
    String? id,
    String? username,
    String? email,
    String? displayName,
    String? avatarUrl,
    UserRole? role,
    List<Permission>? permissions,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Checks if the user has a specific permission.
  bool hasPermission(Permission permission) {
    return permissions.contains(permission) ||
        role.defaultPermissions.contains(permission);
  }

  /// Converts this user to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'role': role.name,
      'permissions': permissions.map((p) => p.name).toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Creates a user from a JSON map.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String,
      avatarUrl: json['avatar_url'] as String? ?? '',
      role: UserRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => UserRole.developer,
      ),
      permissions: (json['permissions'] as List<dynamic>?)
              ?.map((p) => Permission.values.firstWhere(
                    (perm) => perm.name == p,
                    orElse: () => Permission.projectView,
                  ))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        username,
        email,
        displayName,
        avatarUrl,
        role,
        permissions,
        createdAt,
      ];
}

/// Global user roles.
enum UserRole {
  /// System administrator with all permissions.
  admin,

  /// Developer who can create and edit projects.
  developer,

  /// Viewer who can only view projects.
  viewer,
}

/// Extension to provide role-specific properties.
extension UserRoleExtension on UserRole {
  /// Default permissions for each role (cached)
  static const _adminPermissions = Permission.values;
  static const _developerPermissions = [
    Permission.projectCreate,
    Permission.projectEdit,
    Permission.projectView,
    Permission.projectExport,
    Permission.modelEdit,
    Permission.modelView,
    Permission.modelExport,
    Permission.codeGenerate,
    Permission.libraryView,
  ];
  static const _viewerPermissions = [
    Permission.projectView,
    Permission.modelView,
    Permission.libraryView,
  ];

  /// Display name for this role.
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.developer:
        return 'Developer';
      case UserRole.viewer:
        return 'Viewer';
    }
  }

  /// Default permissions for this role.
  List<Permission> get defaultPermissions {
    switch (this) {
      case UserRole.admin:
        return _adminPermissions;
      case UserRole.developer:
        return _developerPermissions;
      case UserRole.viewer:
        return _viewerPermissions;
    }
  }
}

/// System permissions.
enum Permission {
  /// Create new projects.
  projectCreate,

  /// Edit project settings.
  projectEdit,

  /// Delete projects.
  projectDelete,

  /// View projects.
  projectView,

  /// Export project data.
  projectExport,

  /// Edit models/canvas.
  modelEdit,

  /// View models.
  modelView,

  /// Export models.
  modelExport,

  /// Generate code.
  codeGenerate,

  /// Manage team members.
  teamManage,

  /// Edit global library.
  libraryEdit,

  /// View global library.
  libraryView,
}

/// Extension to provide permission properties.
extension PermissionExtension on Permission {
  /// Display name for this permission.
  String get displayName {
    switch (this) {
      case Permission.projectCreate:
        return 'Create Projects';
      case Permission.projectEdit:
        return 'Edit Projects';
      case Permission.projectDelete:
        return 'Delete Projects';
      case Permission.projectView:
        return 'View Projects';
      case Permission.projectExport:
        return 'Export Projects';
      case Permission.modelEdit:
        return 'Edit Models';
      case Permission.modelView:
        return 'View Models';
      case Permission.modelExport:
        return 'Export Models';
      case Permission.codeGenerate:
        return 'Generate Code';
      case Permission.teamManage:
        return 'Manage Team';
      case Permission.libraryEdit:
        return 'Edit Library';
      case Permission.libraryView:
        return 'View Library';
    }
  }

  /// Description of this permission.
  String get description {
    switch (this) {
      case Permission.projectCreate:
        return 'Create new projects';
      case Permission.projectEdit:
        return 'Edit project settings and metadata';
      case Permission.projectDelete:
        return 'Delete projects';
      case Permission.projectView:
        return 'View projects';
      case Permission.projectExport:
        return 'Export project data';
      case Permission.modelEdit:
        return 'Edit models and canvas elements';
      case Permission.modelView:
        return 'View models';
      case Permission.modelExport:
        return 'Export models to IR format';
      case Permission.codeGenerate:
        return 'Generate code from models';
      case Permission.teamManage:
        return 'Manage team members and permissions';
      case Permission.libraryEdit:
        return 'Edit global library components';
      case Permission.libraryView:
        return 'View global library components';
    }
  }
}
