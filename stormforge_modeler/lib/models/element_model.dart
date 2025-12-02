import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

/// The type of EventStorming element.
enum ElementType {
  /// Domain Event (Orange) - Things that have happened in the domain.
  domainEvent,

  /// Command (Blue) - Actions that cause events.
  command,

  /// Aggregate (Yellow) - Domain objects that handle commands.
  aggregate,

  /// Policy (Purple) - Automated reactions to events.
  policy,

  /// Read Model (Green) - Views/projections of data.
  readModel,

  /// External System (Pink) - Third-party integrations.
  externalSystem,

  /// UI (White) - User interface elements.
  ui,
}

/// Extension to provide visual properties for element types.
extension ElementTypeExtension on ElementType {
  /// The display name for this element type.
  String get displayName {
    switch (this) {
      case ElementType.domainEvent:
        return 'Domain Event';
      case ElementType.command:
        return 'Command';
      case ElementType.aggregate:
        return 'Aggregate';
      case ElementType.policy:
        return 'Policy';
      case ElementType.readModel:
        return 'Read Model';
      case ElementType.externalSystem:
        return 'External System';
      case ElementType.ui:
        return 'UI';
    }
  }

  /// The background color for this element type.
  Color get backgroundColor {
    switch (this) {
      case ElementType.domainEvent:
        return const Color(0xFFFF9800); // Orange
      case ElementType.command:
        return const Color(0xFF2196F3); // Blue
      case ElementType.aggregate:
        return const Color(0xFFFFEB3B); // Yellow
      case ElementType.policy:
        return const Color(0xFF9C27B0); // Purple
      case ElementType.readModel:
        return const Color(0xFF4CAF50); // Green
      case ElementType.externalSystem:
        return const Color(0xFFE91E63); // Pink
      case ElementType.ui:
        return const Color(0xFFFAFAFA); // White
    }
  }

  /// The text color for this element type.
  Color get textColor {
    switch (this) {
      case ElementType.domainEvent:
      case ElementType.command:
      case ElementType.policy:
      case ElementType.externalSystem:
        return Colors.white;
      case ElementType.aggregate:
      case ElementType.readModel:
      case ElementType.ui:
        return Colors.black87;
    }
  }

  /// The icon for this element type.
  IconData get icon {
    switch (this) {
      case ElementType.domainEvent:
        return Icons.event_note;
      case ElementType.command:
        return Icons.play_arrow;
      case ElementType.aggregate:
        return Icons.account_tree;
      case ElementType.policy:
        return Icons.policy;
      case ElementType.readModel:
        return Icons.visibility;
      case ElementType.externalSystem:
        return Icons.cloud;
      case ElementType.ui:
        return Icons.web;
    }
  }

  /// The description for this element type.
  String get description {
    switch (this) {
      case ElementType.domainEvent:
        return 'Something that has happened in the domain (past tense)';
      case ElementType.command:
        return 'An action that triggers a domain event';
      case ElementType.aggregate:
        return 'A cluster of domain objects treated as a unit';
      case ElementType.policy:
        return 'A reaction to an event that triggers another command';
      case ElementType.readModel:
        return 'A projection or view of domain data';
      case ElementType.externalSystem:
        return 'An external system that interacts with the domain';
      case ElementType.ui:
        return 'A user interface element';
    }
  }
}

/// A base class for canvas elements.
abstract class CanvasElement extends Equatable {
  /// Creates a canvas element.
  const CanvasElement({
    required this.id,
    required this.type,
    required this.position,
    required this.size,
    required this.label,
    this.description = '',
    this.isSelected = false,
  });

  /// Unique identifier for this element.
  final String id;

  /// The type of this element.
  final ElementType type;

  /// The position of this element on the canvas.
  final Offset position;

  /// The size of this element.
  final Size size;

  /// The label/name of this element.
  final String label;

  /// Optional description of this element.
  final String description;

  /// Whether this element is currently selected.
  final bool isSelected;

  /// Creates a copy of this element with the given properties.
  CanvasElement copyWith({
    String? id,
    ElementType? type,
    Offset? position,
    Size? size,
    String? label,
    String? description,
    bool? isSelected,
  });

  /// The bounding rectangle of this element.
  Rect get bounds =>
      Rect.fromLTWH(position.dx, position.dy, size.width, size.height);

  /// Checks if this element contains the given point.
  bool containsPoint(Offset point) => bounds.contains(point);

  @override
  List<Object?> get props => [
    id,
    type,
    position,
    size,
    label,
    description,
    isSelected,
  ];
}

/// A sticky note element on the canvas.
class StickyNoteElement extends CanvasElement {
  /// Creates a sticky note element.
  const StickyNoteElement({
    required super.id,
    required super.type,
    required super.position,
    super.size = const Size(150, 100),
    required super.label,
    super.description,
    super.isSelected,
  });

  /// Creates a new sticky note with default values.
  factory StickyNoteElement.create({
    required ElementType type,
    required Offset position,
    String? label,
  }) {
    return StickyNoteElement(
      id: const Uuid().v4(),
      type: type,
      position: position,
      label: label ?? type.displayName,
    );
  }

  @override
  StickyNoteElement copyWith({
    String? id,
    ElementType? type,
    Offset? position,
    Size? size,
    String? label,
    String? description,
    bool? isSelected,
  }) {
    return StickyNoteElement(
      id: id ?? this.id,
      type: type ?? this.type,
      position: position ?? this.position,
      size: size ?? this.size,
      label: label ?? this.label,
      description: description ?? this.description,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

/// A connection between two elements.
class ConnectionElement extends Equatable {
  /// Creates a connection between two elements.
  const ConnectionElement({
    required this.id,
    required this.sourceId,
    required this.targetId,
    this.label = '',
    this.isSelected = false,
  });

  /// Unique identifier for this connection.
  final String id;

  /// The ID of the source element.
  final String sourceId;

  /// The ID of the target element.
  final String targetId;

  /// Optional label for the connection.
  final String label;

  /// Whether this connection is currently selected.
  final bool isSelected;

  /// Creates a new connection with default values.
  factory ConnectionElement.create({
    required String sourceId,
    required String targetId,
    String? label,
  }) {
    return ConnectionElement(
      id: const Uuid().v4(),
      sourceId: sourceId,
      targetId: targetId,
      label: label ?? '',
    );
  }

  /// Creates a copy of this connection with the given properties.
  ConnectionElement copyWith({
    String? id,
    String? sourceId,
    String? targetId,
    String? label,
    bool? isSelected,
  }) {
    return ConnectionElement(
      id: id ?? this.id,
      sourceId: sourceId ?? this.sourceId,
      targetId: targetId ?? this.targetId,
      label: label ?? this.label,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  List<Object?> get props => [id, sourceId, targetId, label, isSelected];
}
