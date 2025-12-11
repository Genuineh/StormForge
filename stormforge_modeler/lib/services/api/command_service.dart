import 'package:stormforge_modeler/models/command_model.dart';
import 'package:stormforge_modeler/services/api/api_client.dart';

class CommandService {
  final ApiClient _apiClient;

  CommandService(this._apiClient);

  /// Create a new command
  Future<CommandDefinition> createCommand({
    required String projectId,
    required String name,
    String? description,
    String? aggregateId,
  }) async {
    final response = await _apiClient.post('/api/commands', {
      'projectId': projectId,
      'name': name,
      if (description != null) 'description': description,
      if (aggregateId != null) 'aggregateId': aggregateId,
    });

    return CommandDefinition.fromJson(response as Map<String, dynamic>);
  }

  /// Get a command by ID
  Future<CommandDefinition> getCommand(String id) async {
    final response = await _apiClient.get('/api/commands/$id');
    return CommandDefinition.fromJson(response as Map<String, dynamic>);
  }

  /// List commands for a project
  Future<List<CommandDefinition>> listCommandsForProject(
      String projectId) async {
    final response =
        await _apiClient.get('/api/projects/$projectId/commands');
    
    List<dynamic> commandsList;
    if (response is List<dynamic>) {
      commandsList = response;
    } else if (response is Map<String, dynamic> && response.containsKey('commands')) {
      commandsList = response['commands'] as List<dynamic>;
    } else {
      throw Exception('Unexpected response format for commands list');
    }
    
    final commands = commandsList
        .map((json) => CommandDefinition.fromJson(json as Map<String, dynamic>))
        .toList();
    return commands;
  }

  /// Update a command
  Future<CommandDefinition> updateCommand({
    required String id,
    required String name,
    String? description,
    String? aggregateId,
    List<String>? producedEvents,
  }) async {
    final response = await _apiClient.put('/api/commands/$id', {
      'name': name,
      if (description != null) 'description': description,
      if (aggregateId != null) 'aggregateId': aggregateId,
      if (producedEvents != null) 'producedEvents': producedEvents,
    });

    return CommandDefinition.fromJson(response as Map<String, dynamic>);
  }

  /// Delete a command
  Future<void> deleteCommand(String id) async {
    await _apiClient.delete('/api/commands/$id');
  }

  /// Add a field to command payload
  Future<CommandDefinition> addField({
    required String commandId,
    required String name,
    required String fieldType,
    required bool required,
    required FieldSource source,
    dynamic defaultValue,
    String? description,
  }) async {
    final response = await _apiClient.post(
      '/api/commands/$commandId/fields',
      {
        'name': name,
        'fieldType': fieldType,
        'required': required,
        'source': source.toJson(),
        if (defaultValue != null) 'defaultValue': defaultValue,
        if (description != null) 'description': description,
      },
    );

    return CommandDefinition.fromJson(response as Map<String, dynamic>);
  }

  /// Update a field in command payload
  Future<CommandDefinition> updateField({
    required String commandId,
    required String fieldId,
    required String name,
    required String fieldType,
    required bool required,
    required FieldSource source,
    dynamic defaultValue,
    String? description,
  }) async {
    final response = await _apiClient.put(
      '/api/commands/$commandId/fields/$fieldId',
      {
        'name': name,
        'fieldType': fieldType,
        'required': required,
        'source': source.toJson(),
        if (defaultValue != null) 'defaultValue': defaultValue,
        if (description != null) 'description': description,
      },
    );

    return CommandDefinition.fromJson(response as Map<String, dynamic>);
  }

  /// Remove a field from command payload
  Future<CommandDefinition> removeField({
    required String commandId,
    required String fieldId,
  }) async {
    final response = await _apiClient.delete(
      '/api/commands/$commandId/fields/$fieldId',
    );

    return CommandDefinition.fromJson(response as Map<String, dynamic>);
  }

  /// Add a validation rule to command
  Future<CommandDefinition> addValidation({
    required String commandId,
    required String fieldName,
    required ValidationOperator operator,
    required dynamic value,
    required String errorMessage,
  }) async {
    final response = await _apiClient.post(
      '/api/commands/$commandId/validations',
      {
        'fieldName': fieldName,
        'operator': operator.toJson(),
        'value': value,
        'errorMessage': errorMessage,
      },
    );

    return CommandDefinition.fromJson(response as Map<String, dynamic>);
  }

  /// Remove a validation rule from command
  Future<CommandDefinition> removeValidation({
    required String commandId,
    required int validationIndex,
  }) async {
    final response = await _apiClient.delete(
      '/api/commands/$commandId/validations/$validationIndex',
    );

    return CommandDefinition.fromJson(response as Map<String, dynamic>);
  }

  /// Add a precondition to command
  Future<CommandDefinition> addPrecondition({
    required String commandId,
    required String description,
    required String expression,
    required PreconditionOperator operator,
    required String errorMessage,
  }) async {
    final response = await _apiClient.post(
      '/api/commands/$commandId/preconditions',
      {
        'description': description,
        'expression': expression,
        'operator': operator.toJson(),
        'errorMessage': errorMessage,
      },
    );

    return CommandDefinition.fromJson(response as Map<String, dynamic>);
  }

  /// Remove a precondition from command
  Future<CommandDefinition> removePrecondition({
    required String commandId,
    required int preconditionIndex,
  }) async {
    final response = await _apiClient.delete(
      '/api/commands/$commandId/preconditions/$preconditionIndex',
    );

    return CommandDefinition.fromJson(response as Map<String, dynamic>);
  }
}
