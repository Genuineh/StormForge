import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stormforge_modeler/canvas/canvas_controller.dart';
import 'package:stormforge_modeler/models/models.dart';
import 'package:stormforge_modeler/services/providers.dart';
import 'package:stormforge_modeler/widgets/dialogs/entity_selection_dialog.dart';
import 'package:stormforge_modeler/widgets/dialogs/command_definition_selection_dialog.dart';
import 'package:stormforge_modeler/widgets/dialogs/read_model_definition_selection_dialog.dart';

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
                bottom: BorderSide(color: theme.colorScheme.outlineVariant),
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
    _descriptionController = TextEditingController(
      text: widget.element.description,
    );
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
            border: Border.all(color: element.type.backgroundColor),
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
                child: Icon(element.type.icon, color: element.type.textColor),
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
              ref
                  .read(canvasModelProvider.notifier)
                  .updateElementLabel(element.id, value);
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
              ref
                  .read(canvasModelProvider.notifier)
                  .updateElementDescription(element.id, value);
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

        // Linked definitions section
        if (element.entityId != null ||
            element.commandDefinitionId != null ||
            element.readModelDefinitionId != null ||
            element.libraryComponentId != null)
          ...[
            _PropertyField(
              label: 'Linked Definitions',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (element.entityId != null)
                    _LinkedDefinitionCard(
                      icon: Icons.account_tree,
                      title: 'Entity',
                      subtitle: 'Linked to entity definition',
                      onTap: () {
                        // TODO: Navigate to entity editor
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Entity editor will open here'),
                          ),
                        );
                      },
                      onUnlink: () {
                        ref
                            .read(canvasModelProvider.notifier)
                            .unlinkEntity(element.id);
                      },
                    ),
                  if (element.commandDefinitionId != null) ...[
                    if (element.entityId != null) const SizedBox(height: 8),
                    _LinkedDefinitionCard(
                      icon: Icons.play_arrow,
                      title: 'Command Definition',
                      subtitle: 'Linked to command data model',
                      onTap: () {
                        // TODO: Navigate to command editor
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Command editor will open here'),
                          ),
                        );
                      },
                      onUnlink: () {
                        ref
                            .read(canvasModelProvider.notifier)
                            .unlinkCommandDefinition(element.id);
                      },
                    ),
                  ],
                  if (element.readModelDefinitionId != null) ...[
                    if (element.entityId != null ||
                        element.commandDefinitionId != null)
                      const SizedBox(height: 8),
                    _LinkedDefinitionCard(
                      icon: Icons.visibility,
                      title: 'Read Model Definition',
                      subtitle: 'Linked to read model fields',
                      onTap: () {
                        // TODO: Navigate to read model editor
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Read model editor will open here'),
                          ),
                        );
                      },
                      onUnlink: () {
                        ref
                            .read(canvasModelProvider.notifier)
                            .unlinkReadModelDefinition(element.id);
                      },
                    ),
                  ],
                  if (element.libraryComponentId != null) ...[
                    if (element.entityId != null ||
                        element.commandDefinitionId != null ||
                        element.readModelDefinitionId != null)
                      const SizedBox(height: 8),
                    _LinkedDefinitionCard(
                      icon: Icons.library_books,
                      title: 'Library Component',
                      subtitle: 'Imported from global library',
                      onTap: () {
                        // TODO: Show library component details
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Library component details will show here'),
                          ),
                        );
                      },
                      onUnlink: () {
                        ref
                            .read(canvasModelProvider.notifier)
                            .unlinkLibraryComponent(element.id);
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
          ],

        // Link actions
        if (element.type == ElementType.aggregate && element.entityId == null)
          ...[
            ElevatedButton.icon(
              onPressed: () async {
                final entityService = ref.read(entityServiceProvider);
                // TODO: Get actual project ID from context/state
                const projectId = 'current-project-id';
                
                final entity = await showDialog<EntityDefinition>(
                  context: context,
                  builder: (context) => EntitySelectionDialog(
                    projectId: projectId,
                    entityService: entityService,
                  ),
                );
                
                if (entity != null) {
                  ref
                      .read(canvasModelProvider.notifier)
                      .linkEntity(element.id, entity.id);
                }
              },
              icon: const Icon(Icons.link),
              label: const Text('Link to Entity'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),
          ],
        if (element.type == ElementType.command &&
            element.commandDefinitionId == null)
          ...[
            ElevatedButton.icon(
              onPressed: () async {
                final commandService = ref.read(commandServiceProvider);
                // TODO: Get actual project ID from context/state
                const projectId = 'current-project-id';
                
                final command = await showDialog<CommandDefinition>(
                  context: context,
                  builder: (context) => CommandDefinitionSelectionDialog(
                    projectId: projectId,
                    commandService: commandService,
                  ),
                );
                
                if (command != null) {
                  ref
                      .read(canvasModelProvider.notifier)
                      .linkCommandDefinition(element.id, command.id);
                }
              },
              icon: const Icon(Icons.link),
              label: const Text('Link to Command Definition'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),
          ],
        if (element.type == ElementType.readModel &&
            element.readModelDefinitionId == null)
          ...[
            ElevatedButton.icon(
              onPressed: () async {
                final readModelService = ref.read(readModelServiceProvider);
                // TODO: Get actual project ID from context/state
                const projectId = 'current-project-id';
                
                final readModel = await showDialog<ReadModelDefinition>(
                  context: context,
                  builder: (context) => ReadModelDefinitionSelectionDialog(
                    projectId: projectId,
                    readModelService: readModelService,
                  ),
                );
                
                if (readModel != null) {
                  ref
                      .read(canvasModelProvider.notifier)
                      .linkReadModelDefinition(element.id, readModel.id);
                }
              },
              icon: const Icon(Icons.link),
              label: const Text('Link to Read Model Definition'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ElevatedButton.icon(
          onPressed: () {
            // TODO: Show library browser
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Library browser will open here'),
              ),
            );
          },
          icon: const Icon(Icons.library_add),
          label: const Text('Import from Library'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.secondaryContainer,
            foregroundColor: theme.colorScheme.onSecondaryContainer,
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
  const _PropertyField({required this.label, required this.child});

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
  const _ReadOnlyField({required this.label, required this.value});

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
        border: Border.all(color: theme.colorScheme.outlineVariant),
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
          Text(value, style: theme.textTheme.bodySmall),
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

/// Card showing a linked definition with edit and unlink actions.
class _LinkedDefinitionCard extends StatelessWidget {
  const _LinkedDefinitionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.onUnlink,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback onUnlink;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.link_off, size: 20),
                tooltip: 'Unlink',
                onPressed: onUnlink,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
