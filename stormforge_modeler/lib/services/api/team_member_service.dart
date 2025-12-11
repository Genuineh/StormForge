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
    return TeamMember.fromJson(response as Map<String, dynamic>);
  }

  /// Lists team members for a project.
  Future<List<TeamMember>> listTeamMembers(String projectId) async {
    final response =
        await _apiClient.get('/api/projects/$projectId/members');
    
    List<dynamic> membersList;
    if (response is List<dynamic>) {
      membersList = response;
    } else if (response is Map<String, dynamic> && response.containsKey('members')) {
      membersList = response['members'] as List<dynamic>;
    } else {
      throw Exception('Unexpected response format for team members list');
    }
    
    final members = membersList
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
    return TeamMember.fromJson(response as Map<String, dynamic>);
  }

  /// Removes a team member from a project.
  Future<void> removeTeamMember({
    required String projectId,
    required String userId,
  }) async {
    await _apiClient.delete('/api/projects/$projectId/members/$userId');
  }
}
