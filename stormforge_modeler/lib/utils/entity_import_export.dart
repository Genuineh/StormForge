import 'dart:convert';
import 'package:stormforge_modeler/models/entity_model.dart';

/// Utilities for importing and exporting entities.
class EntityImportExport {
  /// Exports entities to JSON string.
  static String exportEntitiesToJson(List<EntityDefinition> entities) {
    final jsonList = entities.map((e) => e.toJson()).toList();
    return const JsonEncoder.withIndent('  ').convert(jsonList);
  }

  /// Exports a single entity to JSON string.
  static String exportEntityToJson(EntityDefinition entity) {
    return const JsonEncoder.withIndent('  ').convert(entity.toJson());
  }

  /// Imports entities from JSON string.
  static List<EntityDefinition> importEntitiesFromJson(String jsonString) {
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => EntityDefinition.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw FormatException('Invalid JSON format: $e');
    }
  }

  /// Imports a single entity from JSON string.
  static EntityDefinition importEntityFromJson(String jsonString) {
    try {
      final Map<String, dynamic> json = jsonDecode(jsonString) as Map<String, dynamic>;
      return EntityDefinition.fromJson(json);
    } catch (e) {
      throw FormatException('Invalid JSON format: $e');
    }
  }

  /// Validates that the JSON string is valid for entity import.
  static bool validateJson(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is List) {
        // Validate each entity in the list
        for (var item in decoded) {
          if (item is! Map<String, dynamic>) return false;
          if (!_validateEntityJson(item)) return false;
        }
        return true;
      } else if (decoded is Map<String, dynamic>) {
        return _validateEntityJson(decoded);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static bool _validateEntityJson(Map<String, dynamic> json) {
    // Check required fields
    return json.containsKey('id') &&
        json.containsKey('projectId') &&
        json.containsKey('name') &&
        json.containsKey('entityType');
  }

  /// Creates a template entity JSON for users to fill in.
  static String createTemplate() {
    final template = {
      'id': 'auto-generated',
      'projectId': 'your-project-id',
      'name': 'EntityName',
      'description': 'Entity description',
      'entityType': 'entity',
      'properties': [
        {
          'id': 'auto-generated',
          'name': 'propertyName',
          'propertyType': 'String',
          'required': true,
          'isIdentifier': false,
          'isReadOnly': false,
          'description': 'Property description',
          'displayOrder': 0,
          'validations': [
            {
              'id': 'auto-generated',
              'validationType': 'required',
              'errorMessage': 'This field is required',
            }
          ],
        }
      ],
      'methods': [
        {
          'id': 'auto-generated',
          'name': 'methodName',
          'methodType': 'query',
          'returnType': 'void',
          'description': 'Method description',
          'parameters': [
            {
              'name': 'paramName',
              'parameterType': 'String',
              'required': true,
            }
          ],
        }
      ],
      'invariants': [
        {
          'id': 'auto-generated',
          'name': 'InvariantName',
          'expression': 'property > 0',
          'errorMessage': 'Invariant violation message',
          'enabled': true,
        }
      ],
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    return const JsonEncoder.withIndent('  ').convert(template);
  }
}
