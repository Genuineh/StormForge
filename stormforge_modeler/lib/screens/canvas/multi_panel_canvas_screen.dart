import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stormforge_modeler/canvas/canvas_widget.dart';
import 'package:stormforge_modeler/widgets/project_tree.dart';
import 'package:stormforge_modeler/widgets/property_panel.dart';
import 'package:stormforge_modeler/widgets/toolbar.dart';

/// Provider for the left panel visibility.
final leftPanelVisibleProvider = StateProvider<bool>((ref) => true);

/// Provider for the right panel visibility.
final rightPanelVisibleProvider = StateProvider<bool>((ref) => true);

/// Provider for the left panel width.
final leftPanelWidthProvider = StateProvider<double>((ref) => 280.0);

/// Provider for the right panel width.
final rightPanelWidthProvider = StateProvider<double>((ref) => 320.0);

/// A multi-panel layout screen combining project tree, canvas, and properties.
class MultiPanelCanvasScreen extends ConsumerWidget {
  /// Creates a multi-panel canvas screen.
  const MultiPanelCanvasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leftPanelVisible = ref.watch(leftPanelVisibleProvider);
    final rightPanelVisible = ref.watch(rightPanelVisibleProvider);
    final leftPanelWidth = ref.watch(leftPanelWidthProvider);
    final rightPanelWidth = ref.watch(rightPanelWidthProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('StormForge Modeler'),
        actions: [
          // Toggle left panel
          IconButton(
            icon: Icon(leftPanelVisible ? Icons.menu_open : Icons.menu),
            tooltip: leftPanelVisible ? 'Hide Project Tree' : 'Show Project Tree',
            onPressed: () {
              ref.read(leftPanelVisibleProvider.notifier).state =
                  !leftPanelVisible;
            },
          ),
          // Toggle right panel
          IconButton(
            icon: Icon(rightPanelVisible ? Icons.info : Icons.info_outline),
            tooltip:
                rightPanelVisible ? 'Hide Properties' : 'Show Properties',
            onPressed: () {
              ref.read(rightPanelVisibleProvider.notifier).state =
                  !rightPanelVisible;
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Toolbar
          const ModelerToolbar(),
          // Main content with panels
          Expanded(
            child: Row(
              children: [
                // Left panel - Project Tree
                if (leftPanelVisible) ...[
                  SizedBox(
                    width: leftPanelWidth,
                    child: const ProjectTree(),
                  ),
                  _ResizableHandle(
                    onDrag: (delta) {
                      final newWidth = (leftPanelWidth + delta).clamp(200.0, 500.0);
                      ref.read(leftPanelWidthProvider.notifier).state = newWidth;
                    },
                  ),
                ],

                // Center panel - Canvas
                Expanded(
                  child: Container(
                    color: Theme.of(context).colorScheme.surface,
                    child: const EventStormingCanvas(),
                  ),
                ),

                // Right panel - Properties
                if (rightPanelVisible) ...[
                  _ResizableHandle(
                    onDrag: (delta) {
                      final newWidth = (rightPanelWidth - delta).clamp(280.0, 600.0);
                      ref.read(rightPanelWidthProvider.notifier).state = newWidth;
                    },
                  ),
                  SizedBox(
                    width: rightPanelWidth,
                    child: const PropertyPanel(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A draggable handle for resizing panels.
class _ResizableHandle extends StatefulWidget {
  const _ResizableHandle({required this.onDrag});

  final void Function(double delta) onDrag;

  @override
  State<_ResizableHandle> createState() => _ResizableHandleState();
}

class _ResizableHandleState extends State<_ResizableHandle> {
  bool _isDragging = false;
  double? _dragStartX;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      onEnter: (_) => setState(() {}),
      onExit: (_) => setState(() {}),
      child: GestureDetector(
        onHorizontalDragStart: (details) {
          setState(() {
            _isDragging = true;
            _dragStartX = details.globalPosition.dx;
          });
        },
        onHorizontalDragUpdate: (details) {
          if (_dragStartX != null) {
            final delta = details.globalPosition.dx - _dragStartX!;
            _dragStartX = details.globalPosition.dx;
            widget.onDrag(delta);
          }
        },
        onHorizontalDragEnd: (_) {
          setState(() {
            _isDragging = false;
            _dragStartX = null;
          });
        },
        child: Container(
          width: 8,
          decoration: BoxDecoration(
            color: _isDragging
                ? theme.colorScheme.primary.withOpacity(0.3)
                : theme.colorScheme.surfaceContainerHighest,
            border: Border(
              left: BorderSide(
                color: theme.colorScheme.outlineVariant,
                width: 1,
              ),
              right: BorderSide(
                color: theme.colorScheme.outlineVariant,
                width: 1,
              ),
            ),
          ),
          child: Center(
            child: Container(
              width: 2,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
