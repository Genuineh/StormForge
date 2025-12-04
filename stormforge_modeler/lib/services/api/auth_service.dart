import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:stormforge_modeler/models/user_model.dart';
import 'package:stormforge_modeler/services/api/api_client.dart';

/// Service for authentication operations.
class AuthService {
  /// Creates an auth service.
  AuthService({
    ApiClient? apiClient,
    FlutterSecureStorage? secureStorage,
  })  : _apiClient = apiClient ?? ApiClient(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final ApiClient _apiClient;
  final FlutterSecureStorage _secureStorage;

  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'user_id';

  /// Registers a new user.
  Future<User> register({
    required String username,
    required String email,
    required String displayName,
    required String password,
    UserRole role = UserRole.developer,
  }) async {
    final response = await _apiClient.post('/api/auth/register', {
      'username': username,
      'email': email,
      'display_name': displayName,
      'password': password,
      'role': role.name,
    });

    final user = User.fromJson(response['user'] as Map<String, dynamic>);
    final token = response['token'] as String;

    // Store authentication data
    await _secureStorage.write(key: _tokenKey, value: token);
    await _secureStorage.write(key: _userIdKey, value: user.id);
    _apiClient.token = token;

    return user;
  }

  /// Logs in a user.
  Future<User> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    final response = await _apiClient.post('/api/auth/login', {
      'username_or_email': usernameOrEmail,
      'password': password,
    });

    final user = User.fromJson(response['user'] as Map<String, dynamic>);
    final token = response['token'] as String;

    // Store authentication data
    await _secureStorage.write(key: _tokenKey, value: token);
    await _secureStorage.write(key: _userIdKey, value: user.id);
    _apiClient.token = token;

    return user;
  }

  /// Logs out the current user.
  Future<void> logout() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _userIdKey);
    _apiClient.token = null;
  }

  /// Checks if a user is logged in.
  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(key: _tokenKey);
    return token != null;
  }

  /// Gets the stored authentication token.
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  /// Gets the current user ID.
  Future<String?> getCurrentUserId() async {
    return await _secureStorage.read(key: _userIdKey);
  }

  /// Initializes the API client with stored token.
  Future<void> initialize() async {
    final token = await getToken();
    if (token != null) {
      _apiClient.token = token;
    }
  }
}
