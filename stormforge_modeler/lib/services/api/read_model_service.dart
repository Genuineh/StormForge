import 'dart:convert';
import '../models/read_model_model.dart';
import 'api_client.dart';

class ReadModelService {
  final ApiClient _apiClient;

  ReadModelService(this._apiClient);

  /// Create a new read model
  Future<ReadModelDefinition> createReadModel({
    required String projectId,
    required String name,
    String? description,
  }) async {
    final response = await _apiClient.post(
      '/api/read-models',
      body: {
        'projectId': projectId,
        'name': name,
        if (description != null) 'description': description,
      },
    );

    if (response.statusCode == 201) {
      return ReadModelDefinition.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create read model: ${response.body}');
    }
  }

  /// Get a read model by ID
  Future<ReadModelDefinition> getReadModel(String id) async {
    final response = await _apiClient.get('/api/read-models/$id');

    if (response.statusCode == 200) {
      return ReadModelDefinition.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get read model: ${response.body}');
    }
  }

  /// List read models for a project
  Future<List<ReadModelDefinition>> listReadModelsForProject(
      String projectId) async {
    final response =
        await _apiClient.get('/api/projects/$projectId/read-models');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((json) => ReadModelDefinition.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to list read models: ${response.body}');
    }
  }

  /// Update a read model
  Future<ReadModelDefinition> updateReadModel({
    required String id,
    required String name,
    String? description,
    List<String>? updatedByEvents,
  }) async {
    final response = await _apiClient.put(
      '/api/read-models/$id',
      body: {
        'name': name,
        if (description != null) 'description': description,
        if (updatedByEvents != null) 'updatedByEvents': updatedByEvents,
      },
    );

    if (response.statusCode == 200) {
      return ReadModelDefinition.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update read model: ${response.body}');
    }
  }

  /// Delete a read model
  Future<void> deleteReadModel(String id) async {
    final response = await _apiClient.delete('/api/read-models/$id');

    if (response.statusCode != 204) {
      throw Exception('Failed to delete read model: ${response.body}');
    }
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
      body: {
        'entityId': entityId,
        'alias': alias,
        'joinType': joinType.toJson(),
        if (joinCondition != null) 'joinCondition': joinCondition.toJson(),
      },
    );

    if (response.statusCode == 200) {
      return ReadModelDefinition.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add source: ${response.body}');
    }
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
      body: {
        'entityId': entityId,
        'alias': alias,
        'joinType': joinType.toJson(),
        if (joinCondition != null) 'joinCondition': joinCondition.toJson(),
      },
    );

    if (response.statusCode == 200) {
      return ReadModelDefinition.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update source: ${response.body}');
    }
  }

  /// Remove a data source from a read model
  Future<ReadModelDefinition> removeSource({
    required String readModelId,
    required int sourceIndex,
  }) async {
    final response = await _apiClient
        .delete('/api/read-models/$readModelId/sources/$sourceIndex');

    if (response.statusCode == 200) {
      return ReadModelDefinition.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to remove source: ${response.body}');
    }
  }

  /// Add a field to a read model
  Future<ReadModelDefinition> addField({
    required String readModelId,
    required String name,
    required String fieldType,
    required FieldSourceType sourceType,
    required String sourcePath,
    FieldTransform? transform,
    bool nullable = false,
    String? description,
  }) async {
    final response = await _apiClient.post(
      '/api/read-models/$readModelId/fields',
      body: {
        'name': name,
        'fieldType': fieldType,
        'sourceType': sourceType.toJson(),
        'sourcePath': sourcePath,
        if (transform != null) 'transform': transform.toJson(),
        'nullable': nullable,
        if (description != null) 'description': description,
      },
    );

    if (response.statusCode == 200) {
      return ReadModelDefinition.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add field: ${response.body}');
    }
  }

  /// Update a field in a read model
  Future<ReadModelDefinition> updateField({
    required String readModelId,
    required String fieldId,
    required String name,
    required String fieldType,
    required FieldSourceType sourceType,
    required String sourcePath,
    FieldTransform? transform,
    bool nullable = false,
    String? description,
  }) async {
    final response = await _apiClient.put(
      '/api/read-models/$readModelId/fields/$fieldId',
      body: {
        'name': name,
        'fieldType': fieldType,
        'sourceType': sourceType.toJson(),
        'sourcePath': sourcePath,
        if (transform != null) 'transform': transform.toJson(),
        'nullable': nullable,
        if (description != null) 'description': description,
      },
    );

    if (response.statusCode == 200) {
      return ReadModelDefinition.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update field: ${response.body}');
    }
  }

  /// Remove a field from a read model
  Future<ReadModelDefinition> removeField({
    required String readModelId,
    required String fieldId,
  }) async {
    final response = await _apiClient
        .delete('/api/read-models/$readModelId/fields/$fieldId');

    if (response.statusCode == 200) {
      return ReadModelDefinition.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to remove field: ${response.body}');
    }
  }
}
