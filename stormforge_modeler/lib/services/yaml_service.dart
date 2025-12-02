import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaml/yaml.dart';
import 'package:stormforge_modeler/models/models.dart';

/// Provider for the YAML service.
final yamlServiceProvider = Provider<YamlService>((ref) => YamlService());

/// Service for exporting and importing canvas models to/from YAML.
class YamlService {
  /// Exports a canvas model to YAML IR format.
  String exportToYaml(CanvasModel model) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('# StormForge IR v1.0');
    buffer.writeln('# Auto-generated from StormForge Modeler');
    buffer.writeln();
    buffer.writeln('version: "1.0"');
    buffer.writeln();

    // Bounded context (default)
    buffer.writeln('bounded_context:');
    buffer.writeln('  name: "GeneratedContext"');
    buffer.writeln('  namespace: "com.example.generated"');
    buffer.writeln('  description: "Auto-generated bounded context"');
    buffer.writeln();

    // Aggregates
    final aggregates = model.elements
        .where((e) => e.type == ElementType.aggregate)
        .toList();
    if (aggregates.isNotEmpty) {
      buffer.writeln('aggregates:');
      for (final aggregate in aggregates) {
        buffer.writeln('  ${_sanitizeName(aggregate.label)}:');
        buffer.writeln('    name: "${aggregate.label}"');
        buffer.writeln(
          '    description: "${_escapeString(aggregate.description)}"',
        );
        buffer.writeln('    root_entity:');
        buffer.writeln('      name: "${aggregate.label}"');
        buffer.writeln('      properties:');
        buffer.writeln('        - name: "id"');
        buffer.writeln('          type: "${aggregate.label}Id"');
        buffer.writeln('          identifier: true');
        buffer.writeln();
      }
    }

    // Domain Events
    final events = model.elements
        .where((e) => e.type == ElementType.domainEvent)
        .toList();
    if (events.isNotEmpty) {
      buffer.writeln('events:');
      for (final event in events) {
        buffer.writeln('  ${_sanitizeName(event.label)}:');
        buffer.writeln('    name: "${event.label}"');
        buffer.writeln(
          '    description: "${_escapeString(event.description)}"',
        );
        buffer.writeln('    payload: []');
        buffer.writeln();
      }
    }

    // Commands
    final commands = model.elements
        .where((e) => e.type == ElementType.command)
        .toList();
    if (commands.isNotEmpty) {
      buffer.writeln('commands:');
      for (final command in commands) {
        buffer.writeln('  ${_sanitizeName(command.label)}:');
        buffer.writeln('    name: "${command.label}"');
        buffer.writeln(
          '    description: "${_escapeString(command.description)}"',
        );
        buffer.writeln('    payload: []');
        buffer.writeln();
      }
    }

    // Policies
    final policies = model.elements
        .where((e) => e.type == ElementType.policy)
        .toList();
    if (policies.isNotEmpty) {
      buffer.writeln('# Policies');
      for (final policy in policies) {
        buffer.writeln('# - ${policy.label}: ${policy.description}');
      }
      buffer.writeln();
    }

    // Read Models
    final readModels = model.elements
        .where((e) => e.type == ElementType.readModel)
        .toList();
    if (readModels.isNotEmpty) {
      buffer.writeln('queries:');
      for (final readModel in readModels) {
        buffer.writeln('  Get${_sanitizeName(readModel.label)}:');
        buffer.writeln('    name: "Get${readModel.label}"');
        buffer.writeln(
          '    description: "${_escapeString(readModel.description)}"',
        );
        buffer.writeln('    parameters: []');
        buffer.writeln('    returns:');
        buffer.writeln('      type: "${readModel.label}"');
        buffer.writeln('      nullable: true');
        buffer.writeln();
      }
    }

    // External Systems
    final externalSystems = model.elements
        .where((e) => e.type == ElementType.externalSystem)
        .toList();
    if (externalSystems.isNotEmpty) {
      buffer.writeln('# External Systems');
      for (final system in externalSystems) {
        buffer.writeln('# - ${system.label}: ${system.description}');
      }
      buffer.writeln();
    }

    // UI Elements
    final uiElements = model.elements
        .where((e) => e.type == ElementType.ui)
        .toList();
    if (uiElements.isNotEmpty) {
      buffer.writeln('# UI Elements');
      for (final ui in uiElements) {
        buffer.writeln('# - ${ui.label}: ${ui.description}');
      }
      buffer.writeln();
    }

    // Connections
    if (model.connections.isNotEmpty) {
      buffer.writeln('# Connections/Flows');
      for (final connection in model.connections) {
        final source = model.getElementById(connection.sourceId);
        final target = model.getElementById(connection.targetId);
        if (source != null && target != null) {
          buffer.writeln('# - ${source.label} -> ${target.label}');
        }
      }
    }

    return buffer.toString();
  }

  /// Imports a canvas model from YAML IR format.
  CanvasModel importFromYaml(String yamlContent) {
    final doc = loadYaml(yamlContent);
    if (doc is! YamlMap) {
      throw FormatException('Invalid YAML format');
    }

    final elements = <CanvasElement>[];
    var yOffset = 50.0;

    // Import aggregates
    if (doc['aggregates'] is YamlMap) {
      final aggregates = doc['aggregates'] as YamlMap;
      var xOffset = 300.0;
      for (final entry in aggregates.entries) {
        final aggregateData = entry.value as YamlMap;
        elements.add(
          StickyNoteElement.create(
            type: ElementType.aggregate,
            position: Offset(xOffset, yOffset),
            label: aggregateData['name']?.toString() ?? entry.key.toString(),
          ).copyWith(
            description: aggregateData['description']?.toString() ?? '',
          ),
        );
        xOffset += 170;
      }
      yOffset += 120;
    }

    // Import events
    if (doc['events'] is YamlMap) {
      final events = doc['events'] as YamlMap;
      var xOffset = 50.0;
      for (final entry in events.entries) {
        final eventData = entry.value as YamlMap;
        elements.add(
          StickyNoteElement.create(
            type: ElementType.domainEvent,
            position: Offset(xOffset, yOffset),
            label: eventData['name']?.toString() ?? entry.key.toString(),
          ).copyWith(description: eventData['description']?.toString() ?? ''),
        );
        xOffset += 170;
      }
      yOffset += 120;
    }

    // Import commands
    if (doc['commands'] is YamlMap) {
      final commands = doc['commands'] as YamlMap;
      var xOffset = 50.0;
      for (final entry in commands.entries) {
        final commandData = entry.value as YamlMap;
        elements.add(
          StickyNoteElement.create(
            type: ElementType.command,
            position: Offset(xOffset, yOffset),
            label: commandData['name']?.toString() ?? entry.key.toString(),
          ).copyWith(description: commandData['description']?.toString() ?? ''),
        );
        xOffset += 170;
      }
      yOffset += 120;
    }

    // Import queries as read models
    if (doc['queries'] is YamlMap) {
      final queries = doc['queries'] as YamlMap;
      var xOffset = 50.0;
      for (final entry in queries.entries) {
        final queryData = entry.value as YamlMap;
        elements.add(
          StickyNoteElement.create(
            type: ElementType.readModel,
            position: Offset(xOffset, yOffset),
            label: queryData['name']?.toString() ?? entry.key.toString(),
          ).copyWith(description: queryData['description']?.toString() ?? ''),
        );
        xOffset += 170;
      }
    }

    return CanvasModel(elements: elements);
  }

  /// Sanitizes a name for use as a YAML key.
  String _sanitizeName(String name) {
    return name
        .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')
        .replaceFirstMapped(RegExp(r'^.'), (m) => m.group(0)!.toUpperCase());
  }

  /// Escapes special characters in a string for YAML.
  String _escapeString(String value) {
    return value
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t');
  }
}
