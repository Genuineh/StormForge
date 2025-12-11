import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stormforge_modeler/models/entity_model.dart';
import 'package:stormforge_modeler/screens/entities/widgets/entity_details_panel.dart';
import 'package:stormforge_modeler/screens/entities/widgets/entity_tree_view.dart';
import 'package:stormforge_modeler/services/api/entity_service.dart';
import 'package:stormforge_modeler/services/providers.dart';
import 'package:stormforge_modeler/widgets/workspace_layout.dart';

/// Enhanced entity management screen with workspace layout.
class EntityManagementScreen extends ConsumerStatefulWidget {
  const EntityManagementScreen({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  final String projectId;
  final String projectName;

  @override
  ConsumerState<EntityManagementScreen> createState() => _EntityManagementScreenState();
}

class _EntityManagementScreenState extends ConsumerState<EntityManagementScreen> {
  final EntityService _entityService = EntityService();
  List<EntityDefinition> _entities = [];
  EntityDefinition? _selectedEntity;
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  EntityType? _typeFilter;

  @override
  void initState() {
    super.initState();
    _loadEntities();
  }

  Future<void> _loadEntities() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final entities = await _entityService.listEntitiesForProject(widget.projectId);
      setState(() {
        _entities = entities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load entities: $e';
        _isLoading = false;
      });
    }
  }

  List<EntityDefinition> get _filteredEntities {
    var filtered = _entities;

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((e) =>
        e.name.toLowerCase().contains(query) ||
        (e.description?.toLowerCase().contains(query) ?? false)
      ).toList();
    }

    // Type filter
    if (_typeFilter != null) {
      filtered = filtered.where((e) => e.entityType == _typeFilter).toList();
    }

    return filtered;
  }

  Future<void> _createEntity() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const _CreateEntityDialog(),
    );

    if (result == null) return;

    try {
      final entity = await _entityService.createEntity(
        projectId: widget.projectId,
        name: result['name'] as String,
        entityType: result['entityType'] as EntityType,
        description: result['description'] as String?,
      );

      setState(() {
        _entities.add(entity);
        _selectedEntity = entity;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create entity: $e')),
        );
      }
    }
  }

  void _onEntityUpdated(EntityDefinition entity) {
    setState(() {
      final index = _entities.indexWhere((e) => e.id == entity.id);
      if (index != -1) {
        _entities[index] = entity;
      }
      if (_selectedEntity?.id == entity.id) {
        _selectedEntity = entity;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WorkspaceLayout(
      projectId: widget.projectId,
      projectName: widget.projectName,
      leftPanel: _buildLeftPanel(),
      rightPanel: _selectedEntity != null
          ? EntityDetailsPanel(
              entity: _selectedEntity!,
              entityService: _entityService,
              onEntityUpdated: _onEntityUpdated,
            )
          : _buildEmptyRightPanel(),
      child: _buildMainContent(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createEntity,
        icon: const Icon(Icons.add),
        label: const Text('New Entity'),
      ),
    );
  }

  Widget _buildLeftPanel() {
    return EntityTreeView(
      entities: _entities,
      selectedEntity: _selectedEntity,
      onEntitySelected: (entity) {
        setState(() {
          _selectedEntity = entity;
        });
      },
      onEntityDeleted: (entity) async {
        try {
          await _entityService.deleteEntity(entity.id);
          setState(() {
            _entities.removeWhere((e) => e.id == entity.id);
            if (_selectedEntity?.id == entity.id) {
              _selectedEntity = null;
            }
          });
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to delete entity: $e')),
            );
          }
        }
      },
      onCreateEntity: _createEntity,
    );
  }

  Widget _buildEmptyRightPanel() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            size: 48,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Select an entity',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Choose an entity from the list\nto view its details',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(_error!),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _loadEntities,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Toolbar
        _buildToolbar(),
        const Divider(height: 1),

        // Entity grid
        Expanded(
          child: _buildEntityGrid(),
        ),
      ],
    );
  }

  Widget _buildToolbar() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Search
          SizedBox(
            width: 300,
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search entities...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          const SizedBox(width: 16),

          // Type filter
          DropdownButton<EntityType?>(
            value: _typeFilter,
            hint: const Text('All Types'),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('All Types'),
              ),
              ...EntityType.values.map((type) => DropdownMenuItem(
                value: type,
                child: Text(_getEntityTypeLabel(type)),
              )),
            ],
            onChanged: (value) {
              setState(() {
                _typeFilter = value;
              });
            },
          ),
          const Spacer(),

          // Stats
          Text(
            '${_filteredEntities.length} of ${_entities.length} entities',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntityGrid() {
    final filteredEntities = _filteredEntities;

    if (filteredEntities.isEmpty) {
      final theme = Theme.of(context);
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isNotEmpty || _typeFilter != null
                  ? Icons.search_off
                  : Icons.category_outlined,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty || _typeFilter != null
                  ? 'No entities found'
                  : 'No entities yet',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty || _typeFilter != null
                  ? 'Try adjusting your filters'
                  : 'Create your first entity to get started',
              style: theme.textTheme.bodyMedium,
            ),
            if (_entities.isEmpty) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _createEntity,
                icon: const Icon(Icons.add),
                label: const Text('Create Entity'),
              ),
            ],
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 280,
        childAspectRatio: 1.1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredEntities.length,
      itemBuilder: (context, index) {
        final entity = filteredEntities[index];
        return _EntityCard(
          entity: entity,
          isSelected: _selectedEntity?.id == entity.id,
          onTap: () {
            setState(() {
              _selectedEntity = entity;
            });
          },
        );
      },
    );
  }

  String _getEntityTypeLabel(EntityType type) {
    switch (type) {
      case EntityType.aggregateRoot:
        return 'Aggregate';
      case EntityType.entity:
        return 'Entity';
      case EntityType.valueObject:
        return 'Value Object';
    }
  }
}

/// Entity card widget.
class _EntityCard extends StatelessWidget {
  const _EntityCard({
    required this.entity,
    required this.isSelected,
    required this.onTap,
  });

  final EntityDefinition entity;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final typeColor = _getEntityTypeColor(entity.entityType);
    final typeIcon = _getEntityTypeIcon(entity.entityType);

    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected
          ? theme.colorScheme.primaryContainer.withOpacity(0.3)
          : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type badge and name
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(typeIcon, size: 14, color: typeColor),
                        const SizedBox(width: 4),
                        Text(
                          _getEntityTypeLabel(entity.entityType),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: typeColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Entity name
              Text(
                entity.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Description
              Expanded(
                child: Text(
                  entity.description ?? 'No description',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const Divider(),

              // Stats
              Row(
                children: [
                  Icon(
                    Icons.tag,
                    size: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${entity.properties.length} properties',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.functions,
                    size: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${entity.methods.length} methods',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getEntityTypeColor(EntityType type) {
    switch (type) {
      case EntityType.aggregateRoot:
        return Colors.blue;
      case EntityType.entity:
        return Colors.green;
      case EntityType.valueObject:
        return Colors.orange;
    }
  }

  IconData _getEntityTypeIcon(EntityType type) {
    switch (type) {
      case EntityType.aggregateRoot:
        return Icons.account_tree;
      case EntityType.entity:
        return Icons.category;
      case EntityType.valueObject:
        return Icons.token;
    }
  }

  String _getEntityTypeLabel(EntityType type) {
    switch (type) {
      case EntityType.aggregateRoot:
        return 'Aggregate';
      case EntityType.entity:
        return 'Entity';
      case EntityType.valueObject:
        return 'Value Object';
    }
  }
}

/// Dialog for creating a new entity.
class _CreateEntityDialog extends StatefulWidget {
  const _CreateEntityDialog();

  @override
  State<_CreateEntityDialog> createState() => _CreateEntityDialogState();
}

class _CreateEntityDialogState extends State<_CreateEntityDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  EntityType _selectedType = EntityType.aggregateRoot;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Entity'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<EntityType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                ),
                items: EntityType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getTypeLabel(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'name': _nameController.text,
                'entityType': _selectedType,
                'description': _descriptionController.text.isEmpty
                    ? null
                    : _descriptionController.text,
              });
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }

  String _getTypeLabel(EntityType type) {
    switch (type) {
      case EntityType.aggregateRoot:
        return 'Aggregate';
      case EntityType.entity:
        return 'Entity';
      case EntityType.valueObject:
        return 'Value Object';
    }
  }
}
