import 'package:flutter/material.dart';
import 'package:stormforge_modeler/models/entity_model.dart';

/// Tree view for displaying entities.
class EntityTreeView extends StatelessWidget {
  const EntityTreeView({
    super.key,
    required this.entities,
    required this.selectedEntity,
    required this.onEntitySelected,
    required this.onEntityDeleted,
    required this.onCreateEntity,
  });

  final List<EntityDefinition> entities;
  final EntityDefinition? selectedEntity;
  final void Function(EntityDefinition) onEntitySelected;
  final void Function(EntityDefinition) onEntityDeleted;
  final VoidCallback onCreateEntity;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const Text(
                'Entities',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: onCreateEntity,
                tooltip: 'Create Entity',
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: entities.isEmpty
              ? const Center(
                  child: Text('No entities yet.\nClick + to create one.'),
                )
              : ListView.builder(
                  itemCount: entities.length,
                  itemBuilder: (context, index) {
                    final entity = entities[index];
                    final isSelected = selectedEntity?.id == entity.id;
                    
                    return _EntityTreeItem(
                      entity: entity,
                      isSelected: isSelected,
                      onTap: () => onEntitySelected(entity),
                      onDelete: () => onEntityDeleted(entity),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// Individual tree item for an entity.
class _EntityTreeItem extends StatefulWidget {
  const _EntityTreeItem({
    required this.entity,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
  });

  final EntityDefinition entity;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  State<_EntityTreeItem> createState() => _EntityTreeItemState();
}

class _EntityTreeItemState extends State<_EntityTreeItem> {
  bool _isExpanded = false;

  IconData _getEntityIcon() {
    switch (widget.entity.entityType) {
      case EntityType.aggregateRoot:
        return Icons.account_tree;
      case EntityType.valueObject:
        return Icons.data_object;
      case EntityType.entity:
        return Icons.category;
    }
  }

  Color _getEntityColor() {
    switch (widget.entity.entityType) {
      case EntityType.aggregateRoot:
        return Colors.blue;
      case EntityType.valueObject:
        return Colors.green;
      case EntityType.entity:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = widget.isSelected
        ? theme.colorScheme.primaryContainer
        : Colors.transparent;

    return Column(
      children: [
        Material(
          color: backgroundColor,
          child: InkWell(
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _isExpanded
                          ? Icons.expand_more
                          : Icons.chevron_right,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 4),
                  Icon(_getEntityIcon(), color: _getEntityColor(), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.entity.name,
                          style: TextStyle(
                            fontWeight: widget.isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        if (widget.entity.description != null)
                          Text(
                            widget.entity.description!,
                            style: theme.textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 18),
                    onPressed: widget.onDelete,
                    tooltip: 'Delete',
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_isExpanded) ...[
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Column(
              children: [
                _buildSubItem(
                  Icons.view_list,
                  'Properties',
                  widget.entity.properties.length,
                ),
                _buildSubItem(
                  Icons.functions,
                  'Methods',
                  widget.entity.methods.length,
                ),
                _buildSubItem(
                  Icons.rule,
                  'Invariants',
                  widget.entity.invariants.length,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSubItem(IconData icon, String label, int count) {
    return ListTile(
      dense: true,
      leading: Icon(icon, size: 16),
      title: Text(
        '$label ($count)',
        style: const TextStyle(fontSize: 13),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
