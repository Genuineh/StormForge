# Component Connection System Design

> Design specification for the visual connection system between EventStorming components
> Version: 1.0
> Date: 2025-12-03

---

## Overview

The Component Connection System enables visual relationships between EventStorming elements on the canvas, making the flow of commands, events, and data explicit and traceable.

## Connection Types

### 1. Command → Aggregate
**Purpose**: Shows which aggregate handles a command
**Visual**: Blue dashed line with arrow
**Validation**: Source must be Command, target must be Aggregate

### 2. Aggregate → Event
**Purpose**: Shows which events an aggregate produces
**Visual**: Orange solid line with arrow
**Validation**: Source must be Aggregate, target must be Domain Event

### 3. Event → Policy
**Purpose**: Shows which policies react to an event
**Visual**: Purple solid line with arrow
**Validation**: Source must be Domain Event, target must be Policy

### 4. Policy → Command
**Purpose**: Shows which command a policy triggers
**Visual**: Blue dashed line with arrow
**Validation**: Source must be Policy, target must be Command

### 5. Event → Read Model
**Purpose**: Shows which read models are updated by an event
**Visual**: Green solid line with arrow
**Validation**: Source must be Domain Event, target must be Read Model

### 6. External System → Command
**Purpose**: Shows external systems that trigger commands
**Visual**: Pink dashed line with arrow
**Validation**: Source must be External System, target must be Command

### 7. UI → Command
**Purpose**: Shows UI elements that trigger commands
**Visual**: Light blue dashed line with arrow
**Validation**: Source must be UI, target must be Command

### 8. Read Model → UI
**Purpose**: Shows UI elements that display read models
**Visual**: Green dashed line with arrow
**Validation**: Source must be Read Model, target must be UI

## Data Model

```dart
enum ConnectionType {
  commandToAggregate('Command → Aggregate', 'Aggregate handles command'),
  aggregateToEvent('Aggregate → Event', 'Aggregate produces event'),
  eventToPolicy('Event → Policy', 'Policy reacts to event'),
  policyToCommand('Policy → Command', 'Policy triggers command'),
  eventToReadModel('Event → Read Model', 'Event updates read model'),
  externalToCommand('External → Command', 'External system triggers command'),
  uiToCommand('UI → Command', 'UI triggers command'),
  readModelToUI('Read Model → UI', 'UI displays read model'),
  custom('Custom', 'Custom relationship');
  
  const ConnectionType(this.displayName, this.description);
  final String displayName;
  final String description;
  
  ConnectionStyle get defaultStyle {
    switch (this) {
      case commandToAggregate:
      case policyToCommand:
      case externalToCommand:
      case uiToCommand:
        return ConnectionStyle(
          color: Colors.blue,
          strokeWidth: 2.0,
          lineStyle: LineStyle.dashed,
          arrowStyle: ArrowStyle.filled,
        );
      case aggregateToEvent:
        return ConnectionStyle(
          color: Colors.orange,
          strokeWidth: 2.0,
          lineStyle: LineStyle.solid,
          arrowStyle: ArrowStyle.filled,
        );
      case eventToPolicy:
        return ConnectionStyle(
          color: Colors.purple,
          strokeWidth: 2.0,
          lineStyle: LineStyle.solid,
          arrowStyle: ArrowStyle.filled,
        );
      case eventToReadModel:
      case readModelToUI:
        return ConnectionStyle(
          color: Colors.green,
          strokeWidth: 2.0,
          lineStyle: LineStyle.solid,
          arrowStyle: ArrowStyle.filled,
        );
      case custom:
        return ConnectionStyle(
          color: Colors.grey,
          strokeWidth: 2.0,
          lineStyle: LineStyle.solid,
          arrowStyle: ArrowStyle.open,
        );
    }
  }
}

class ConnectionElement extends Equatable {
  final String id;
  final String sourceId;
  final String targetId;
  final ConnectionType type;
  final String label;
  final ConnectionStyle style;
  final Map<String, dynamic> metadata;
  final bool isSelected;
  
  const ConnectionElement({
    required this.id,
    required this.sourceId,
    required this.targetId,
    required this.type,
    this.label = '',
    ConnectionStyle? style,
    this.metadata = const {},
    this.isSelected = false,
  }) : style = style ?? type.defaultStyle;
  
  bool isValid(CanvasElement source, CanvasElement target) {
    switch (type) {
      case ConnectionType.commandToAggregate:
        return source.type == ElementType.command &&
               target.type == ElementType.aggregate;
      case ConnectionType.aggregateToEvent:
        return source.type == ElementType.aggregate &&
               target.type == ElementType.domainEvent;
      case ConnectionType.eventToPolicy:
        return source.type == ElementType.domainEvent &&
               target.type == ElementType.policy;
      case ConnectionType.policyToCommand:
        return source.type == ElementType.policy &&
               target.type == ElementType.command;
      case ConnectionType.eventToReadModel:
        return source.type == ElementType.domainEvent &&
               target.type == ElementType.readModel;
      case ConnectionType.externalToCommand:
        return source.type == ElementType.externalSystem &&
               target.type == ElementType.command;
      case ConnectionType.uiToCommand:
        return source.type == ElementType.ui &&
               target.type == ElementType.command;
      case ConnectionType.readModelToUI:
        return source.type == ElementType.readModel &&
               target.type == ElementType.ui;
      case ConnectionType.custom:
        return true;
    }
  }
  
  @override
  List<Object?> get props => [
    id, sourceId, targetId, type,
    label, style, metadata, isSelected,
  ];
}

enum LineStyle {
  solid,
  dashed,
  dotted,
}

enum ArrowStyle {
  filled,
  open,
  none,
}

class ConnectionStyle extends Equatable {
  final Color color;
  final double strokeWidth;
  final LineStyle lineStyle;
  final ArrowStyle arrowStyle;
  
  const ConnectionStyle({
    required this.color,
    required this.strokeWidth,
    required this.lineStyle,
    required this.arrowStyle,
  });
  
  @override
  List<Object?> get props => [color, strokeWidth, lineStyle, arrowStyle];
}
```

## UI Implementation

### Connection Mode

```dart
enum CanvasMode {
  select,      // Default - select and move elements
  connect,     // Connection mode - create connections
  pan,         // Pan mode - move viewport
}

class CanvasController extends ChangeNotifier {
  CanvasMode _mode = CanvasMode.select;
  String? _connectionSourceId;
  ConnectionType? _pendingConnectionType;
  
  void enterConnectionMode(ConnectionType type) {
    _mode = CanvasMode.connect;
    _pendingConnectionType = type;
    notifyListeners();
  }
  
  void exitConnectionMode() {
    _mode = CanvasMode.select;
    _connectionSourceId = null;
    _pendingConnectionType = null;
    notifyListeners();
  }
  
  void onElementClick(String elementId, CanvasElement element) {
    if (_mode == CanvasMode.connect) {
      if (_connectionSourceId == null) {
        // First click - set source
        _connectionSourceId = elementId;
        notifyListeners();
      } else {
        // Second click - create connection
        _createConnection(elementId, element);
      }
    }
  }
  
  void _createConnection(String targetId, CanvasElement target) {
    if (_connectionSourceId == null || _pendingConnectionType == null) return;
    
    final source = getElementById(_connectionSourceId!);
    if (source == null) return;
    
    final connection = ConnectionElement(
      id: Uuid().v4(),
      sourceId: _connectionSourceId!,
      targetId: targetId,
      type: _pendingConnectionType!,
    );
    
    // Validate
    if (!connection.isValid(source, target)) {
      _showError('Invalid connection: ${connection.type.displayName} '
                 'requires ${_getExpectedTypes(connection.type)}');
      exitConnectionMode();
      return;
    }
    
    // Add connection
    addConnection(connection);
    exitConnectionMode();
  }
  
  String _getExpectedTypes(ConnectionType type) {
    switch (type) {
      case ConnectionType.commandToAggregate:
        return 'Command → Aggregate';
      // ... other cases
    }
  }
}
```

### Connection Rendering

```dart
class ConnectionPainter extends CustomPainter {
  final List<ConnectionElement> connections;
  final Map<String, CanvasElement> elements;
  final CanvasViewport viewport;
  
  ConnectionPainter({
    required this.connections,
    required this.elements,
    required this.viewport,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    for (final connection in connections) {
      final source = elements[connection.sourceId];
      final target = elements[connection.targetId];
      
      if (source == null || target == null) continue;
      
      _paintConnection(canvas, connection, source, target);
    }
  }
  
  void _paintConnection(
    Canvas canvas,
    ConnectionElement connection,
    CanvasElement source,
    CanvasElement target,
  ) {
    // Calculate start and end points
    final startPoint = _getConnectionPoint(source, target);
    final endPoint = _getConnectionPoint(target, source);
    
    // Convert to screen coordinates
    final screenStart = viewport.canvasToScreen(startPoint);
    final screenEnd = viewport.canvasToScreen(endPoint);
    
    // Create paint
    final paint = Paint()
      ..color = connection.style.color
      ..strokeWidth = connection.style.strokeWidth
      ..style = PaintingStyle.stroke;
    
    // Apply line style
    if (connection.style.lineStyle == LineStyle.dashed) {
      paint.shader = _createDashedShader();
    }
    
    // Draw line (use orthogonal routing or bezier curves)
    final path = _createConnectionPath(screenStart, screenEnd);
    canvas.drawPath(path, paint);
    
    // Draw arrow
    _drawArrow(canvas, screenEnd, screenStart, connection.style);
    
    // Draw label if present
    if (connection.label.isNotEmpty) {
      _drawLabel(canvas, path, connection.label);
    }
  }
  
  Offset _getConnectionPoint(CanvasElement from, CanvasElement to) {
    // Get edge point closest to target
    final fromCenter = from.bounds.center;
    final toCenter = to.bounds.center;
    
    // Calculate which edge of 'from' is closest to 'to'
    final dx = toCenter.dx - fromCenter.dx;
    final dy = toCenter.dy - fromCenter.dy;
    
    if (dx.abs() > dy.abs()) {
      // Horizontal - use left or right edge
      return Offset(
        dx > 0 ? from.bounds.right : from.bounds.left,
        fromCenter.dy,
      );
    } else {
      // Vertical - use top or bottom edge
      return Offset(
        fromCenter.dx,
        dy > 0 ? from.bounds.bottom : from.bounds.top,
      );
    }
  }
  
  Path _createConnectionPath(Offset start, Offset end) {
    // Use orthogonal (Manhattan) routing for cleaner diagrams
    final path = Path();
    path.moveTo(start.dx, start.dy);
    
    final midX = (start.dx + end.dx) / 2;
    
    // Orthogonal path with one bend
    path.lineTo(midX, start.dy);
    path.lineTo(midX, end.dy);
    path.lineTo(end.dx, end.dy);
    
    return path;
  }
  
  void _drawArrow(Canvas canvas, Offset tip, Offset from, ConnectionStyle style) {
    if (style.arrowStyle == ArrowStyle.none) return;
    
    final angle = atan2(tip.dy - from.dy, tip.dx - from.dx);
    final arrowSize = 10.0;
    
    final path = Path();
    path.moveTo(tip.dx, tip.dy);
    path.lineTo(
      tip.dx - arrowSize * cos(angle - pi / 6),
      tip.dy - arrowSize * sin(angle - pi / 6),
    );
    path.lineTo(
      tip.dx - arrowSize * cos(angle + pi / 6),
      tip.dy - arrowSize * sin(angle + pi / 6),
    );
    path.close();
    
    final paint = Paint()
      ..color = style.color
      ..style = style.arrowStyle == ArrowStyle.filled
          ? PaintingStyle.fill
          : PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    canvas.drawPath(path, paint);
  }
  
  void _drawLabel(Canvas canvas, Path path, String label) {
    // Find midpoint of path
    final metrics = path.computeMetrics().first;
    final midPoint = metrics.getTangentForOffset(metrics.length / 2)!.position;
    
    // Draw label background
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(color: Colors.black, fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    
    final labelRect = Rect.fromCenter(
      center: midPoint,
      width: textPainter.width + 8,
      height: textPainter.height + 4,
    );
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(labelRect, Radius.circular(4)),
      Paint()..color = Colors.white.withOpacity(0.9),
    );
    
    textPainter.paint(
      canvas,
      Offset(
        midPoint.dx - textPainter.width / 2,
        midPoint.dy - textPainter.height / 2,
      ),
    );
  }
  
  @override
  bool shouldRepaint(ConnectionPainter oldDelegate) {
    return connections != oldDelegate.connections ||
           elements != oldDelegate.elements ||
           viewport != oldDelegate.viewport;
  }
}
```

## Toolbar Integration

```dart
class ConnectionToolbar extends StatelessWidget {
  final CanvasController controller;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Connections', style: Theme.of(context).textTheme.titleSmall),
            SizedBox(height: 8),
            ...ConnectionType.values.map((type) {
              return Tooltip(
                message: type.description,
                child: IconButton(
                  icon: Icon(_getConnectionIcon(type)),
                  color: type.defaultStyle.color,
                  onPressed: () => controller.enterConnectionMode(type),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
  
  IconData _getConnectionIcon(ConnectionType type) {
    switch (type) {
      case ConnectionType.commandToAggregate:
      case ConnectionType.policyToCommand:
      case ConnectionType.externalToCommand:
      case ConnectionType.uiToCommand:
        return Icons.arrow_forward;
      case ConnectionType.aggregateToEvent:
      case ConnectionType.eventToPolicy:
      case ConnectionType.eventToReadModel:
      case ConnectionType.readModelToUI:
        return Icons.arrow_forward;
      case ConnectionType.custom:
        return Icons.more_horiz;
    }
  }
}
```

## Context Menu

```dart
class ConnectionContextMenu extends StatelessWidget {
  final ConnectionElement connection;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Edit Connection'),
            onTap: onEdit,
          ),
          ListTile(
            leading: Icon(Icons.label),
            title: Text('Edit Label'),
            onTap: () {
              // Show label editor dialog
            },
          ),
          ListTile(
            leading: Icon(Icons.style),
            title: Text('Change Style'),
            onTap: () {
              // Show style editor dialog
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: Text('Delete', style: TextStyle(color: Colors.red)),
            onTap: onDelete,
          ),
        ],
      ),
    );
  }
}
```

## Properties Panel

```dart
class ConnectionPropertiesPanel extends StatelessWidget {
  final ConnectionElement connection;
  final ValueChanged<ConnectionElement> onUpdate;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Connection Properties', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 16),
            
            // Type (read-only)
            TextField(
              decoration: InputDecoration(labelText: 'Type'),
              readOnly: true,
              controller: TextEditingController(text: connection.type.displayName),
            ),
            SizedBox(height: 12),
            
            // Label
            TextField(
              decoration: InputDecoration(labelText: 'Label'),
              controller: TextEditingController(text: connection.label),
              onChanged: (value) {
                onUpdate(connection.copyWith(label: value));
              },
            ),
            SizedBox(height: 12),
            
            // Style
            Text('Style', style: Theme.of(context).textTheme.titleSmall),
            SizedBox(height: 8),
            
            // Color picker
            ColorPicker(
              color: connection.style.color,
              onColorChanged: (color) {
                onUpdate(connection.copyWith(
                  style: connection.style.copyWith(color: color),
                ));
              },
            ),
            
            // Line style
            DropdownButton<LineStyle>(
              value: connection.style.lineStyle,
              items: LineStyle.values.map((style) {
                return DropdownMenuItem(
                  value: style,
                  child: Text(style.name),
                );
              }).toList(),
              onChanged: (style) {
                if (style != null) {
                  onUpdate(connection.copyWith(
                    style: connection.style.copyWith(lineStyle: style),
                  ));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

## Validation

```dart
class ConnectionValidator {
  static ValidationResult validate(
    ConnectionElement connection,
    CanvasElement source,
    CanvasElement target,
  ) {
    final errors = <String>[];
    
    // Check if connection type matches element types
    if (!connection.isValid(source, target)) {
      errors.add(
        'Invalid connection: ${connection.type.displayName} '
        'cannot connect ${source.type.displayName} to ${target.type.displayName}',
      );
    }
    
    // Check for circular dependencies
    if (_hasCircularDependency(connection, source, target)) {
      errors.add('Circular dependency detected');
    }
    
    // Check for duplicate connections
    if (_hasDuplicateConnection(connection)) {
      errors.add('Connection already exists between these elements');
    }
    
    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
  
  static bool _hasCircularDependency(
    ConnectionElement newConnection,
    CanvasElement source,
    CanvasElement target,
  ) {
    // TODO: Implement cycle detection
    return false;
  }
  
  static bool _hasDuplicateConnection(ConnectionElement connection) {
    // TODO: Check for existing connections
    return false;
  }
}

class ValidationResult {
  final bool isValid;
  final List<String> errors;
  
  const ValidationResult({
    required this.isValid,
    required this.errors,
  });
}
```

---

## Testing

### Unit Tests
- Connection type validation
- Connection path calculation
- Arrow rendering
- Label positioning

### Integration Tests
- Creating connections in UI
- Editing connection properties
- Deleting connections
- Connection mode interaction

---

*This design will be refined during implementation.*
