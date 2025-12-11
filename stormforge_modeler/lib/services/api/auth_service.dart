import 'package:shared_preferences/shared_preferences.dart';
import 'package:stormforge_modeler/models/user_model.dart';
import 'package:stormforge_modeler/services/api/api_client.dart';

/// Service for authentication operations.
class AuthService {
  /// Creates an auth service.
  AuthService({
    ApiClient? apiClient,
    SharedPreferences? sharedPreferences,
  })  : _apiClient = apiClient ?? ApiClient(),
        _sharedPreferences = sharedPreferences;

  final ApiClient _apiClient;
  final SharedPreferences? _sharedPreferences;

  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'user_id';

  /// Gets the SharedPreferences instance.
  ///
  /// Note: SharedPreferences stores data in plain text. For production use on platforms
  /// that require encryption (mobile), consider using flutter_secure_storage or
  /// implementing encryption on top of SharedPreferences. For Linux compatibility,
  /// we use SharedPreferences as flutter_secure_storage_linux has build issues.
  Future<SharedPreferences> get _prefs async =>
      _sharedPreferences ?? await SharedPreferences.getInstance();

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
      'displayName': displayName,
      'password': password,
      'role': role.name,
    });

    final user = User.fromJson(response['user'] as Map<String, dynamic>);
    final token = response['token'] as String;

    // Store authentication data
    final prefs = await _prefs;
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userIdKey, user.id);
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
    final prefs = await _prefs;
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userIdKey, user.id);
    _apiClient.token = token;

    return user;
  }

  /// Logs out the current user.
  Future<void> logout() async {
    final prefs = await _prefs;
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    _apiClient.token = null;
  }

  /// Checks if a user is logged in.
  Future<bool> isLoggedIn() async {
    final prefs = await _prefs;
    final token = prefs.getString(_tokenKey);
    return token != null;
  }

  /// Gets the stored authentication token.
  Future<String?> getToken() async {
    final prefs = await _prefs;
    return prefs.getString(_tokenKey);
  }

  /// Gets the current user ID.
  Future<String?> getCurrentUserId() async {
    final prefs = await _prefs;
    return prefs.getString(_userIdKey);
  }

  /// Initializes the API client with stored token.
  Future<void> initialize() async {
    final token = await getToken();
    if (token != null) {
      _apiClient.token = token;
    }
  }
}
