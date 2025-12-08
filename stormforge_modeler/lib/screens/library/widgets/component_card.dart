import 'package:flutter/material.dart';

import 'package:stormforge_modeler/models/library_model.dart';

/// Card widget displaying a library component in grid view.
class ComponentCard extends StatelessWidget {
  const ComponentCard({
    super.key,
    required this.component,
    required this.onTap,
  });

  final LibraryComponent component;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and type
              Row(
                children: [
                  _buildComponentIcon(),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          component.type.displayName,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ),
                  _buildScopeBadge(context),
                ],
              ),
              const SizedBox(height: 12),
              // Component name
              Text(
                component.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Namespace
              Text(
                component.namespace,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontFamily: 'monospace',
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Description
              Expanded(
                child: Text(
                  component.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 8),
              // Tags (show max 2)
              if (component.tags.isNotEmpty)
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: component.tags
                      .take(2)
                      .map((tag) => Chip(
                            label: Text(
                              tag,
                              style: const TextStyle(fontSize: 10),
                            ),
                            padding: const EdgeInsets.all(4),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ))
                      .toList(),
                ),
              const SizedBox(height: 8),
              // Footer with version and usage stats
              Row(
                children: [
                  // Version
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'v${component.version}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            fontFamily: 'monospace',
                          ),
                    ),
                  ),
                  const Spacer(),
                  // Usage stats
                  Row(
                    children: [
                      const Icon(Icons.folder, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${component.usageStats.projectCount}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Row(
                    children: [
                      const Icon(Icons.link, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${component.usageStats.referenceCount}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              // Status indicator (if not active)
              if (component.status != ComponentStatus.active)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(component.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(component.status),
                          size: 12,
                          color: _getStatusColor(component.status),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          component.status.displayName,
                          style: TextStyle(
                            fontSize: 11,
                            color: _getStatusColor(component.status),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComponentIcon() {
    IconData icon;
    Color color;

    switch (component.type) {
      case ComponentType.entity:
        icon = Icons.layers;
        color = Colors.blue;
        break;
      case ComponentType.valueObject:
        icon = Icons.data_object;
        color = Colors.green;
        break;
      case ComponentType.enumType:
        icon = Icons.list;
        color = Colors.orange;
        break;
      case ComponentType.aggregate:
        icon = Icons.account_tree;
        color = Colors.purple;
        break;
      case ComponentType.command:
        icon = Icons.play_arrow;
        color = Colors.indigo;
        break;
      case ComponentType.event:
        icon = Icons.event_note;
        color = Colors.red;
        break;
      case ComponentType.readModel:
        icon = Icons.visibility;
        color = Colors.teal;
        break;
      case ComponentType.policy:
        icon = Icons.policy;
        color = Colors.brown;
        break;
      case ComponentType.interface:
        icon = Icons.integration_instructions;
        color = Colors.cyan;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 24, color: color),
    );
  }

  Widget _buildScopeBadge(BuildContext context) {
    Color color;
    switch (component.scope) {
      case LibraryScope.enterprise:
        color = Colors.amber;
        break;
      case LibraryScope.organization:
        color = Colors.blue;
        break;
      case LibraryScope.project:
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        component.scope.displayName,
        style: TextStyle(
          fontSize: 10,
          color: color[700] ?? color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getStatusColor(ComponentStatus status) {
    switch (status) {
      case ComponentStatus.draft:
        return Colors.blue;
      case ComponentStatus.active:
        return Colors.green;
      case ComponentStatus.deprecated:
        return Colors.orange;
      case ComponentStatus.archived:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(ComponentStatus status) {
    switch (status) {
      case ComponentStatus.draft:
        return Icons.edit;
      case ComponentStatus.active:
        return Icons.check_circle;
      case ComponentStatus.deprecated:
        return Icons.warning;
      case ComponentStatus.archived:
        return Icons.archive;
    }
  }
}
