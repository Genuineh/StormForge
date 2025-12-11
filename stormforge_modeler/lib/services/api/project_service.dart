import 'package:stormforge_modeler/models/project_model.dart';
import 'package:stormforge_modeler/services/api/api_client.dart';

/// Service for project management operations.
class ProjectService {
  /// Creates a project service.
  ProjectService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  /// Creates a new project.
  Future<Project> createProject({
    required String name,
    required String namespace,
    required String ownerId,
    String? description,
    ProjectVisibility visibility = ProjectVisibility.private,
  }) async {
    final response = await _apiClient.post('/api/projects', {
      'name': name,
      'namespace': namespace,
      'ownerId': ownerId,
      if (description != null) 'description': description,
      'visibility': visibility.name,
    });
    return Project.fromJson(response as Map<String, dynamic>);
  }

  /// Gets a project by ID.
  Future<Project> getProject(String projectId) async {
    final response = await _apiClient.get('/api/projects/$projectId');
    return Project.fromJson(response as Map<String, dynamic>);
  }

  /// Lists projects for an owner.
  Future<List<Project>> listProjects(String ownerId) async {
    final response = await _apiClient.get('/api/projects/owner/$ownerId');
    
    List<dynamic> projectsList;
    if (response is List<dynamic>) {
      projectsList = response;
    } else if (response is Map<String, dynamic> && response.containsKey('projects')) {
      projectsList = response['projects'] as List<dynamic>;
    } else {
      throw Exception('Unexpected response format for projects list');
    }
    
    final projects = projectsList
        .map((p) => Project.fromJson(p as Map<String, dynamic>))
        .toList();
    return projects;
  }

  /// Updates a project.
  Future<Project> updateProject({
    required String projectId,
    String? name,
    String? namespace,
    String? description,
    ProjectVisibility? visibility,
    ProjectSettings? settings,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (namespace != null) body['namespace'] = namespace;
    if (description != null) body['description'] = description;
    if (visibility != null) body['visibility'] = visibility.name;
    if (settings != null) body['settings'] = settings.toJson();

    final response = await _apiClient.put('/api/projects/$projectId', body);
    return Project.fromJson(response as Map<String, dynamic>);
  }

  /// Deletes a project.
  Future<void> deleteProject(String projectId) async {
    await _apiClient.delete('/api/projects/$projectId');
  }
}
