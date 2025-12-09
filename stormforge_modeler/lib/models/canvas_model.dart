import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:stormforge_modeler/models/connection_model.dart';
import 'package:stormforge_modeler/models/element_model.dart';

/// Represents a bounded context on the canvas.
class BoundedContext extends Equatable {
  /// Creates a bounded context.
  const BoundedContext({
    required this.id,
    required this.name,
    required this.namespace,
    this.description = '',
    this.color = Colors.grey,
    required this.bounds,
    this.isSelected = false,
  });

  /// Unique identifier for this context.
  final String id;

  /// The name of this bounded context.
  final String name;

  /// The namespace for generated code.
  final String namespace;

  /// Optional description.
  final String description;

  /// The color used to represent this context.
  final Color color;

  /// The bounding rectangle of this context.
  final Rect bounds;

  /// Whether this context is currently selected.
  final bool isSelected;

  /// Creates a new bounded context with default values.
  factory BoundedContext.create({
    required String name,
    required String namespace,
    String description = '',
    Color color = Colors.blue,
    Rect? bounds,
  }) {
    return BoundedContext(
      id: const Uuid().v4(),
      name: name,
      namespace: namespace,
      description: description,
      color: color,
      bounds: bounds ?? const Rect.fromLTWH(0, 0, 800, 600),
    );
  }

  /// Creates a copy with the given properties.
  BoundedContext copyWith({
    String? id,
    String? name,
    String? namespace,
    String? description,
    Color? color,
    Rect? bounds,
    bool? isSelected,
  }) {
    return BoundedContext(
      id: id ?? this.id,
      name: name ?? this.name,
      namespace: namespace ?? this.namespace,
      description: description ?? this.description,
      color: color ?? this.color,
      bounds: bounds ?? this.bounds,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  /// Checks if this context contains the given point.
  bool containsPoint(Offset point) => bounds.contains(point);

  @override
  List<Object?> get props => [
    id,
    name,
    namespace,
    description,
    color,
    bounds,
    isSelected,
  ];
}

/// The complete canvas model containing all elements and contexts.
class CanvasModel extends Equatable {
  /// Creates a canvas model.
  const CanvasModel({
    this.elements = const [],
    this.connections = const [],
    this.typedConnections = const [],
    this.contexts = const [],
    this.selectedElementId,
    this.selectedConnectionId,
    this.selectedContextId,
  });

  /// All elements on the canvas.
  final List<CanvasElement> elements;

  /// All connections between elements (legacy, for backward compatibility).
  final List<ConnectionElement> connections;

  /// All typed connections between elements (new system).
  final List<TypedConnectionElement> typedConnections;

  /// All bounded contexts.
  final List<BoundedContext> contexts;

  /// The ID of the currently selected element.
  final String? selectedElementId;

  /// The ID of the currently selected connection.
  final String? selectedConnectionId;

  /// The ID of the currently selected context.
  final String? selectedContextId;

  /// Gets the currently selected element, if any.
  CanvasElement? get selectedElement {
    if (selectedElementId == null) return null;
    return elements.cast<CanvasElement?>().firstWhere(
      (e) => e?.id == selectedElementId,
      orElse: () => null,
    );
  }

  /// Gets the currently selected connection, if any.
  ConnectionElement? get selectedConnection {
    if (selectedConnectionId == null) return null;
    return connections.cast<ConnectionElement?>().firstWhere(
      (c) => c?.id == selectedConnectionId,
      orElse: () => null,
    );
  }

  /// Gets the currently selected context, if any.
  BoundedContext? get selectedContext {
    if (selectedContextId == null) return null;
    return contexts.cast<BoundedContext?>().firstWhere(
      (c) => c?.id == selectedContextId,
      orElse: () => null,
    );
  }

  /// Creates a copy with the given properties.
  CanvasModel copyWith({
    List<CanvasElement>? elements,
    List<ConnectionElement>? connections,
    List<TypedConnectionElement>? typedConnections,
    List<BoundedContext>? contexts,
    String? selectedElementId,
    String? selectedConnectionId,
    String? selectedContextId,
    bool clearElementSelection = false,
    bool clearConnectionSelection = false,
    bool clearContextSelection = false,
  }) {
    return CanvasModel(
      elements: elements ?? this.elements,
      connections: connections ?? this.connections,
      typedConnections: typedConnections ?? this.typedConnections,
      contexts: contexts ?? this.contexts,
      selectedElementId: clearElementSelection
          ? null
          : (selectedElementId ?? this.selectedElementId),
      selectedConnectionId: clearConnectionSelection
          ? null
          : (selectedConnectionId ?? this.selectedConnectionId),
      selectedContextId: clearContextSelection
          ? null
          : (selectedContextId ?? this.selectedContextId),
    );
  }

  /// Adds an element to the canvas.
  CanvasModel addElement(CanvasElement element) {
    return copyWith(
      elements: [...elements, element],
      selectedElementId: element.id,
      clearConnectionSelection: true,
      clearContextSelection: true,
    );
  }

  /// Removes an element from the canvas.
  CanvasModel removeElement(String elementId) {
    return copyWith(
      elements: elements.where((e) => e.id != elementId).toList(),
      connections: connections
          .where((c) => c.sourceId != elementId && c.targetId != elementId)
          .toList(),
      clearElementSelection: selectedElementId == elementId,
    );
  }

  /// Updates an element on the canvas.
  CanvasModel updateElement(CanvasElement element) {
    return copyWith(
      elements: elements.map((e) => e.id == element.id ? element : e).toList(),
    );
  }

  /// Adds a connection to the canvas.
  CanvasModel addConnection(ConnectionElement connection) {
    return copyWith(
      connections: [...connections, connection],
      selectedConnectionId: connection.id,
      clearElementSelection: true,
      clearContextSelection: true,
    );
  }

  /// Adds a typed connection to the canvas.
  CanvasModel addTypedConnection(TypedConnectionElement connection) {
    return copyWith(
      typedConnections: [...typedConnections, connection],
      selectedConnectionId: connection.id,
      clearElementSelection: true,
      clearContextSelection: true,
    );
  }

  /// Removes a connection from the canvas.
  CanvasModel removeConnection(String connectionId) {
    return copyWith(
      connections: connections.where((c) => c.id != connectionId).toList(),
      typedConnections:
          typedConnections.where((c) => c.id != connectionId).toList(),
      clearConnectionSelection: selectedConnectionId == connectionId,
    );
  }

  /// Updates a typed connection on the canvas.
  CanvasModel updateTypedConnection(TypedConnectionElement connection) {
    return copyWith(
      typedConnections: typedConnections
          .map((c) => c.id == connection.id ? connection : c)
          .toList(),
    );
  }

  /// Selects an element by ID.
  CanvasModel selectElement(String? elementId) {
    return copyWith(
      selectedElementId: elementId,
      clearConnectionSelection: true,
      clearContextSelection: true,
    );
  }

  /// Clears all selections.
  CanvasModel clearSelection() {
    return copyWith(
      clearElementSelection: true,
      clearConnectionSelection: true,
      clearContextSelection: true,
    );
  }

  /// Gets an element by ID.
  CanvasElement? getElementById(String id) {
    return elements.cast<CanvasElement?>().firstWhere(
      (e) => e?.id == id,
      orElse: () => null,
    );
  }

  @override
  List<Object?> get props => [
    elements,
    connections,
    typedConnections,
    contexts,
    selectedElementId,
    selectedConnectionId,
    selectedContextId,
  ];
}

/// The viewport state for the canvas.
class CanvasViewport extends Equatable {
  /// Creates a canvas viewport.
  const CanvasViewport({this.offset = Offset.zero, this.scale = 1.0});

  /// The current pan offset.
  final Offset offset;

  /// The current zoom scale.
  final double scale;

  /// Minimum zoom scale.
  static const double minScale = 0.1;

  /// Maximum zoom scale.
  static const double maxScale = 4.0;

  /// Creates a copy with the given properties.
  CanvasViewport copyWith({Offset? offset, double? scale}) {
    return CanvasViewport(
      offset: offset ?? this.offset,
      scale: (scale ?? this.scale).clamp(minScale, maxScale),
    );
  }

  /// Converts a screen position to canvas position.
  Offset screenToCanvas(Offset screenPosition) {
    return (screenPosition - offset) / scale;
  }

  /// Converts a canvas position to screen position.
  Offset canvasToScreen(Offset canvasPosition) {
    return canvasPosition * scale + offset;
  }

  @override
  List<Object?> get props => [offset, scale];
}
