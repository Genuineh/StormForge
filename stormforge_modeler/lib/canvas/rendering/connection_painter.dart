import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:stormforge_modeler/models/models.dart';
import 'package:stormforge_modeler/models/connection_model.dart';

/// Painter for rendering typed connections between elements.
class ConnectionPainter {
  /// The canvas model containing elements.
  final CanvasModel model;

  /// The canvas viewport for coordinate transformations.
  final CanvasViewport viewport;

  /// Creates a connection painter.
  const ConnectionPainter({
    required this.model,
    required this.viewport,
  });

  /// Paints all typed connections.
  void paint(Canvas canvas) {
    // Draw legacy connections first (backward compatibility)
    for (final connection in model.connections) {
      _drawLegacyConnection(canvas, connection);
    }

    // Draw typed connections
    for (final connection in model.typedConnections) {
      _drawTypedConnection(canvas, connection);
    }
  }

  /// Draws a legacy connection (backward compatibility).
  void _drawLegacyConnection(Canvas canvas, ConnectionElement connection) {
    final sourceElement = model.getElementById(connection.sourceId);
    final targetElement = model.getElementById(connection.targetId);

    if (sourceElement == null || targetElement == null) return;

    final sourceCenter = sourceElement.bounds.center;
    final targetCenter = targetElement.bounds.center;

    final sourcePoint = _getConnectionPoint(sourceElement.bounds, targetCenter);
    final targetPoint = _getConnectionPoint(targetElement.bounds, sourceCenter);

    final linePaint = Paint()
      ..color = connection.isSelected ? Colors.blue : Colors.grey
      ..strokeWidth = connection.isSelected ? 2.0 : 1.5
      ..style = PaintingStyle.stroke;

    final path = _createConnectionPath(sourcePoint, targetPoint);
    canvas.drawPath(path, linePaint);

    _drawArrow(
      canvas,
      targetPoint,
      sourcePoint,
      connection.isSelected ? Colors.blue : Colors.grey,
      ArrowStyle.filled,
    );

    if (connection.label.isNotEmpty) {
      _drawLabel(canvas, path, connection.label);
    }
  }

  /// Draws a typed connection with full styling support.
  void _drawTypedConnection(Canvas canvas, TypedConnectionElement connection) {
    final sourceElement = model.getElementById(connection.sourceId);
    final targetElement = model.getElementById(connection.targetId);

    if (sourceElement == null || targetElement == null) return;

    final sourceCenter = sourceElement.bounds.center;
    final targetCenter = targetElement.bounds.center;

    final sourcePoint = _getConnectionPoint(sourceElement.bounds, targetCenter);
    final targetPoint = _getConnectionPoint(targetElement.bounds, sourceCenter);

    // Create paint with connection style
    final linePaint = Paint()
      ..color = _parseColor(connection.style.color)
      ..strokeWidth = connection.isSelected
          ? connection.style.strokeWidth + 1.0
          : connection.style.strokeWidth
      ..style = PaintingStyle.stroke;

    // Apply line style (solid, dashed, dotted)
    final path = _createConnectionPath(sourcePoint, targetPoint);

    if (connection.style.lineStyle == LineStyle.dashed) {
      _drawDashedPath(canvas, path, linePaint, 8.0, 4.0);
    } else if (connection.style.lineStyle == LineStyle.dotted) {
      _drawDashedPath(canvas, path, linePaint, 2.0, 4.0);
    } else {
      canvas.drawPath(path, linePaint);
    }

    // Draw arrow
    if (connection.style.arrowStyle != ArrowStyle.none) {
      _drawArrow(
        canvas,
        targetPoint,
        sourcePoint,
        _parseColor(connection.style.color),
        connection.style.arrowStyle,
      );
    }

    // Draw label if present
    if (connection.label.isNotEmpty) {
      _drawLabel(canvas, path, connection.label);
    }

    // Draw selection indicator
    if (connection.isSelected) {
      _drawSelectionIndicator(canvas, sourcePoint, targetPoint);
    }
  }

  /// Creates a connection path between two points using orthogonal routing.
  Path _createConnectionPath(Offset start, Offset end) {
    final path = Path();
    path.moveTo(start.dx, start.dy);

    // Calculate if we should use horizontal-first or vertical-first routing
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;

    // Use orthogonal (Manhattan) routing for cleaner diagrams
    if (dx.abs() > dy.abs()) {
      // Horizontal-first routing
      final midX = start.dx + dx / 2;
      path.lineTo(midX, start.dy);
      path.lineTo(midX, end.dy);
      path.lineTo(end.dx, end.dy);
    } else {
      // Vertical-first routing
      final midY = start.dy + dy / 2;
      path.lineTo(start.dx, midY);
      path.lineTo(end.dx, midY);
      path.lineTo(end.dx, end.dy);
    }

    return path;
  }

  /// Draws a dashed path.
  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint,
    double dashWidth,
    double dashSpace,
  ) {
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final length = draw ? dashWidth : dashSpace;
        final nextDistance = distance + length;
        if (nextDistance > metric.length) {
          break;
        }
        final segment = metric.extractPath(distance, nextDistance);
        if (draw) {
          canvas.drawPath(segment, paint);
        }
        distance = nextDistance;
        draw = !draw;
      }
    }
  }

  /// Draws an arrow at the target point.
  void _drawArrow(
    Canvas canvas,
    Offset tip,
    Offset from,
    Color color,
    ArrowStyle style,
  ) {
    if (style == ArrowStyle.none) return;

    final angle = math.atan2(tip.dy - from.dy, tip.dx - from.dx);
    const arrowSize = 12.0;
    const arrowAngle = math.pi / 6;

    final path = Path();
    path.moveTo(tip.dx, tip.dy);
    path.lineTo(
      tip.dx - arrowSize * math.cos(angle - arrowAngle),
      tip.dy - arrowSize * math.sin(angle - arrowAngle),
    );
    path.lineTo(
      tip.dx - arrowSize * math.cos(angle + arrowAngle),
      tip.dy - arrowSize * math.sin(angle + arrowAngle),
    );
    path.close();

    final paint = Paint()..color = color;

    if (style == ArrowStyle.filled) {
      paint.style = PaintingStyle.fill;
    } else {
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 2.0;
    }

    canvas.drawPath(path, paint);
  }

  /// Draws a label on the connection path.
  void _drawLabel(Canvas canvas, Path path, String label) {
    final metrics = path.computeMetrics().first;
    final midPoint = metrics.getTangentForOffset(metrics.length / 2)?.position;

    if (midPoint == null) return;

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Draw background
    final labelRect = Rect.fromCenter(
      center: midPoint,
      width: textPainter.width + 8,
      height: textPainter.height + 4,
    );

    final bgPaint = Paint()..color = Colors.white.withOpacity(0.95);
    canvas.drawRRect(
      RRect.fromRectAndRadius(labelRect, const Radius.circular(3)),
      bgPaint,
    );

    // Draw border
    final borderPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(labelRect, const Radius.circular(3)),
      borderPaint,
    );

    // Draw text
    textPainter.paint(
      canvas,
      Offset(
        midPoint.dx - textPainter.width / 2,
        midPoint.dy - textPainter.height / 2,
      ),
    );
  }

  /// Draws a selection indicator for the connection.
  void _drawSelectionIndicator(Canvas canvas, Offset start, Offset end) {
    final selectionPaint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke;

    final path = _createConnectionPath(start, end);
    canvas.drawPath(path, selectionPaint);
  }

  /// Gets the connection point on a rectangle's boundary toward a target point.
  Offset _getConnectionPoint(Rect rect, Offset target) {
    final center = rect.center;
    final dx = target.dx - center.dx;
    final dy = target.dy - center.dy;

    // Determine which edge of the rectangle to use
    if (dx.abs() > dy.abs()) {
      // Use left or right edge
      final x = dx > 0 ? rect.right : rect.left;
      return Offset(x, center.dy);
    } else {
      // Use top or bottom edge
      final y = dy > 0 ? rect.bottom : rect.top;
      return Offset(center.dx, y);
    }
  }

  /// Parses a color string (hex format like "#2196F3") to a Color object.
  Color _parseColor(String colorStr) {
    try {
      if (colorStr.startsWith('#')) {
        final hexColor = colorStr.substring(1);
        if (hexColor.length == 6) {
          return Color(int.parse('FF$hexColor', radix: 16));
        } else if (hexColor.length == 8) {
          return Color(int.parse(hexColor, radix: 16));
        }
      }
    } catch (e) {
      // Fallback to grey if parsing fails
      return Colors.grey;
    }
    return Colors.grey;
  }
}
