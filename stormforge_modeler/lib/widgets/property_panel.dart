import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stormforge_modeler/canvas/canvas_controller.dart';
import 'package:stormforge_modeler/models/models.dart';

/// The property panel widget for editing selected elements.
class PropertyPanel extends ConsumerWidget {
  /// Creates a property panel.
  const PropertyPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final canvasModel = ref.watch(canvasModelProvider);
    final selectedElement = canvasModel.selectedElement;

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
                bottom: BorderSide(
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
            ),
            child: Text(
              'Properties',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Content
          Expanded(
            child: selectedElement != null
                ? _ElementProperties(element: selectedElement)
                : const _NoSelectionPlaceholder(),
          ),
        ],
      ),
    );
  }
}

/// Properties editor for a selected element.
class _ElementProperties extends ConsumerStatefulWidget {
  const _ElementProperties({required this.element});

  final CanvasElement element;

  @override
  ConsumerState<_ElementProperties> createState() => _ElementPropertiesState();
}

class _ElementPropertiesState extends ConsumerState<_ElementProperties> {
  late TextEditingController _labelController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.element.label);
    _descriptionController =
        TextEditingController(text: widget.element.description);
  }

  @override
  void didUpdateWidget(covariant _ElementProperties oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controllers when element changes or when same element's properties change externally
    if (oldWidget.element.id != widget.element.id ||
        (oldWidget.element.label != widget.element.label &&
            _labelController.text != widget.element.label) ||
        (oldWidget.element.description != widget.element.description &&
            _descriptionController.text != widget.element.description)) {
      _labelController.text = widget.element.label;
      _descriptionController.text = widget.element.description;
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final element = widget.element;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Element type indicator
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: element.type.backgroundColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: element.type.backgroundColor,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: element.type.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  element.type.icon,
                  color: element.type.textColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      element.type.displayName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      element.type.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Label field
        _PropertyField(
          label: 'Label',
          child: TextField(
            controller: _labelController,
            decoration: const InputDecoration(
              hintText: 'Enter label...',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              ref.read(canvasModelProvider.notifier).updateElementLabel(
                    element.id,
                    value,
                  );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Description field
        _PropertyField(
          label: 'Description',
          child: TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              hintText: 'Enter description...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            onChanged: (value) {
              ref.read(canvasModelProvider.notifier).updateElementDescription(
                    element.id,
                    value,
                  );
            },
          ),
        ),

        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),

        // Position info
        _PropertyField(
          label: 'Position',
          child: Row(
            children: [
              Expanded(
                child: _ReadOnlyField(
                  label: 'X',
                  value: element.position.dx.toStringAsFixed(0),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ReadOnlyField(
                  label: 'Y',
                  value: element.position.dy.toStringAsFixed(0),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Size info
        _PropertyField(
          label: 'Size',
          child: Row(
            children: [
              Expanded(
                child: _ReadOnlyField(
                  label: 'W',
                  value: element.size.width.toStringAsFixed(0),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ReadOnlyField(
                  label: 'H',
                  value: element.size.height.toStringAsFixed(0),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),

        // ID (for debugging)
        _PropertyField(
          label: 'ID',
          child: SelectableText(
            element.id,
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: 'RobotoMono',
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Delete button
        ElevatedButton.icon(
          onPressed: () {
            ref.read(canvasModelProvider.notifier).removeElement(element.id);
          },
          icon: const Icon(Icons.delete),
          label: const Text('Delete Element'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.errorContainer,
            foregroundColor: theme.colorScheme.onErrorContainer,
          ),
        ),
      ],
    );
  }
}

/// A property field with a label.
class _PropertyField extends StatelessWidget {
  const _PropertyField({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}

/// A read-only field for displaying values.
class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Text(
            '$label:',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// Placeholder shown when no element is selected.
class _NoSelectionPlaceholder extends StatelessWidget {
  const _NoSelectionPlaceholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.touch_app_outlined,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No element selected',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Click on an element to edit its properties',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
