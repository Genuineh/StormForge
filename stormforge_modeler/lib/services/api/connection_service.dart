import 'package:stormforge_modeler/models/connection_model.dart';
import 'package:stormforge_modeler/services/api/api_client.dart';

/// Service for connection management operations.
class ConnectionService {
  /// Creates a connection service.
  ConnectionService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  /// Creates a new connection.
  Future<ConnectionDefinition> createConnection({
    required String projectId,
    required String sourceId,
    required String targetId,
    required ConnectionType connectionType,
    String label = '',
    ConnectionStyle? style,
    Map<String, dynamic> metadata = const {},
  }) async {
    final response = await _apiClient.post(
      '/api/projects/$projectId/connections',
      {
        'sourceId': sourceId,
        'targetId': targetId,
        'type': _connectionTypeToString(connectionType),
        'label': label,
        if (style != null)
          'style': {
            'color': style.colorToHex(),
            'strokeWidth': style.strokeWidth,
            'lineStyle': _lineStyleToString(style.lineStyle),
            'arrowStyle': _arrowStyleToString(style.arrowStyle),
          },
        'metadata': metadata,
      },
    );
    return ConnectionDefinition.fromJson(response as Map<String, dynamic>);
  }

  /// Gets a connection by ID.
  Future<ConnectionDefinition> getConnection({
    required String projectId,
    required String connectionId,
  }) async {
    final response = await _apiClient
        .get('/api/projects/$projectId/connections/$connectionId');
    return ConnectionDefinition.fromJson(response as Map<String, dynamic>);
  }

  /// Lists connections for a project.
  Future<List<ConnectionDefinition>> listConnectionsForProject(
    String projectId,
  ) async {
    final response =
        await _apiClient.get('/api/projects/$projectId/connections');

    List<dynamic> connectionsList;
    if (response is List<dynamic>) {
      connectionsList = response;
    } else if (response is Map<String, dynamic> &&
        response.containsKey('connections')) {
      connectionsList = response['connections'] as List<dynamic>;
    } else {
      throw Exception('Unexpected response format for connections list');
    }

    final connections = connectionsList
        .map((c) => ConnectionDefinition.fromJson(c as Map<String, dynamic>))
        .toList();
    return connections;
  }

  /// Lists connections for a specific element.
  Future<List<ConnectionDefinition>> listConnectionsForElement({
    required String projectId,
    required String elementId,
  }) async {
    final response = await _apiClient
        .get('/api/projects/$projectId/connections/element/$elementId');

    List<dynamic> connectionsList;
    if (response is List<dynamic>) {
      connectionsList = response;
    } else if (response is Map<String, dynamic> &&
        response.containsKey('connections')) {
      connectionsList = response['connections'] as List<dynamic>;
    } else {
      throw Exception('Unexpected response format for connections list');
    }

    final connections = connectionsList
        .map((c) => ConnectionDefinition.fromJson(c as Map<String, dynamic>))
        .toList();
    return connections;
  }

  /// Updates a connection.
  Future<ConnectionDefinition> updateConnection({
    required String projectId,
    required String connectionId,
    String? label,
    ConnectionStyle? style,
    Map<String, dynamic>? metadata,
  }) async {
    final body = <String, dynamic>{};
    if (label != null) body['label'] = label;
    if (style != null) {
      body['style'] = {
        'color': style.colorToHex(),
        'strokeWidth': style.strokeWidth,
        'lineStyle': _lineStyleToString(style.lineStyle),
        'arrowStyle': _arrowStyleToString(style.arrowStyle),
      };
    }
    if (metadata != null) body['metadata'] = metadata;

    final response = await _apiClient.put(
      '/api/projects/$projectId/connections/$connectionId',
      body,
    );
    return ConnectionDefinition.fromJson(response as Map<String, dynamic>);
  }

  /// Deletes a connection.
  Future<void> deleteConnection({
    required String projectId,
    required String connectionId,
  }) async {
    await _apiClient
        .delete('/api/projects/$projectId/connections/$connectionId');
  }

  /// Converts ConnectionType to backend string format.
  String _connectionTypeToString(ConnectionType type) {
    switch (type) {
      case ConnectionType.commandToAggregate:
        return 'CommandToAggregate';
      case ConnectionType.aggregateToEvent:
        return 'AggregateToEvent';
      case ConnectionType.eventToPolicy:
        return 'EventToPolicy';
      case ConnectionType.policyToCommand:
        return 'PolicyToCommand';
      case ConnectionType.eventToReadModel:
        return 'EventToReadModel';
      case ConnectionType.externalToCommand:
        return 'ExternalToCommand';
      case ConnectionType.uiToCommand:
        return 'UIToCommand';
      case ConnectionType.readModelToUI:
        return 'ReadModelToUI';
      case ConnectionType.custom:
        return 'Custom';
    }
  }

  /// Converts LineStyle to backend string format.
  String _lineStyleToString(LineStyle style) {
    switch (style) {
      case LineStyle.solid:
        return 'Solid';
      case LineStyle.dashed:
        return 'Dashed';
      case LineStyle.dotted:
        return 'Dotted';
    }
  }

  /// Converts ArrowStyle to backend string format.
  String _arrowStyleToString(ArrowStyle style) {
    switch (style) {
      case ArrowStyle.filled:
        return 'Filled';
      case ArrowStyle.open:
        return 'Open';
      case ArrowStyle.none:
        return 'None';
    }
  }
}

/// Backend connection model definition.
class ConnectionDefinition {
  /// Creates a connection definition.
  const ConnectionDefinition({
    required this.id,
    required this.projectId,
    required this.sourceId,
    required this.targetId,
    required this.connectionType,
    this.label = '',
    required this.style,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  /// Unique identifier for this connection.
  final String id;

  /// The ID of the project this connection belongs to.
  final String projectId;

  /// The ID of the source element.
  final String sourceId;

  /// The ID of the target element.
  final String targetId;

  /// The type of this connection.
  final ConnectionType connectionType;

  /// Optional label for the connection.
  final String label;

  /// The visual style of the connection.
  final ConnectionStyle style;

  /// Additional metadata for the connection.
  final Map<String, dynamic> metadata;

  /// Timestamp when the connection was created.
  final DateTime createdAt;

  /// Timestamp when the connection was last updated.
  final DateTime updatedAt;

  /// Creates a connection definition from JSON.
  factory ConnectionDefinition.fromJson(Map<String, dynamic> json) {
    return ConnectionDefinition(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      sourceId: json['sourceId'] as String,
      targetId: json['targetId'] as String,
      connectionType: _parseConnectionType(json['type'] as String),
      label: json['label'] as String? ?? '',
      style: _parseConnectionStyle(json['style'] as Map<String, dynamic>),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Converts this connection definition to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'sourceId': sourceId,
      'targetId': targetId,
      'type': _connectionTypeToString(connectionType),
      'label': label,
      'style': {
        'color': style.colorToHex(),
        'strokeWidth': style.strokeWidth,
        'lineStyle': _lineStyleToString(style.lineStyle),
        'arrowStyle': _arrowStyleToString(style.arrowStyle),
      },
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Converts this connection definition to a TypedConnectionElement.
  TypedConnectionElement toCanvasElement() {
    return TypedConnectionElement(
      id: id,
      sourceId: sourceId,
      targetId: targetId,
      type: connectionType,
      label: label,
      style: style,
      metadata: metadata,
    );
  }

  /// Parses ConnectionType from backend string format.
  static ConnectionType _parseConnectionType(String type) {
    switch (type) {
      case 'CommandToAggregate':
        return ConnectionType.commandToAggregate;
      case 'AggregateToEvent':
        return ConnectionType.aggregateToEvent;
      case 'EventToPolicy':
        return ConnectionType.eventToPolicy;
      case 'PolicyToCommand':
        return ConnectionType.policyToCommand;
      case 'EventToReadModel':
        return ConnectionType.eventToReadModel;
      case 'ExternalToCommand':
        return ConnectionType.externalToCommand;
      case 'UIToCommand':
        return ConnectionType.uiToCommand;
      case 'ReadModelToUI':
        return ConnectionType.readModelToUI;
      case 'Custom':
      default:
        return ConnectionType.custom;
    }
  }

  /// Parses ConnectionStyle from JSON.
  static ConnectionStyle _parseConnectionStyle(Map<String, dynamic> json) {
    return ConnectionStyle.fromHex(
      hexColor: json['color'] as String,
      strokeWidth: (json['strokeWidth'] as num).toDouble(),
      lineStyle: _parseLineStyle(json['lineStyle'] as String),
      arrowStyle: _parseArrowStyle(json['arrowStyle'] as String),
    );
  }

  /// Parses LineStyle from backend string format.
  static LineStyle _parseLineStyle(String style) {
    switch (style) {
      case 'Solid':
        return LineStyle.solid;
      case 'Dashed':
        return LineStyle.dashed;
      case 'Dotted':
        return LineStyle.dotted;
      default:
        return LineStyle.solid;
    }
  }

  /// Parses ArrowStyle from backend string format.
  static ArrowStyle _parseArrowStyle(String style) {
    switch (style) {
      case 'Filled':
        return ArrowStyle.filled;
      case 'Open':
        return ArrowStyle.open;
      case 'None':
        return ArrowStyle.none;
      default:
        return ArrowStyle.filled;
    }
  }

  /// Converts ConnectionType to backend string format.
  static String _connectionTypeToString(ConnectionType type) {
    switch (type) {
      case ConnectionType.commandToAggregate:
        return 'CommandToAggregate';
      case ConnectionType.aggregateToEvent:
        return 'AggregateToEvent';
      case ConnectionType.eventToPolicy:
        return 'EventToPolicy';
      case ConnectionType.policyToCommand:
        return 'PolicyToCommand';
      case ConnectionType.eventToReadModel:
        return 'EventToReadModel';
      case ConnectionType.externalToCommand:
        return 'ExternalToCommand';
      case ConnectionType.uiToCommand:
        return 'UIToCommand';
      case ConnectionType.readModelToUI:
        return 'ReadModelToUI';
      case ConnectionType.custom:
        return 'Custom';
    }
  }

  /// Converts LineStyle to backend string format.
  static String _lineStyleToString(LineStyle style) {
    switch (style) {
      case LineStyle.solid:
        return 'Solid';
      case LineStyle.dashed:
        return 'Dashed';
      case LineStyle.dotted:
        return 'Dotted';
    }
  }

  /// Converts ArrowStyle to backend string format.
  static String _arrowStyleToString(ArrowStyle style) {
    switch (style) {
      case ArrowStyle.filled:
        return 'Filled';
      case ArrowStyle.open:
        return 'Open';
      case ArrowStyle.none:
        return 'None';
    }
  }
}
