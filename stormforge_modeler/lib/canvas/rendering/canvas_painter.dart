import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:stormforge_modeler/models/models.dart';

/// Custom painter for rendering the EventStorming canvas.
class CanvasPainter extends CustomPainter {
  /// Creates a canvas painter.
  const CanvasPainter({
    required this.model,
    required this.viewport,
    this.dragPreviewType,
    this.dragPreviewPosition,
  });

  /// The canvas model to render.
  final CanvasModel model;

  /// The current viewport state.
  final CanvasViewport viewport;

  /// The type of element being dragged (for preview).
  final ElementType? dragPreviewType;

  /// The position of the drag preview.
  final Offset? dragPreviewPosition;

  @override
  void paint(Canvas canvas, Size size) {
    // Apply viewport transformation
    canvas.save();
    canvas.translate(viewport.offset.dx, viewport.offset.dy);
    canvas.scale(viewport.scale);

    // Draw grid
    _drawGrid(canvas, size);

    // Draw connections
    for (final connection in model.connections) {
      _drawConnection(canvas, connection);
    }

    // Draw elements
    for (final element in model.elements) {
      _drawElement(canvas, element);
    }

    // Draw drag preview
    if (dragPreviewType != null && dragPreviewPosition != null) {
      _drawDragPreview(canvas, dragPreviewType!, dragPreviewPosition!);
    }

    canvas.restore();
  }

  /// Draws the background grid.
  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1.0;

    const gridSize = 50.0;

    // Calculate visible area in canvas coordinates
    final topLeft = viewport.screenToCanvas(Offset.zero);
    final bottomRight =
        viewport.screenToCanvas(Offset(size.width, size.height));

    final startX = (topLeft.dx / gridSize).floor() * gridSize;
    final startY = (topLeft.dy / gridSize).floor() * gridSize;
    final endX = (bottomRight.dx / gridSize).ceil() * gridSize;
    final endY = (bottomRight.dy / gridSize).ceil() * gridSize;

    // Draw vertical lines
    for (double x = startX; x <= endX; x += gridSize) {
      canvas.drawLine(
        Offset(x, startY),
        Offset(x, endY),
        gridPaint,
      );
    }

    // Draw horizontal lines
    for (double y = startY; y <= endY; y += gridSize) {
      canvas.drawLine(
        Offset(startX, y),
        Offset(endX, y),
        gridPaint,
      );
    }
  }

  /// Draws a sticky note element.
  void _drawElement(Canvas canvas, CanvasElement element) {
    final rect = element.bounds;

    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.translate(2, 2),
        const Radius.circular(4),
      ),
      shadowPaint,
    );

    // Background
    final backgroundPaint = Paint()..color = element.type.backgroundColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      backgroundPaint,
    );

    // Selection border
    if (element.isSelected) {
      final selectionPaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.inflate(2), const Radius.circular(6)),
        selectionPaint,
      );
    }

    // Border
    final borderPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      borderPaint,
    );

    // Label text
    final textPainter = TextPainter(
      text: TextSpan(
        text: element.label,
        style: TextStyle(
          color: element.type.textColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 3,
      ellipsis: '...',
    );
    textPainter.layout(maxWidth: rect.width - 16);
    textPainter.paint(
      canvas,
      rect.topLeft + const Offset(8, 8),
    );

    // Type indicator
    final typeTextPainter = TextPainter(
      text: TextSpan(
        text: element.type.displayName.toUpperCase(),
        style: TextStyle(
          color: element.type.textColor.withOpacity(0.6),
          fontSize: 9,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    typeTextPainter.layout();
    typeTextPainter.paint(
      canvas,
      Offset(
        rect.left + 8,
        rect.bottom - typeTextPainter.height - 6,
      ),
    );
  }

  /// Draws a connection between elements.
  void _drawConnection(Canvas canvas, ConnectionElement connection) {
    final sourceElement = model.getElementById(connection.sourceId);
    final targetElement = model.getElementById(connection.targetId);

    if (sourceElement == null || targetElement == null) return;

    final sourceCenter = sourceElement.bounds.center;
    final targetCenter = targetElement.bounds.center;

    // Calculate connection points on element boundaries
    final sourcePoint = _getConnectionPoint(sourceElement.bounds, targetCenter);
    final targetPoint = _getConnectionPoint(targetElement.bounds, sourceCenter);

    final linePaint = Paint()
      ..color = connection.isSelected ? Colors.blue : Colors.grey
      ..strokeWidth = connection.isSelected ? 2 : 1
      ..style = PaintingStyle.stroke;

    // Draw curved line
    final path = Path();
    path.moveTo(sourcePoint.dx, sourcePoint.dy);

    final midX = (sourcePoint.dx + targetPoint.dx) / 2;
    final midY = (sourcePoint.dy + targetPoint.dy) / 2;

    // Simple quadratic curve
    path.quadraticBezierTo(
      midX,
      midY - 20,
      targetPoint.dx,
      targetPoint.dy,
    );

    canvas.drawPath(path, linePaint);

    // Draw arrow head
    _drawArrowHead(canvas, targetPoint, sourcePoint, linePaint);
  }

  /// Gets the connection point on a rectangle's boundary toward a target point.
  Offset _getConnectionPoint(Rect rect, Offset target) {
    final center = rect.center;
    final dx = target.dx - center.dx;
    final dy = target.dy - center.dy;

    if (dx == 0 && dy == 0) return center;

    final absDx = dx.abs();
    final absDy = dy.abs();

    // Determine which edge to connect to
    if (absDx / rect.width > absDy / rect.height) {
      // Connect to left or right edge
      final x = dx > 0 ? rect.right : rect.left;
      final y = center.dy + dy * (x - center.dx).abs() / absDx;
      return Offset(x, y.clamp(rect.top, rect.bottom));
    } else {
      // Connect to top or bottom edge
      final y = dy > 0 ? rect.bottom : rect.top;
      final x = center.dx + dx * (y - center.dy).abs() / absDy;
      return Offset(x.clamp(rect.left, rect.right), y);
    }
  }

  /// Draws an arrow head at the target point.
  void _drawArrowHead(Canvas canvas, Offset point, Offset from, Paint paint) {
    final direction = (point - from);
    final normalized = direction / direction.distance;

    const arrowLength = 10.0;
    const arrowAngle = 0.5;

    final arrowPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(point.dx, point.dy);
    path.lineTo(
      point.dx -
          arrowLength *
              (normalized.dx * arrowAngle.cos() -
                  normalized.dy * arrowAngle.sin()),
      point.dy -
          arrowLength *
              (normalized.dx * arrowAngle.sin() +
                  normalized.dy * arrowAngle.cos()),
    );
    path.lineTo(
      point.dx -
          arrowLength *
              (normalized.dx * arrowAngle.cos() +
                  normalized.dy * arrowAngle.sin()),
      point.dy -
          arrowLength *
              (-normalized.dx * arrowAngle.sin() +
                  normalized.dy * arrowAngle.cos()),
    );
    path.close();

    canvas.drawPath(path, arrowPaint);
  }

  /// Draws a preview of an element being dragged from the palette.
  void _drawDragPreview(Canvas canvas, ElementType type, Offset position) {
    final rect = Rect.fromCenter(
      center: position,
      width: 150,
      height: 100,
    );

    // Semi-transparent background
    final backgroundPaint = Paint()
      ..color = type.backgroundColor.withOpacity(0.6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      backgroundPaint,
    );

    // Dashed border
    final borderPaint = Paint()
      ..color = type.backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      borderPaint,
    );

    // Label
    final textPainter = TextPainter(
      text: TextSpan(
        text: type.displayName,
        style: TextStyle(
          color: type.textColor.withOpacity(0.8),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      rect.topLeft + const Offset(8, 8),
    );
  }

  @override
  bool shouldRepaint(covariant CanvasPainter oldDelegate) {
    return model != oldDelegate.model ||
        viewport != oldDelegate.viewport ||
        dragPreviewType != oldDelegate.dragPreviewType ||
        dragPreviewPosition != oldDelegate.dragPreviewPosition;
  }
}

/// Extension on double for math operations.
extension DoubleExtension on double {
  /// Returns the cosine of this angle in radians.
  double cos() => math.cos(this);

  /// Returns the sine of this angle in radians.
  double sin() => math.sin(this);
}
