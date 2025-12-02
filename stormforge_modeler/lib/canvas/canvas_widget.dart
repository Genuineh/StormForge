import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stormforge_modeler/canvas/canvas_controller.dart';
import 'package:stormforge_modeler/canvas/rendering/canvas_painter.dart';
import 'package:stormforge_modeler/canvas/interactions/drag_handler.dart';
import 'package:stormforge_modeler/canvas/interactions/zoom_handler.dart';
import 'package:stormforge_modeler/models/models.dart';

/// The main EventStorming canvas widget.
class EventStormingCanvas extends ConsumerStatefulWidget {
  /// Creates an EventStorming canvas.
  const EventStormingCanvas({super.key});

  @override
  ConsumerState<EventStormingCanvas> createState() =>
      _EventStormingCanvasState();
}

class _EventStormingCanvasState extends ConsumerState<EventStormingCanvas> {
  /// The current drag target position for drag-drop from palette.
  Offset? _dragTargetPosition;

  @override
  Widget build(BuildContext context) {
    final canvasModel = ref.watch(canvasModelProvider);
    final viewport = ref.watch(canvasViewportProvider);
    final draggedType = ref.watch(draggedElementTypeProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        return DragTarget<ElementType>(
          onWillAcceptWithDetails: (details) {
            _dragTargetPosition = details.offset;
            return true;
          },
          onAcceptWithDetails: (details) {
            // Convert screen position to canvas position
            final canvasPosition = viewport.screenToCanvas(
              details.offset -
                  Offset(constraints.maxWidth / 2, constraints.maxHeight / 2),
            );

            ref
                .read(canvasModelProvider.notifier)
                .createElementFromDrag(details.data, canvasPosition);
            ref.read(draggedElementTypeProvider.notifier).state = null;
          },
          onLeave: (data) {
            _dragTargetPosition = null;
          },
          builder: (context, candidateData, rejectedData) {
            return GestureDetector(
              onTapDown: (details) => _handleTapDown(details, viewport),
              onPanStart: (details) => _handlePanStart(details),
              onPanUpdate: (details) => _handlePanUpdate(details),
              onPanEnd: (details) => _handlePanEnd(details),
              child: Listener(
                onPointerSignal: (event) {
                  if (event is PointerScrollEvent) {
                    _handleScroll(event, viewport);
                  }
                },
                child: ClipRect(
                  child: CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: CanvasPainter(
                      model: canvasModel,
                      viewport: viewport,
                      dragPreviewType: draggedType,
                      dragPreviewPosition: _dragTargetPosition != null
                          ? viewport.screenToCanvas(
                              _dragTargetPosition! -
                                  Offset(
                                    constraints.maxWidth / 2,
                                    constraints.maxHeight / 2,
                                  ),
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Handles tap down events on the canvas.
  void _handleTapDown(TapDownDetails details, CanvasViewport viewport) {
    final canvasPosition = viewport.screenToCanvas(details.localPosition);
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

  Offset? _lastPanPosition;
  String? _draggingElementId;

  /// Handles pan start events.
  void _handlePanStart(DragStartDetails details) {
    _lastPanPosition = details.localPosition;

    final viewport = ref.read(canvasViewportProvider);
    final canvasPosition = viewport.screenToCanvas(details.localPosition);
    final canvasModel = ref.read(canvasModelProvider);

    // Check if we're starting to drag an element
    for (final element in canvasModel.elements.reversed) {
      if (element.containsPoint(canvasPosition)) {
        _draggingElementId = element.id;
        ref.read(canvasModelProvider.notifier).selectElement(element.id);
        return;
      }
    }

    _draggingElementId = null;
  }

  /// Handles pan update events.
  void _handlePanUpdate(DragUpdateDetails details) {
    if (_lastPanPosition == null) return;

    final delta = details.localPosition - _lastPanPosition!;
    _lastPanPosition = details.localPosition;

    if (_draggingElementId != null) {
      // Drag the element
      final viewport = ref.read(canvasViewportProvider);
      final scaledDelta = delta / viewport.scale;

      final element = ref
          .read(canvasModelProvider)
          .getElementById(_draggingElementId!);
      if (element != null) {
        ref
            .read(canvasModelProvider.notifier)
            .moveElement(_draggingElementId!, element.position + scaledDelta);
      }
    } else {
      // Pan the canvas
      ref.read(canvasViewportProvider.notifier).pan(delta);
    }
  }

  /// Handles pan end events.
  void _handlePanEnd(DragEndDetails details) {
    _lastPanPosition = null;
    _draggingElementId = null;
  }

  /// Handles scroll events for zooming.
  void _handleScroll(PointerScrollEvent event, CanvasViewport viewport) {
    final zoomFactor = event.scrollDelta.dy > 0 ? 0.9 : 1.1;
    ref
        .read(canvasViewportProvider.notifier)
        .zoom(zoomFactor, event.localPosition);
  }
}
