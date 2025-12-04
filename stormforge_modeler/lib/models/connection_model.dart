import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:stormforge_modeler/models/element_model.dart';

/// The type of connection between EventStorming elements.
enum ConnectionType {
  /// Command → Aggregate: Shows which aggregate handles a command
  commandToAggregate,

  /// Aggregate → Event: Shows which events an aggregate produces
  aggregateToEvent,

  /// Event → Policy: Shows which policies react to an event
  eventToPolicy,

  /// Policy → Command: Shows which command a policy triggers
  policyToCommand,

  /// Event → Read Model: Shows which read models are updated by an event
  eventToReadModel,

  /// External System → Command: Shows external systems that trigger commands
  externalToCommand,

  /// UI → Command: Shows UI elements that trigger commands
  uiToCommand,

  /// Read Model → UI: Shows UI elements that display read models
  readModelToUI,

  /// Custom relationship between elements
  custom,
}

/// Extension to provide properties for connection types.
extension ConnectionTypeExtension on ConnectionType {
  /// The display name for this connection type.
  String get displayName {
    switch (this) {
      case ConnectionType.commandToAggregate:
        return 'Command → Aggregate';
      case ConnectionType.aggregateToEvent:
        return 'Aggregate → Event';
      case ConnectionType.eventToPolicy:
        return 'Event → Policy';
      case ConnectionType.policyToCommand:
        return 'Policy → Command';
      case ConnectionType.eventToReadModel:
        return 'Event → Read Model';
      case ConnectionType.externalToCommand:
        return 'External → Command';
      case ConnectionType.uiToCommand:
        return 'UI → Command';
      case ConnectionType.readModelToUI:
        return 'Read Model → UI';
      case ConnectionType.custom:
        return 'Custom';
    }
  }

  /// The description for this connection type.
  String get description {
    switch (this) {
      case ConnectionType.commandToAggregate:
        return 'Aggregate handles command';
      case ConnectionType.aggregateToEvent:
        return 'Aggregate produces event';
      case ConnectionType.eventToPolicy:
        return 'Policy reacts to event';
      case ConnectionType.policyToCommand:
        return 'Policy triggers command';
      case ConnectionType.eventToReadModel:
        return 'Event updates read model';
      case ConnectionType.externalToCommand:
        return 'External system triggers command';
      case ConnectionType.uiToCommand:
        return 'UI triggers command';
      case ConnectionType.readModelToUI:
        return 'UI displays read model';
      case ConnectionType.custom:
        return 'Custom relationship';
    }
  }

  /// Gets the default style for this connection type.
  ConnectionStyle get defaultStyle {
    switch (this) {
      case ConnectionType.commandToAggregate:
      case ConnectionType.policyToCommand:
      case ConnectionType.externalToCommand:
      case ConnectionType.uiToCommand:
        return const ConnectionStyle(
          color: Color(0xFF2196F3), // Blue
          strokeWidth: 2.0,
          lineStyle: LineStyle.dashed,
          arrowStyle: ArrowStyle.filled,
        );
      case ConnectionType.aggregateToEvent:
        return const ConnectionStyle(
          color: Color(0xFFFF9800), // Orange
          strokeWidth: 2.0,
          lineStyle: LineStyle.solid,
          arrowStyle: ArrowStyle.filled,
        );
      case ConnectionType.eventToPolicy:
        return const ConnectionStyle(
          color: Color(0xFF9C27B0), // Purple
          strokeWidth: 2.0,
          lineStyle: LineStyle.solid,
          arrowStyle: ArrowStyle.filled,
        );
      case ConnectionType.eventToReadModel:
      case ConnectionType.readModelToUI:
        return const ConnectionStyle(
          color: Color(0xFF4CAF50), // Green
          strokeWidth: 2.0,
          lineStyle: LineStyle.solid,
          arrowStyle: ArrowStyle.filled,
        );
      case ConnectionType.custom:
        return const ConnectionStyle(
          color: Colors.grey,
          strokeWidth: 2.0,
          lineStyle: LineStyle.solid,
          arrowStyle: ArrowStyle.open,
        );
    }
  }

  /// Validates if the connection type is compatible with the given element types.
  bool isValid(ElementType sourceType, ElementType targetType) {
    switch (this) {
      case ConnectionType.commandToAggregate:
        return sourceType == ElementType.command &&
            targetType == ElementType.aggregate;
      case ConnectionType.aggregateToEvent:
        return sourceType == ElementType.aggregate &&
            targetType == ElementType.domainEvent;
      case ConnectionType.eventToPolicy:
        return sourceType == ElementType.domainEvent &&
            targetType == ElementType.policy;
      case ConnectionType.policyToCommand:
        return sourceType == ElementType.policy &&
            targetType == ElementType.command;
      case ConnectionType.eventToReadModel:
        return sourceType == ElementType.domainEvent &&
            targetType == ElementType.readModel;
      case ConnectionType.externalToCommand:
        return sourceType == ElementType.externalSystem &&
            targetType == ElementType.command;
      case ConnectionType.uiToCommand:
        return sourceType == ElementType.ui && targetType == ElementType.command;
      case ConnectionType.readModelToUI:
        return sourceType == ElementType.readModel &&
            targetType == ElementType.ui;
      case ConnectionType.custom:
        return true; // Custom connections allow any element types
    }
  }

  /// Gets the expected element types for this connection type.
  String get expectedTypes {
    switch (this) {
      case ConnectionType.commandToAggregate:
        return 'Command → Aggregate';
      case ConnectionType.aggregateToEvent:
        return 'Aggregate → Domain Event';
      case ConnectionType.eventToPolicy:
        return 'Domain Event → Policy';
      case ConnectionType.policyToCommand:
        return 'Policy → Command';
      case ConnectionType.eventToReadModel:
        return 'Domain Event → Read Model';
      case ConnectionType.externalToCommand:
        return 'External System → Command';
      case ConnectionType.uiToCommand:
        return 'UI → Command';
      case ConnectionType.readModelToUI:
        return 'Read Model → UI';
      case ConnectionType.custom:
        return 'Any → Any';
    }
  }

  /// Gets the icon for this connection type.
  IconData get icon {
    switch (this) {
      case ConnectionType.commandToAggregate:
      case ConnectionType.aggregateToEvent:
      case ConnectionType.eventToPolicy:
      case ConnectionType.policyToCommand:
      case ConnectionType.eventToReadModel:
      case ConnectionType.externalToCommand:
      case ConnectionType.uiToCommand:
      case ConnectionType.readModelToUI:
        return Icons.arrow_forward;
      case ConnectionType.custom:
        return Icons.more_horiz;
    }
  }
}

/// The style of a line in a connection.
enum LineStyle {
  /// Solid line
  solid,

  /// Dashed line
  dashed,

  /// Dotted line
  dotted,
}

/// The style of an arrow in a connection.
enum ArrowStyle {
  /// Filled arrow
  filled,

  /// Open arrow
  open,

  /// No arrow
  none,
}

/// The visual style of a connection.
class ConnectionStyle extends Equatable {
  /// Creates a connection style.
  const ConnectionStyle({
    required this.color,
    required this.strokeWidth,
    required this.lineStyle,
    required this.arrowStyle,
  });

  /// The color of the connection line.
  final Color color;

  /// The width of the connection line.
  final double strokeWidth;

  /// The style of the connection line.
  final LineStyle lineStyle;

  /// The style of the arrow.
  final ArrowStyle arrowStyle;

  /// Creates a copy with the given properties.
  ConnectionStyle copyWith({
    Color? color,
    double? strokeWidth,
    LineStyle? lineStyle,
    ArrowStyle? arrowStyle,
  }) {
    return ConnectionStyle(
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      lineStyle: lineStyle ?? this.lineStyle,
      arrowStyle: arrowStyle ?? this.arrowStyle,
    );
  }

  @override
  List<Object?> get props => [color, strokeWidth, lineStyle, arrowStyle];
}

/// A typed connection between two elements on the canvas.
class TypedConnectionElement extends Equatable {
  /// Creates a typed connection element.
  const TypedConnectionElement({
    required this.id,
    required this.sourceId,
    required this.targetId,
    required this.type,
    this.label = '',
    ConnectionStyle? style,
    this.metadata = const {},
    this.isSelected = false,
  }) : style = style ?? const ConnectionStyle(
          color: Colors.grey,
          strokeWidth: 2.0,
          lineStyle: LineStyle.solid,
          arrowStyle: ArrowStyle.filled,
        );

  /// Unique identifier for this connection.
  final String id;

  /// The ID of the source element.
  final String sourceId;

  /// The ID of the target element.
  final String targetId;

  /// The type of this connection.
  final ConnectionType type;

  /// Optional label for the connection.
  final String label;

  /// The visual style of the connection.
  final ConnectionStyle style;

  /// Additional metadata for the connection.
  final Map<String, dynamic> metadata;

  /// Whether this connection is currently selected.
  final bool isSelected;

  /// Creates a new connection with default values.
  factory TypedConnectionElement.create({
    required String sourceId,
    required String targetId,
    required ConnectionType type,
    String? label,
    ConnectionStyle? style,
  }) {
    return TypedConnectionElement(
      id: const Uuid().v4(),
      sourceId: sourceId,
      targetId: targetId,
      type: type,
      label: label ?? '',
      style: style ?? type.defaultStyle,
    );
  }

  /// Creates a copy with the given properties.
  TypedConnectionElement copyWith({
    String? id,
    String? sourceId,
    String? targetId,
    ConnectionType? type,
    String? label,
    ConnectionStyle? style,
    Map<String, dynamic>? metadata,
    bool? isSelected,
  }) {
    return TypedConnectionElement(
      id: id ?? this.id,
      sourceId: sourceId ?? this.sourceId,
      targetId: targetId ?? this.targetId,
      type: type ?? this.type,
      label: label ?? this.label,
      style: style ?? this.style,
      metadata: metadata ?? this.metadata,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  /// Validates if this connection is valid for the given elements.
  bool isValidFor(CanvasElement source, CanvasElement target) {
    return type.isValid(source.type, target.type);
  }

  @override
  List<Object?> get props => [
        id,
        sourceId,
        targetId,
        type,
        label,
        style,
        metadata,
        isSelected,
      ];
}
