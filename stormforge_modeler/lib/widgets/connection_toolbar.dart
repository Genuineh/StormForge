import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stormforge_modeler/models/connection_model.dart';
import 'package:stormforge_modeler/canvas/canvas_controller.dart';

/// Toolbar for selecting connection types.
class ConnectionToolbar extends ConsumerWidget {
  /// Creates a connection toolbar.
  const ConnectionToolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasMode = ref.watch(canvasModeProvider);
    final pendingConnectionType = ref.watch(pendingConnectionTypeProvider);

    return Card(
      elevation: 4,
      child: Container(
        width: 60,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.cable,
                size: 24,
                color: canvasMode == CanvasMode.connect
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              ),
            ),
            const Divider(height: 8),

            // Connection type buttons
            ...ConnectionType.values.map((type) {
              final isActive = canvasMode == CanvasMode.connect &&
                  pendingConnectionType == type;

              return Tooltip(
                message: '${type.displayName}\n${type.description}',
                preferBelow: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: InkWell(
                    onTap: () => _onConnectionTypeSelected(ref, type),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isActive
                            ? Theme.of(context).primaryColor.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isActive
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        type.icon,
                        color: _parseColor(type.defaultStyle.color),
                        size: 24,
                      ),
                    ),
                  ),
                ),
              );
            }),

            const Divider(height: 8),

            // Exit connection mode button
            if (canvasMode == CanvasMode.connect)
              Tooltip(
                message: 'Exit Connection Mode (Esc)',
                preferBelow: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: InkWell(
                    onTap: () => _exitConnectionMode(ref),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.red,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Handles connection type selection.
  void _onConnectionTypeSelected(WidgetRef ref, ConnectionType type) {
    // Enter connection mode with the selected type
    ref.read(canvasModeProvider.notifier).state = CanvasMode.connect;
    ref.read(pendingConnectionTypeProvider.notifier).state = type;
    ref.read(connectionSourceProvider.notifier).state = null; // Reset source
  }

  /// Exits connection mode.
  void _exitConnectionMode(WidgetRef ref) {
    ref.read(canvasModeProvider.notifier).state = CanvasMode.select;
    ref.read(pendingConnectionTypeProvider.notifier).state = null;
    ref.read(connectionSourceProvider.notifier).state = null;
  }

  /// Parses a color string to a Color object.
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
      return Colors.grey;
    }
    return Colors.grey;
  }
}
