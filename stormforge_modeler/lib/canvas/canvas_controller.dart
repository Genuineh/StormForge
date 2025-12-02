import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stormforge_modeler/models/models.dart';

/// Provider for the canvas model state.
final canvasModelProvider = StateNotifierProvider<CanvasModelNotifier, CanvasModel>(
  (ref) => CanvasModelNotifier(),
);

/// Provider for the canvas viewport state.
final canvasViewportProvider = StateNotifierProvider<CanvasViewportNotifier, CanvasViewport>(
  (ref) => CanvasViewportNotifier(),
);

/// Provider for the currently dragged element type (from palette).
final draggedElementTypeProvider = StateProvider<ElementType?>((ref) => null);

/// Provider for tracking if we're in connection mode.
final connectionModeProvider = StateProvider<bool>((ref) => false);

/// Provider for the source element when creating a connection.
final connectionSourceProvider = StateProvider<String?>((ref) => null);

/// State notifier for managing the canvas model.
class CanvasModelNotifier extends StateNotifier<CanvasModel> {
  /// Creates a canvas model notifier.
  CanvasModelNotifier() : super(const CanvasModel());

  /// Adds an element to the canvas.
  void addElement(CanvasElement element) {
    state = state.addElement(element);
  }

  /// Removes an element from the canvas.
  void removeElement(String elementId) {
    state = state.removeElement(elementId);
  }

  /// Updates an element on the canvas.
  void updateElement(CanvasElement element) {
    state = state.updateElement(element);
  }

  /// Moves an element to a new position.
  void moveElement(String elementId, Offset newPosition) {
    final element = state.getElementById(elementId);
    if (element != null) {
      state = state.updateElement(element.copyWith(position: newPosition));
    }
  }

  /// Resizes an element.
  void resizeElement(String elementId, Size newSize) {
    final element = state.getElementById(elementId);
    if (element != null) {
      state = state.updateElement(element.copyWith(size: newSize));
    }
  }

  /// Updates an element's label.
  void updateElementLabel(String elementId, String label) {
    final element = state.getElementById(elementId);
    if (element != null) {
      state = state.updateElement(element.copyWith(label: label));
    }
  }

  /// Updates an element's description.
  void updateElementDescription(String elementId, String description) {
    final element = state.getElementById(elementId);
    if (element != null) {
      state = state.updateElement(element.copyWith(description: description));
    }
  }

  /// Adds a connection between two elements.
  void addConnection(String sourceId, String targetId, {String? label}) {
    final connection = ConnectionElement.create(
      sourceId: sourceId,
      targetId: targetId,
      label: label,
    );
    state = state.addConnection(connection);
  }

  /// Removes a connection from the canvas.
  void removeConnection(String connectionId) {
    state = state.removeConnection(connectionId);
  }

  /// Selects an element by ID.
  void selectElement(String? elementId) {
    state = state.selectElement(elementId);
  }

  /// Clears all selections.
  void clearSelection() {
    state = state.clearSelection();
  }

  /// Creates a new element from a palette drag.
  void createElementFromDrag(ElementType type, Offset position) {
    final element = StickyNoteElement.create(
      type: type,
      position: position,
    );
    addElement(element);
  }

  /// Loads a canvas model (e.g., from YAML).
  void loadModel(CanvasModel model) {
    state = model;
  }

  /// Clears the entire canvas.
  void clearCanvas() {
    state = const CanvasModel();
  }

  /// Gets all elements of a specific type.
  List<CanvasElement> getElementsByType(ElementType type) {
    return state.elements.where((e) => e.type == type).toList();
  }
}

/// State notifier for managing the canvas viewport.
class CanvasViewportNotifier extends StateNotifier<CanvasViewport> {
  /// Creates a canvas viewport notifier.
  CanvasViewportNotifier() : super(const CanvasViewport());

  /// Pans the canvas by the given delta.
  void pan(Offset delta) {
    state = state.copyWith(offset: state.offset + delta);
  }

  /// Sets the canvas offset.
  void setOffset(Offset offset) {
    state = state.copyWith(offset: offset);
  }

  /// Zooms the canvas by the given factor, centered on the given point.
  void zoom(double factor, Offset center) {
    final newScale = (state.scale * factor).clamp(
      CanvasViewport.minScale,
      CanvasViewport.maxScale,
    );
    
    if (newScale == state.scale) return;

    // Adjust offset to zoom toward the center point
    final scaleDiff = newScale / state.scale;
    final newOffset = center - (center - state.offset) * scaleDiff;

    state = state.copyWith(
      scale: newScale,
      offset: newOffset,
    );
  }

  /// Sets the zoom scale directly.
  void setScale(double scale) {
    state = state.copyWith(scale: scale);
  }

  /// Resets the viewport to default.
  void reset() {
    state = const CanvasViewport();
  }

  /// Fits all elements into the viewport.
  void fitToContent(List<CanvasElement> elements, Size viewportSize) {
    if (elements.isEmpty) {
      reset();
      return;
    }

    // Calculate the bounding box of all elements
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final element in elements) {
      minX = minX < element.position.dx ? minX : element.position.dx;
      minY = minY < element.position.dy ? minY : element.position.dy;
      maxX = maxX > (element.position.dx + element.size.width)
          ? maxX
          : (element.position.dx + element.size.width);
      maxY = maxY > (element.position.dy + element.size.height)
          ? maxY
          : (element.position.dy + element.size.height);
    }

    final contentWidth = maxX - minX;
    final contentHeight = maxY - minY;

    // Add some padding
    const padding = 50.0;
    final scale = (viewportSize.width - padding * 2) / contentWidth;
    final scaleY = (viewportSize.height - padding * 2) / contentHeight;
    final finalScale = (scale < scaleY ? scale : scaleY).clamp(
      CanvasViewport.minScale,
      CanvasViewport.maxScale,
    );

    // Center the content
    final offsetX = (viewportSize.width - contentWidth * finalScale) / 2 - minX * finalScale;
    final offsetY = (viewportSize.height - contentHeight * finalScale) / 2 - minY * finalScale;

    state = CanvasViewport(
      offset: Offset(offsetX, offsetY),
      scale: finalScale,
    );
  }
}
