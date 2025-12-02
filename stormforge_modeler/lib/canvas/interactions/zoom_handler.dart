import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stormforge_modeler/canvas/canvas_controller.dart';

/// Handles zoom interactions on the canvas.
class ZoomHandler {
  /// Creates a zoom handler.
  ZoomHandler({
    required this.ref,
  });

  /// The Riverpod ref for accessing providers.
  final Ref ref;

  /// The zoom factor per scroll step.
  static const double _zoomFactor = 0.1;

  /// Handles scroll zoom.
  void handleScroll(PointerScrollEvent event) {
    final delta = event.scrollDelta.dy;
    final zoomChange = delta > 0 ? (1 - _zoomFactor) : (1 + _zoomFactor);
    
    ref.read(canvasViewportProvider.notifier).zoom(
      zoomChange,
      event.localPosition,
    );
  }

  /// Handles pinch zoom.
  void handlePinchZoom(double scale, Offset focalPoint) {
    ref.read(canvasViewportProvider.notifier).zoom(scale, focalPoint);
  }

  /// Zooms in by a fixed amount.
  void zoomIn() {
    final viewport = ref.read(canvasViewportProvider);
    ref.read(canvasViewportProvider.notifier).setScale(viewport.scale * 1.2);
  }

  /// Zooms out by a fixed amount.
  void zoomOut() {
    final viewport = ref.read(canvasViewportProvider);
    ref.read(canvasViewportProvider.notifier).setScale(viewport.scale / 1.2);
  }

  /// Resets zoom to 100%.
  void resetZoom() {
    ref.read(canvasViewportProvider.notifier).setScale(1.0);
  }

  /// Fits all elements into the viewport.
  void fitToContent(Size viewportSize) {
    final canvasModel = ref.read(canvasModelProvider);
    ref.read(canvasViewportProvider.notifier).fitToContent(
      canvasModel.elements,
      viewportSize,
    );
  }
}

/// Handles pan interactions on the canvas.
class PanHandler {
  /// Creates a pan handler.
  PanHandler({
    required this.ref,
  });

  /// The Riverpod ref for accessing providers.
  final Ref ref;

  /// Pans the canvas by the given delta.
  void pan(Offset delta) {
    ref.read(canvasViewportProvider.notifier).pan(delta);
  }

  /// Resets pan to center.
  void resetPan() {
    ref.read(canvasViewportProvider.notifier).setOffset(Offset.zero);
  }
}
