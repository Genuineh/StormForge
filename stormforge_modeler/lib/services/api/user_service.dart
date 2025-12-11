import 'package:stormforge_modeler/models/user_model.dart';
import 'package:stormforge_modeler/services/api/api_client.dart';

/// Service for user management operations.
class UserService {
  /// Creates a user service.
  UserService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  /// Lists all users.
  Future<List<User>> listUsers() async {
    final response = await _apiClient.get('/api/users');
    
    List<dynamic> usersList;
    if (response is List<dynamic>) {
      usersList = response;
    } else if (response is Map<String, dynamic> && response.containsKey('users')) {
      usersList = response['users'] as List<dynamic>;
    } else {
      throw Exception('Unexpected response format for users list');
    }
    
    final users = usersList
        .map((u) => User.fromJson(u as Map<String, dynamic>))
        .toList();
    return users;
  }

  /// Gets a user by ID.
  Future<User> getUser(String userId) async {
    final response = await _apiClient.get('/api/users/$userId');
    return User.fromJson(response as Map<String, dynamic>);
  }

  /// Updates a user.
  Future<User> updateUser({
    required String userId,
    String? username,
    String? email,
    String? displayName,
    String? avatarUrl,
    UserRole? role,
  }) async {
    final body = <String, dynamic>{};
    if (username != null) body['username'] = username;
    if (email != null) body['email'] = email;
    if (displayName != null) body['display_name'] = displayName;
    if (avatarUrl != null) body['avatar_url'] = avatarUrl;
    if (role != null) body['role'] = role.name;

    final response = await _apiClient.put('/api/users/$userId', body);
    return User.fromJson(response as Map<String, dynamic>);
  }
}
