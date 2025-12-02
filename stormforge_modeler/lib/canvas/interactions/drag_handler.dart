import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stormforge_modeler/canvas/canvas_controller.dart';
import 'package:stormforge_modeler/models/models.dart';

/// Handles drag interactions on the canvas.
class DragHandler {
  /// Creates a drag handler.
  DragHandler({
    required this.ref,
  });

  /// The Riverpod ref for accessing providers.
  final Ref ref;

  /// The element ID being dragged, if any.
  String? _draggingElementId;

  /// The last drag position.
  Offset? _lastPosition;

  /// The initial element position when drag started.
  Offset? _initialElementPosition;

  /// Starts a drag operation.
  void startDrag(Offset position) {
    _lastPosition = position;

    final viewport = ref.read(canvasViewportProvider);
    final canvasPosition = viewport.screenToCanvas(position);
    final canvasModel = ref.read(canvasModelProvider);

    // Check if we're starting to drag an element (check in reverse for top elements first)
    for (final element in canvasModel.elements.reversed) {
      if (element.containsPoint(canvasPosition)) {
        _draggingElementId = element.id;
        _initialElementPosition = element.position;
        ref.read(canvasModelProvider.notifier).selectElement(element.id);
        return;
      }
    }

    _draggingElementId = null;
    _initialElementPosition = null;
  }

  /// Updates the drag operation.
  void updateDrag(Offset position) {
    if (_lastPosition == null) return;

    final delta = position - _lastPosition!;
    _lastPosition = position;

    if (_draggingElementId != null) {
      // Drag the element
      final viewport = ref.read(canvasViewportProvider);
      final scaledDelta = delta / viewport.scale;

      final element = ref.read(canvasModelProvider).getElementById(_draggingElementId!);
      if (element != null) {
        ref.read(canvasModelProvider.notifier).moveElement(
          _draggingElementId!,
          element.position + scaledDelta,
        );
      }
    } else {
      // Pan the canvas
      ref.read(canvasViewportProvider.notifier).pan(delta);
    }
  }

  /// Ends the drag operation.
  void endDrag() {
    // Snap to grid if enabled
    if (_draggingElementId != null) {
      final element = ref.read(canvasModelProvider).getElementById(_draggingElementId!);
      if (element != null) {
        final snappedPosition = _snapToGrid(element.position);
        ref.read(canvasModelProvider.notifier).moveElement(
          _draggingElementId!,
          snappedPosition,
        );
      }
    }

    _draggingElementId = null;
    _lastPosition = null;
    _initialElementPosition = null;
  }

  /// Cancels the current drag operation.
  void cancelDrag() {
    // Restore initial position if we were dragging an element
    if (_draggingElementId != null && _initialElementPosition != null) {
      ref.read(canvasModelProvider.notifier).moveElement(
        _draggingElementId!,
        _initialElementPosition!,
      );
    }

    _draggingElementId = null;
    _lastPosition = null;
    _initialElementPosition = null;
  }

  /// Returns whether an element is being dragged.
  bool get isDraggingElement => _draggingElementId != null;

  /// Returns the ID of the element being dragged.
  String? get draggingElementId => _draggingElementId;

  /// Snaps a position to the nearest grid point.
  Offset _snapToGrid(Offset position, {double gridSize = 25.0}) {
    return Offset(
      (position.dx / gridSize).round() * gridSize,
      (position.dy / gridSize).round() * gridSize,
    );
  }
}

/// Handles selection interactions on the canvas.
class SelectionHandler {
  /// Creates a selection handler.
  SelectionHandler({
    required this.ref,
  });

  /// The Riverpod ref for accessing providers.
  final Ref ref;

  /// Handles a tap on the canvas.
  void handleTap(Offset position) {
    final viewport = ref.read(canvasViewportProvider);
    final canvasPosition = viewport.screenToCanvas(position);
    final canvasModel = ref.read(canvasModelProvider);

    // Check if we tapped on an element
    for (final element in canvasModel.elements.reversed) {
      if (element.containsPoint(canvasPosition)) {
        ref.read(canvasModelProvider.notifier).selectElement(element.id);
        return;
      }
    }

    // Clicked on empty space - clear selection
    ref.read(canvasModelProvider.notifier).clearSelection();
  }

  /// Handles a double tap on the canvas.
  void handleDoubleTap(Offset position) {
    final viewport = ref.read(canvasViewportProvider);
    final canvasPosition = viewport.screenToCanvas(position);
    final canvasModel = ref.read(canvasModelProvider);

    // Check if we double-tapped on an element
    for (final element in canvasModel.elements.reversed) {
      if (element.containsPoint(canvasPosition)) {
        // TODO: Open element editor dialog
        return;
      }
    }
  }

  /// Selects all elements.
  void selectAll() {
    // TODO: Implement multi-selection
  }

  /// Clears the selection.
  void clearSelection() {
    ref.read(canvasModelProvider.notifier).clearSelection();
  }
}

/// Handles context menu interactions.
class ContextMenuHandler {
  /// Creates a context menu handler.
  ContextMenuHandler({
    required this.ref,
  });

  /// The Riverpod ref for accessing providers.
  final Ref ref;

  /// Shows a context menu at the given position.
  void showContextMenu(BuildContext context, Offset position) {
    final viewport = ref.read(canvasViewportProvider);
    final canvasPosition = viewport.screenToCanvas(position);
    final canvasModel = ref.read(canvasModelProvider);

    // Check if we right-clicked on an element
    CanvasElement? clickedElement;
    for (final element in canvasModel.elements.reversed) {
      if (element.containsPoint(canvasPosition)) {
        clickedElement = element;
        break;
      }
    }

    if (clickedElement != null) {
      _showElementContextMenu(context, position, clickedElement);
    } else {
      _showCanvasContextMenu(context, position, canvasPosition);
    }
  }

  /// Shows context menu for an element.
  void _showElementContextMenu(
    BuildContext context,
    Offset position,
    CanvasElement element,
  ) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx, position.dy),
      items: [
        PopupMenuItem(
          value: 'edit',
          child: const ListTile(
            leading: Icon(Icons.edit),
            title: Text('Edit'),
            dense: true,
          ),
          onTap: () {
            // TODO: Open edit dialog
          },
        ),
        PopupMenuItem(
          value: 'duplicate',
          child: const ListTile(
            leading: Icon(Icons.copy),
            title: Text('Duplicate'),
            dense: true,
          ),
          onTap: () {
            _duplicateElement(element);
          },
        ),
        PopupMenuItem(
          value: 'delete',
          child: const ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: Text('Delete', style: TextStyle(color: Colors.red)),
            dense: true,
          ),
          onTap: () {
            ref.read(canvasModelProvider.notifier).removeElement(element.id);
          },
        ),
      ],
    );
  }

  /// Shows context menu for the canvas.
  void _showCanvasContextMenu(
    BuildContext context,
    Offset position,
    Offset canvasPosition,
  ) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx, position.dy),
      items: [
        for (final type in ElementType.values)
          PopupMenuItem(
            value: type,
            child: ListTile(
              leading: Icon(type.icon, color: type.backgroundColor),
              title: Text(type.displayName),
              dense: true,
            ),
            onTap: () {
              ref.read(canvasModelProvider.notifier).createElementFromDrag(
                type,
                canvasPosition,
              );
            },
          ),
      ],
    );
  }

  /// Duplicates an element.
  void _duplicateElement(CanvasElement element) {
    final newElement = element.copyWith(
      id: null, // Will generate new ID
      position: element.position + const Offset(20, 20),
      isSelected: false,
    );
    ref.read(canvasModelProvider.notifier).addElement(newElement);
  }
}
