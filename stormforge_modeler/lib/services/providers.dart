import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stormforge_modeler/models/user_model.dart';
import 'package:stormforge_modeler/services/api/api_client.dart';
import 'package:stormforge_modeler/services/api/auth_service.dart';
import 'package:stormforge_modeler/services/api/command_service.dart';
import 'package:stormforge_modeler/services/api/entity_service.dart';
import 'package:stormforge_modeler/services/api/library_service.dart';
import 'package:stormforge_modeler/services/api/project_service.dart';
import 'package:stormforge_modeler/services/api/read_model_service.dart';
import 'package:stormforge_modeler/services/api/team_member_service.dart';
import 'package:stormforge_modeler/services/api/user_service.dart';

/// Provider for the API client.
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

/// Provider for the auth service.
final authServiceProvider = Provider<AuthService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthService(apiClient: apiClient);
});

/// Provider for the user service.
final userServiceProvider = Provider<UserService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return UserService(apiClient: apiClient);
});

/// Provider for the project service.
final projectServiceProvider = Provider<ProjectService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProjectService(apiClient: apiClient);
});

/// Provider for the team member service.
final teamMemberServiceProvider = Provider<TeamMemberService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TeamMemberService(apiClient: apiClient);
});

/// Provider for the entity service.
final entityServiceProvider = Provider<EntityService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return EntityService(apiClient: apiClient);
});

/// Provider for the read model service.
final readModelServiceProvider = Provider<ReadModelService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ReadModelService(apiClient);
});

/// Provider for the command service.
final commandServiceProvider = Provider<CommandService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CommandService(apiClient);
});

/// Provider for the library service.
final libraryServiceProvider = Provider<LibraryService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return LibraryService(apiClient);
});

/// State notifier for authentication state.
class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  AuthNotifier(this._authService) : super(const AsyncValue.loading()) {
    _initialize();
  }

  final AuthService _authService;

  Future<void> _initialize() async {
    state = const AsyncValue.loading();
    try {
      await _authService.initialize();
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        // TODO: Fetch current user data
        state = const AsyncValue.data(null);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Logs in a user.
  Future<void> login(String usernameOrEmail, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.login(
        usernameOrEmail: usernameOrEmail,
        password: password,
      );
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Registers a new user.
  Future<void> register({
    required String username,
    required String email,
    required String displayName,
    required String password,
    UserRole role = UserRole.developer,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.register(
        username: username,
        email: email,
        displayName: displayName,
        password: password,
        role: role,
      );
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Logs out the current user.
  Future<void> logout() async {
    await _authService.logout();
    state = const AsyncValue.data(null);
  }
}

/// Provider for authentication state.
final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>(
  (ref) {
    final authService = ref.watch(authServiceProvider);
    return AuthNotifier(authService);
  },
);

/// Provider to check if user is authenticated.
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.valueOrNull != null;
});
