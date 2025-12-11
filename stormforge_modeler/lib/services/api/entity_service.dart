import 'package:stormforge_modeler/models/entity_model.dart';
import 'package:stormforge_modeler/services/api/api_client.dart';

/// Service for entity management operations.
class EntityService {
  /// Creates an entity service.
  EntityService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  /// Creates a new entity.
  Future<EntityDefinition> createEntity({
    required String projectId,
    required String name,
    EntityType entityType = EntityType.entity,
    String? description,
    String? aggregateId,
  }) async {
    final response = await _apiClient.post('/api/entities', {
      'projectId': projectId,
      'name': name,
      'entityType': entityType.toJson(),
      if (description != null) 'description': description,
      if (aggregateId != null) 'aggregateId': aggregateId,
    });
    return EntityDefinition.fromJson(response as Map<String, dynamic>);
  }

  /// Gets an entity by ID.
  Future<EntityDefinition> getEntity(String entityId) async {
    final response = await _apiClient.get('/api/entities/$entityId');
    return EntityDefinition.fromJson(response as Map<String, dynamic>);
  }

  /// Lists entities for a project.
  Future<List<EntityDefinition>> listEntitiesForProject(
      String projectId) async {
    final response =
        await _apiClient.get('/api/projects/$projectId/entities');
    
    List<dynamic> entitiesList;
    if (response is List<dynamic>) {
      entitiesList = response;
    } else if (response is Map<String, dynamic> && response.containsKey('entities')) {
      entitiesList = response['entities'] as List<dynamic>;
    } else {
      throw Exception('Unexpected response format for entities list');
    }
    
    final entities = entitiesList
        .map((e) => EntityDefinition.fromJson(e as Map<String, dynamic>))
        .toList();
    return entities;
  }

  /// Lists entities for an aggregate.
  Future<List<EntityDefinition>> listEntitiesForAggregate(
      String aggregateId) async {
    final response =
        await _apiClient.get('/api/aggregates/$aggregateId/entities');
    
    List<dynamic> entitiesList;
    if (response is List<dynamic>) {
      entitiesList = response;
    } else if (response is Map<String, dynamic> && response.containsKey('entities')) {
      entitiesList = response['entities'] as List<dynamic>;
    } else {
      throw Exception('Unexpected response format for entities list');
    }
    
    final entities = entitiesList
        .map((e) => EntityDefinition.fromJson(e as Map<String, dynamic>))
        .toList();
    return entities;
  }

  /// Updates an entity.
  Future<EntityDefinition> updateEntity({
    required String entityId,
    String? name,
    String? description,
    EntityType? entityType,
    String? aggregateId,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (description != null) body['description'] = description;
    if (entityType != null) body['entityType'] = entityType.toJson();
    if (aggregateId != null) body['aggregateId'] = aggregateId;

    final response = await _apiClient.put('/api/entities/$entityId', body);
    return EntityDefinition.fromJson(response as Map<String, dynamic>);
  }

  /// Deletes an entity.
  Future<void> deleteEntity(String entityId) async {
    await _apiClient.delete('/api/entities/$entityId');
  }

  /// Adds a property to an entity.
  Future<EntityDefinition> addProperty({
    required String entityId,
    required String name,
    required String propertyType,
    bool required = false,
    bool isIdentifier = false,
    bool isReadOnly = false,
    dynamic defaultValue,
    String? description,
    List<ValidationRule>? validations,
  }) async {
    final response =
        await _apiClient.post('/api/entities/$entityId/properties', {
      'name': name,
      'propertyType': propertyType,
      'required': required,
      'isIdentifier': isIdentifier,
      'isReadOnly': isReadOnly,
      if (defaultValue != null) 'defaultValue': defaultValue,
      if (description != null) 'description': description,
      if (validations != null)
        'validations': validations.map((v) => v.toJson()).toList(),
    });
    return EntityDefinition.fromJson(response as Map<String, dynamic>);
  }

  /// Updates a property.
  Future<EntityDefinition> updateProperty({
    required String entityId,
    required String propertyId,
    String? name,
    String? propertyType,
    bool? required,
    bool? isIdentifier,
    bool? isReadOnly,
    dynamic defaultValue,
    String? description,
    List<ValidationRule>? validations,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (propertyType != null) body['propertyType'] = propertyType;
    if (required != null) body['required'] = required;
    if (isIdentifier != null) body['isIdentifier'] = isIdentifier;
    if (isReadOnly != null) body['isReadOnly'] = isReadOnly;
    if (defaultValue != null) body['defaultValue'] = defaultValue;
    if (description != null) body['description'] = description;
    if (validations != null) {
      body['validations'] = validations.map((v) => v.toJson()).toList();
    }

    final response = await _apiClient.put(
      '/api/entities/$entityId/properties/$propertyId',
      body,
    );
    return EntityDefinition.fromJson(response as Map<String, dynamic>);
  }

  /// Removes a property.
  Future<EntityDefinition> removeProperty({
    required String entityId,
    required String propertyId,
  }) async {
    final response = await _apiClient.delete(
      '/api/entities/$entityId/properties/$propertyId',
    );
    return EntityDefinition.fromJson(response as Map<String, dynamic>);
  }

  /// Adds a method to an entity.
  Future<EntityDefinition> addMethod({
    required String entityId,
    required String name,
    required MethodType methodType,
    String returnType = 'void',
    String? description,
    List<MethodParameter>? parameters,
  }) async {
    final response = await _apiClient.post('/api/entities/$entityId/methods', {
      'name': name,
      'methodType': methodType.toJson(),
      'returnType': returnType,
      if (description != null) 'description': description,
      if (parameters != null)
        'parameters': parameters.map((p) => p.toJson()).toList(),
    });
    return EntityDefinition.fromJson(response as Map<String, dynamic>);
  }

  /// Updates a method.
  Future<EntityDefinition> updateMethod({
    required String entityId,
    required String methodId,
    String? name,
    MethodType? methodType,
    String? returnType,
    String? description,
    List<MethodParameter>? parameters,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (methodType != null) body['methodType'] = methodType.toJson();
    if (returnType != null) body['returnType'] = returnType;
    if (description != null) body['description'] = description;
    if (parameters != null) {
      body['parameters'] = parameters.map((p) => p.toJson()).toList();
    }

    final response = await _apiClient.put(
      '/api/entities/$entityId/methods/$methodId',
      body,
    );
    return EntityDefinition.fromJson(response as Map<String, dynamic>);
  }

  /// Removes a method.
  Future<EntityDefinition> removeMethod({
    required String entityId,
    required String methodId,
  }) async {
    final response = await _apiClient.delete(
      '/api/entities/$entityId/methods/$methodId',
    );
    return EntityDefinition.fromJson(response as Map<String, dynamic>);
  }

  /// Adds an invariant to an entity.
  Future<EntityDefinition> addInvariant({
    required String entityId,
    required String name,
    required String expression,
    String errorMessage = 'Invariant violation',
    bool enabled = true,
  }) async {
    final response =
        await _apiClient.post('/api/entities/$entityId/invariants', {
      'name': name,
      'expression': expression,
      'errorMessage': errorMessage,
      'enabled': enabled,
    });
    return EntityDefinition.fromJson(response as Map<String, dynamic>);
  }

  /// Updates an invariant.
  Future<EntityDefinition> updateInvariant({
    required String entityId,
    required String invariantId,
    String? name,
    String? expression,
    String? errorMessage,
    bool? enabled,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (expression != null) body['expression'] = expression;
    if (errorMessage != null) body['errorMessage'] = errorMessage;
    if (enabled != null) body['enabled'] = enabled;

    final response = await _apiClient.put(
      '/api/entities/$entityId/invariants/$invariantId',
      body,
    );
    return EntityDefinition.fromJson(response as Map<String, dynamic>);
  }

  /// Removes an invariant.
  Future<EntityDefinition> removeInvariant({
    required String entityId,
    required String invariantId,
  }) async {
    final response = await _apiClient.delete(
      '/api/entities/$entityId/invariants/$invariantId',
    );
    return EntityDefinition.fromJson(response as Map<String, dynamic>);
  }

  /// Finds references to an entity.
  Future<Map<String, dynamic>> findReferences(String entityId) async {
    final response =
        await _apiClient.get('/api/entities/$entityId/references');
    return response;
  }
}
