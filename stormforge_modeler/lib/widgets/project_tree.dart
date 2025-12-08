import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stormforge_modeler/canvas/canvas_controller.dart';
import 'package:stormforge_modeler/models/models.dart';

/// A tree widget showing project structure with entities, commands, read models, etc.
class ProjectTree extends ConsumerWidget {
  /// Creates a project tree widget.
  const ProjectTree({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final canvasModel = ref.watch(canvasModelProvider);

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
            child: Row(
              children: [
                Icon(
                  Icons.account_tree,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Project Explorer',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Tree content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                _TreeSection(
                  title: 'Entities',
                  icon: Icons.account_tree,
                  items: _getEntityItems(canvasModel),
                  onItemTap: (id) {
                    ref.read(canvasModelProvider.notifier).selectElement(id);
                  },
                ),
                const SizedBox(height: 8),
                _TreeSection(
                  title: 'Aggregates',
                  icon: Icons.account_tree,
                  items: _getAggregateItems(canvasModel),
                  onItemTap: (id) {
                    ref.read(canvasModelProvider.notifier).selectElement(id);
                  },
                ),
                const SizedBox(height: 8),
                _TreeSection(
                  title: 'Commands',
                  icon: Icons.play_arrow,
                  items: _getCommandItems(canvasModel),
                  onItemTap: (id) {
                    ref.read(canvasModelProvider.notifier).selectElement(id);
                  },
                ),
                const SizedBox(height: 8),
                _TreeSection(
                  title: 'Events',
                  icon: Icons.event_note,
                  items: _getEventItems(canvasModel),
                  onItemTap: (id) {
                    ref.read(canvasModelProvider.notifier).selectElement(id);
                  },
                ),
                const SizedBox(height: 8),
                _TreeSection(
                  title: 'Read Models',
                  icon: Icons.visibility,
                  items: _getReadModelItems(canvasModel),
                  onItemTap: (id) {
                    ref.read(canvasModelProvider.notifier).selectElement(id);
                  },
                ),
                const SizedBox(height: 8),
                _TreeSection(
                  title: 'Policies',
                  icon: Icons.policy,
                  items: _getPolicyItems(canvasModel),
                  onItemTap: (id) {
                    ref.read(canvasModelProvider.notifier).selectElement(id);
                  },
                ),
                const SizedBox(height: 8),
                _TreeSection(
                  title: 'External Systems',
                  icon: Icons.cloud,
                  items: _getExternalSystemItems(canvasModel),
                  onItemTap: (id) {
                    ref.read(canvasModelProvider.notifier).selectElement(id);
                  },
                ),
                const SizedBox(height: 8),
                _TreeSection(
                  title: 'UI',
                  icon: Icons.web,
                  items: _getUIItems(canvasModel),
                  onItemTap: (id) {
                    ref.read(canvasModelProvider.notifier).selectElement(id);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<_TreeItem> _getEntityItems(CanvasModel model) {
    // TODO: Get entities from entity service
    // For now, return empty list
    return [];
  }

  List<_TreeItem> _getAggregateItems(CanvasModel model) {
    return model.elements
        .where((e) => e.type == ElementType.aggregate)
        .map((e) => _TreeItem(
              id: e.id,
              label: e.label,
              hasLink: e.entityId != null,
            ))
        .toList();
  }

  List<_TreeItem> _getCommandItems(CanvasModel model) {
    return model.elements
        .where((e) => e.type == ElementType.command)
        .map((e) => _TreeItem(
              id: e.id,
              label: e.label,
              hasLink: e.commandDefinitionId != null,
            ))
        .toList();
  }

  List<_TreeItem> _getEventItems(CanvasModel model) {
    return model.elements
        .where((e) => e.type == ElementType.domainEvent)
        .map((e) => _TreeItem(
              id: e.id,
              label: e.label,
              hasLink: false,
            ))
        .toList();
  }

  List<_TreeItem> _getReadModelItems(CanvasModel model) {
    return model.elements
        .where((e) => e.type == ElementType.readModel)
        .map((e) => _TreeItem(
              id: e.id,
              label: e.label,
              hasLink: e.readModelDefinitionId != null,
            ))
        .toList();
  }

  List<_TreeItem> _getPolicyItems(CanvasModel model) {
    return model.elements
        .where((e) => e.type == ElementType.policy)
        .map((e) => _TreeItem(
              id: e.id,
              label: e.label,
              hasLink: false,
            ))
        .toList();
  }

  List<_TreeItem> _getExternalSystemItems(CanvasModel model) {
    return model.elements
        .where((e) => e.type == ElementType.externalSystem)
        .map((e) => _TreeItem(
              id: e.id,
              label: e.label,
              hasLink: false,
            ))
        .toList();
  }

  List<_TreeItem> _getUIItems(CanvasModel model) {
    return model.elements
        .where((e) => e.type == ElementType.ui)
        .map((e) => _TreeItem(
              id: e.id,
              label: e.label,
              hasLink: false,
            ))
        .toList();
  }
}

/// A tree item data structure.
class _TreeItem {
  const _TreeItem({
    required this.id,
    required this.label,
    required this.hasLink,
  });

  final String id;
  final String label;
  final bool hasLink;
}

/// A collapsible section in the tree.
class _TreeSection extends StatefulWidget {
  const _TreeSection({
    required this.title,
    required this.icon,
    required this.items,
    required this.onItemTap,
  });

  final String title;
  final IconData icon;
  final List<_TreeItem> items;
  final void Function(String id) onItemTap;

  @override
  State<_TreeSection> createState() => _TreeSectionState();
}

class _TreeSectionState extends State<_TreeSection> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section header
        InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  _isExpanded ? Icons.expand_more : Icons.chevron_right,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Icon(
                  widget.icon,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.items.length.toString(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Section items
        if (_isExpanded && widget.items.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: Column(
              children: widget.items.map((item) {
                return _TreeItemWidget(
                  item: item,
                  onTap: () => widget.onItemTap(item.id),
                );
              }).toList(),
            ),
          ),

        // Empty state
        if (_isExpanded && widget.items.isEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 32, top: 8, bottom: 8),
            child: Text(
              'No ${widget.title.toLowerCase()} yet',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
}

/// A single tree item widget.
class _TreeItemWidget extends ConsumerWidget {
  const _TreeItemWidget({
    required this.item,
    required this.onTap,
  });

  final _TreeItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final canvasModel = ref.watch(canvasModelProvider);
    final isSelected = canvasModel.selectedElement?.id == item.id;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primaryContainer.withOpacity(0.5)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: isSelected
                ? Border.all(color: theme.colorScheme.primary, width: 2)
                : null,
          ),
          child: Row(
            children: [
              Icon(
                Icons.circle,
                size: 8,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (item.hasLink)
                Icon(
                  Icons.link,
                  size: 14,
                  color: theme.colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
