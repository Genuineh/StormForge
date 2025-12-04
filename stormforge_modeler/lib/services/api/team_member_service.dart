import 'package:stormforge_modeler/models/team_member_model.dart';
import 'package:stormforge_modeler/services/api/api_client.dart';

/// Service for team member management operations.
class TeamMemberService {
  /// Creates a team member service.
  TeamMemberService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  /// Adds a team member to a project.
  Future<TeamMember> addTeamMember({
    required String projectId,
    required String userId,
    TeamRole role = TeamRole.editor,
  }) async {
    final response = await _apiClient.post(
      '/api/projects/$projectId/members',
      {
        'user_id': userId,
        'role': role.name,
      },
    );
    return TeamMember.fromJson(response);
  }

  /// Lists team members for a project.
  Future<List<TeamMember>> listTeamMembers(String projectId) async {
    final response =
        await _apiClient.get('/api/projects/$projectId/members');
    final members = (response['members'] as List<dynamic>)
        .map((m) => TeamMember.fromJson(m as Map<String, dynamic>))
        .toList();
    return members;
  }

  /// Updates a team member's role.
  Future<TeamMember> updateTeamMember({
    required String projectId,
    required String userId,
    required TeamRole role,
  }) async {
    final response = await _apiClient.put(
      '/api/projects/$projectId/members/$userId',
      {'role': role.name},
    );
    return TeamMember.fromJson(response);
  }

  /// Removes a team member from a project.
  Future<void> removeTeamMember({
    required String projectId,
    required String userId,
  }) async {
    await _apiClient.delete('/api/projects/$projectId/members/$userId');
  }
}
