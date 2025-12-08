import 'package:flutter/material.dart';
import 'package:stormforge_modeler/models/entity_model.dart';
import 'package:stormforge_modeler/services/api/entity_service.dart';

/// Dialog for selecting an entity to link to an aggregate element.
class EntitySelectionDialog extends StatefulWidget {
  const EntitySelectionDialog({
    super.key,
    required this.projectId,
    required this.entityService,
    this.excludeEntityIds = const [],
  });

  final String projectId;
  final EntityService entityService;
  final List<String> excludeEntityIds;

  @override
  State<EntitySelectionDialog> createState() => _EntitySelectionDialogState();
}

class _EntitySelectionDialogState extends State<EntitySelectionDialog> {
  List<EntityDefinition>? _entities;
  List<EntityDefinition>? _filteredEntities;
  bool _isLoading = false;
  String? _error;
  final _searchController = TextEditingController();
  EntityDefinition? _selectedEntity;

  @override
  void initState() {
    super.initState();
    _loadEntities();
    _searchController.addListener(_filterEntities);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEntities() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final entities =
          await widget.entityService.listEntitiesForProject(widget.projectId);
      
      // Filter out excluded entities
      final filtered = entities
          .where((e) => !widget.excludeEntityIds.contains(e.id))
          .toList();
      
      setState(() {
        _entities = filtered;
        _filteredEntities = filtered;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterEntities() {
    if (_entities == null) return;

    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredEntities = _entities;
      });
      return;
    }

    setState(() {
      _filteredEntities = _entities!
          .where((entity) =>
              entity.name.toLowerCase().contains(query) ||
              (entity.description?.toLowerCase().contains(query) ?? false))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: Container(
        width: 600,
        height: 700,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.account_tree,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Select Entity',
                  style: theme.textTheme.headlineSmall,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Search bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search entities...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
              ),
            ),
            const SizedBox(height: 16),

            // Content
            Expanded(
              child: _buildContent(theme),
            ),

            const SizedBox(height: 16),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _selectedEntity == null
                      ? null
                      : () => Navigator.of(context).pop(_selectedEntity),
                  child: const Text('Link Entity'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load entities',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _loadEntities,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredEntities == null || _filteredEntities!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty
                  ? 'No entities found'
                  : 'No matching entities',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isEmpty
                  ? 'Create entities in the Entity Editor first'
                  : 'Try a different search term',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredEntities!.length,
      itemBuilder: (context, index) {
        final entity = _filteredEntities![index];
        final isSelected = _selectedEntity?.id == entity.id;

        return Card(
          elevation: isSelected ? 2 : 0,
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surface,
          child: ListTile(
            leading: Icon(
              Icons.account_tree,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            title: Text(
              entity.name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            subtitle: entity.description != null && entity.description!.isNotEmpty
                ? Text(entity.description!)
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Chip(
                  label: Text(
                    entity.entityType.name,
                    style: theme.textTheme.labelSmall,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
                if (entity.properties.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Chip(
                      label: Text(
                        '${entity.properties.length} props',
                        style: theme.textTheme.labelSmall,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),
            selected: isSelected,
            onTap: () {
              setState(() {
                _selectedEntity = entity;
              });
            },
          ),
        );
      },
    );
  }
}
