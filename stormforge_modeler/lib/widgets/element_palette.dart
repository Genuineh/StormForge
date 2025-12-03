import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stormforge_modeler/canvas/canvas_controller.dart';
import 'package:stormforge_modeler/models/models.dart';

/// The element palette widget for dragging elements onto the canvas.
class ElementPalette extends ConsumerWidget {
  /// Creates an element palette.
  const ElementPalette({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surfaceContainerLowest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
            ),
            child: Text(
              'Elements',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Element list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                const _PaletteSectionHeader(title: 'EventStorming'),
                for (final type in ElementType.values) _PaletteItem(type: type),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Section header in the palette.
class _PaletteSectionHeader extends StatelessWidget {
  const _PaletteSectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

/// A draggable element item in the palette.
class _PaletteItem extends ConsumerWidget {
  const _PaletteItem({required this.type});

  final ElementType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Draggable<ElementType>(
        data: type,
        onDragStarted: () {
          ref.read(draggedElementTypeProvider.notifier).state = type;
        },
        onDragEnd: (details) {
          ref.read(draggedElementTypeProvider.notifier).state = null;
        },
        feedback: _PaletteItemFeedback(type: type),
        childWhenDragging: Opacity(
          opacity: 0.5,
          child: _PaletteItemContent(type: type),
        ),
        child: _PaletteItemContent(type: type),
      ),
    );
  }
}

/// The content of a palette item.
class _PaletteItemContent extends StatelessWidget {
  const _PaletteItemContent({required this.type});

  final ElementType type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          // Could show info about this element type
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Color indicator
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: type.backgroundColor,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.black.withOpacity(0.1)),
                ),
                child: Icon(type.icon, size: 18, color: type.textColor),
              ),
              const SizedBox(width: 12),
              // Name and description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.displayName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      type.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Drag handle
              Icon(
                Icons.drag_indicator,
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The feedback widget shown while dragging.
class _PaletteItemFeedback extends StatelessWidget {
  const _PaletteItemFeedback({required this.type});

  final ElementType type;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 150,
        height: 100,
        decoration: BoxDecoration(
          color: type.backgroundColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              type.displayName,
              style: TextStyle(
                color: type.textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              type.displayName.toUpperCase(),
              style: TextStyle(
                color: type.textColor.withOpacity(0.6),
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
