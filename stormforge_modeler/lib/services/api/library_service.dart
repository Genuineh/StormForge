import 'package:stormforge_modeler/models/library_model.dart';
import 'package:stormforge_modeler/services/api/api_client.dart';

class LibraryService {
  final ApiClient _apiClient;

  LibraryService(this._apiClient);

  /// Publish a new component to the library
  Future<LibraryComponent> publishComponent({
    required String name,
    required String namespace,
    required LibraryScope scope,
    required ComponentType componentType,
    required String version,
    required String description,
    String? author,
    String? organizationId,
    List<String>? tags,
    required Map<String, dynamic> definition,
  }) async {
    final response = await _apiClient.post('/api/library/components', {
      'name': name,
      'namespace': namespace,
      'scope': scope.toJson(),
      'type': componentType.toJson(),
      'version': version,
      'description': description,
      if (author != null) 'author': author,
      if (organizationId != null) 'organizationId': organizationId,
      if (tags != null) 'tags': tags,
      'definition': definition,
    });

    return LibraryComponent.fromJson(response);
  }

  /// Get a component by ID
  Future<LibraryComponent> getComponent(String id) async {
    final response = await _apiClient.get('/api/library/components/$id');
    return LibraryComponent.fromJson(response);
  }

  /// Search components
  Future<List<LibraryComponent>> searchComponents({
    String? query,
    LibraryScope? scope,
  }) async {
    final queryParams = <String, String>{};
    if (query != null) {
      queryParams['q'] = query;
    }
    if (scope != null) {
      queryParams['scope'] = scope.toJson();
    }

    final uri = Uri.parse('/api/library/components')
        .replace(queryParameters: queryParams.isEmpty ? null : queryParams);
    
    final response = await _apiClient.get(uri.toString());
    
    if (response is List) {
      return response
          .map((json) => LibraryComponent.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    
    return [];
  }

  /// List components by scope
  Future<List<LibraryComponent>> listByScope(LibraryScope scope) async {
    return searchComponents(scope: scope);
  }

  /// Update component version
  Future<LibraryComponent> updateVersion({
    required String componentId,
    required String newVersion,
    required Map<String, dynamic> definition,
    required String changeNotes,
    required String author,
  }) async {
    final response = await _apiClient.put(
      '/api/library/components/$componentId/version',
      {
        'newVersion': newVersion,
        'definition': definition,
        'changeNotes': changeNotes,
        'author': author,
      },
    );

    return LibraryComponent.fromJson(response);
  }

  /// Delete a component
  Future<void> deleteComponent(String id) async {
    await _apiClient.delete('/api/library/components/$id');
  }

  /// Get component versions
  Future<List<ComponentVersion>> getComponentVersions(String componentId) async {
    final response =
        await _apiClient.get('/api/library/components/$componentId/versions');
    
    if (response is List) {
      return response
          .map((json) => ComponentVersion.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    
    return [];
  }

  /// Add component reference to project
  Future<ComponentReference> addReference({
    required String projectId,
    required String componentId,
    required ComponentReferenceMode mode,
  }) async {
    final response = await _apiClient.post(
      '/api/projects/$projectId/library/references',
      {
        'componentId': componentId,
        'mode': mode.toJson(),
      },
    );

    return ComponentReference.fromJson(response);
  }

  /// Remove component reference from project
  Future<void> removeReference({
    required String projectId,
    required String componentId,
  }) async {
    await _apiClient.delete(
      '/api/projects/$projectId/library/references/$componentId',
    );
  }

  /// Get project component references
  Future<List<ComponentReference>> getProjectReferences(String projectId) async {
    final response = await _apiClient.get(
      '/api/projects/$projectId/library/references',
    );
    
    if (response is List) {
      return response
          .map((json) => ComponentReference.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    
    return [];
  }

  /// Analyze impact of component changes
  Future<ImpactAnalysis> analyzeImpact(String componentId) async {
    final response = await _apiClient.get(
      '/api/library/components/$componentId/impact',
    );

    return ImpactAnalysis.fromJson(response);
  }
}
