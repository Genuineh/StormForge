import 'package:stormforge_modeler/models/read_model_model.dart';
import 'package:stormforge_modeler/services/api/api_client.dart';

class ReadModelService {
  final ApiClient _apiClient;

  ReadModelService(this._apiClient);

  /// Create a new read model
  Future<ReadModelDefinition> createReadModel({
    required String projectId,
    required String name,
    String? description,
  }) async {
    final response = await _apiClient.post('/api/read-models', {
      'projectId': projectId,
      'name': name,
      if (description != null) 'description': description,
    });

    return ReadModelDefinition.fromJson(response);
  }

  /// Get a read model by ID
  Future<ReadModelDefinition> getReadModel(String id) async {
    final response = await _apiClient.get('/api/read-models/$id');
    return ReadModelDefinition.fromJson(response);
  }

  /// List read models for a project
  Future<List<ReadModelDefinition>> listReadModelsForProject(
      String projectId) async {
    final response =
        await _apiClient.get('/api/projects/$projectId/read-models');
    
    final readModels = (response['readModels'] as List<dynamic>)
        .map((json) => ReadModelDefinition.fromJson(json as Map<String, dynamic>))
        .toList();
    return readModels;
  }

  /// Update a read model
  Future<ReadModelDefinition> updateReadModel({
    required String id,
    required String name,
    String? description,
    List<String>? updatedByEvents,
  }) async {
    final response = await _apiClient.put('/api/read-models/$id', {
      'name': name,
      if (description != null) 'description': description,
      if (updatedByEvents != null) 'updatedByEvents': updatedByEvents,
    });

    return ReadModelDefinition.fromJson(response);
  }

  /// Delete a read model
  Future<void> deleteReadModel(String id) async {
    await _apiClient.delete('/api/read-models/$id');
  }

  /// Add a data source to a read model
  Future<ReadModelDefinition> addSource({
    required String readModelId,
    required String entityId,
    required String alias,
    required JoinType joinType,
    JoinCondition? joinCondition,
  }) async {
    final response = await _apiClient.post(
      '/api/read-models/$readModelId/sources',
      {
        'entityId': entityId,
        'alias': alias,
        'joinType': joinType.toJson(),
        if (joinCondition != null) 'joinCondition': joinCondition.toJson(),
      },
    );

    return ReadModelDefinition.fromJson(response);
  }

  /// Update a data source in a read model
  Future<ReadModelDefinition> updateSource({
    required String readModelId,
    required int sourceIndex,
    required String entityId,
    required String alias,
    required JoinType joinType,
    JoinCondition? joinCondition,
  }) async {
    final response = await _apiClient.put(
      '/api/read-models/$readModelId/sources/$sourceIndex',
      {
        'entityId': entityId,
        'alias': alias,
        'joinType': joinType.toJson(),
        if (joinCondition != null) 'joinCondition': joinCondition.toJson(),
      },
    );

    return ReadModelDefinition.fromJson(response);
  }

  /// Remove a data source from a read model
  Future<ReadModelDefinition> removeSource({
    required String readModelId,
    required int sourceIndex,
  }) async {
    final response = await _apiClient
        .delete('/api/read-models/$readModelId/sources/$sourceIndex');

    return ReadModelDefinition.fromJson(response);
  }

  /// Add a field to a read model
  Future<ReadModelDefinition> addField({
    required String readModelId,
    required String name,
    required String fieldType,
    required ReadModelFieldSourceType sourceType,
    required String sourcePath,
    FieldTransform? transform,
    bool nullable = false,
    String? description,
  }) async {
    final response = await _apiClient.post(
      '/api/read-models/$readModelId/fields',
      {
        'name': name,
        'fieldType': fieldType,
        'sourceType': sourceType.toJson(),
        'sourcePath': sourcePath,
        if (transform != null) 'transform': transform.toJson(),
        'nullable': nullable,
        if (description != null) 'description': description,
      },
    );

    return ReadModelDefinition.fromJson(response);
  }

  /// Update a field in a read model
  Future<ReadModelDefinition> updateField({
    required String readModelId,
    required String fieldId,
    required String name,
    required String fieldType,
    required ReadModelFieldSourceType sourceType,
    required String sourcePath,
    FieldTransform? transform,
    bool nullable = false,
    String? description,
  }) async {
    final response = await _apiClient.put(
      '/api/read-models/$readModelId/fields/$fieldId',
      {
        'name': name,
        'fieldType': fieldType,
        'sourceType': sourceType.toJson(),
        'sourcePath': sourcePath,
        if (transform != null) 'transform': transform.toJson(),
        'nullable': nullable,
        if (description != null) 'description': description,
      },
    );

    return ReadModelDefinition.fromJson(response);
  }

  /// Remove a field from a read model
  Future<ReadModelDefinition> removeField({
    required String readModelId,
    required String fieldId,
  }) async {
    final response = await _apiClient
        .delete('/api/read-models/$readModelId/fields/$fieldId');

    return ReadModelDefinition.fromJson(response);
  }
}
