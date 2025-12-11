import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stormforge_modeler/models/models.dart';
import 'package:stormforge_modeler/services/api/api_client.dart';
import 'package:stormforge_modeler/services/api/entity_service.dart';
import 'package:stormforge_modeler/services/api/read_model_service.dart';
import 'package:stormforge_modeler/widgets/workspace_layout.dart';

/// Enhanced Read Model Designer with workspace layout.
class ReadModelManagementScreen extends ConsumerStatefulWidget {
  const ReadModelManagementScreen({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  final String projectId;
  final String projectName;

  @override
  ConsumerState<ReadModelManagementScreen> createState() =>
      _ReadModelManagementScreenState();
}

class _ReadModelManagementScreenState
    extends ConsumerState<ReadModelManagementScreen> {
  final ReadModelService _readModelService = ReadModelService(ApiClient());
  final EntityService _entityService = EntityService();

  List<ReadModelDefinition> _readModels = [];
  List<EntityDefinition> _entities = [];
  ReadModelDefinition? _selectedReadModel;
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final readModels =
          await _readModelService.listReadModelsForProject(widget.projectId);
      final entities =
          await _entityService.listEntitiesForProject(widget.projectId);

      setState(() {
        _readModels = readModels;
        _entities = entities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load data: $e';
        _isLoading = false;
      });
    }
  }

  List<ReadModelDefinition> get _filteredReadModels {
    if (_searchQuery.isEmpty) return _readModels;
    
    final query = _searchQuery.toLowerCase();
    return _readModels.where((rm) =>
      rm.name.toLowerCase().contains(query) ||
      (rm.description?.toLowerCase().contains(query) ?? false)
    ).toList();
  }

  Future<void> _createReadModel() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _CreateReadModelDialog(entities: _entities),
    );

    if (result == null) return;

    try {
      final readModel = await _readModelService.createReadModel(
        projectId: widget.projectId,
        name: result['name'] as String,
        description: result['description'] as String?,
      );

      setState(() {
        _readModels.add(readModel);
        _selectedReadModel = readModel;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Read model created')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create read model: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WorkspaceLayout(
      projectId: widget.projectId,
      projectName: widget.projectName,
      leftPanel: _buildLeftPanel(),
      rightPanel: _selectedReadModel != null
          ? _buildDetailsPanel()
          : _buildEmptyPanel(),
      child: _buildMainContent(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createReadModel,
        icon: const Icon(Icons.add),
        label: const Text('New Read Model'),
      ),
    );
  }

  Widget _buildLeftPanel() {
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            'Read Models',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _readModels.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.view_module_outlined,
                        size: 48,
                        color: theme.colorScheme.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No read models',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _readModels.length,
                  itemBuilder: (context, index) {
                    final readModel = _readModels[index];
                    final isSelected = _selectedReadModel?.id == readModel.id;

                    return ListTile(
                      selected: isSelected,
                      leading: Icon(
                        Icons.view_module,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      title: Text(readModel.name),
                      subtitle: Text(
                        '${readModel.fields.length} fields',
                        style: theme.textTheme.bodySmall,
                      ),
                      onTap: () {
                        setState(() {
                          _selectedReadModel = readModel;
                        });
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDetailsPanel() {
    final theme = Theme.of(context);
    final readModel = _selectedReadModel!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Details',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Name
          _InfoRow(
            label: 'Name',
            value: readModel.name,
          ),
          const SizedBox(height: 12),

          // Description
          _InfoRow(
            label: 'Description',
            value: readModel.description ?? 'No description',
          ),
          const SizedBox(height: 12),

          // Fields count
          _InfoRow(
            label: 'Fields',
            value: '${readModel.fields.length}',
          ),
          const SizedBox(height: 12),

          // Source entities count
          _InfoRow(
            label: 'Source Entities',
            value: '${readModel.sources.length}',
          ),
          const SizedBox(height: 24),

          // Fields list
          Text(
            'Fields',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (readModel.fields.isEmpty)
            Text(
              'No fields defined',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            )
          else
            ...readModel.fields.map((field) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.label, size: 20),
                title: Text(field.name),
                subtitle: Text(field.fieldType),
                dense: true,
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildEmptyPanel() {
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
            'Select a read model',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a read model\nto view its details',
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
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildToolbar(),
        const Divider(height: 1),
        Expanded(child: _buildReadModelGrid()),
      ],
    );
  }

  Widget _buildToolbar() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          SizedBox(
            width: 300,
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search read models...',
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
          const Spacer(),
          Text(
            '${_filteredReadModels.length} of ${_readModels.length} read models',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadModelGrid() {
    final filteredReadModels = _filteredReadModels;

    if (filteredReadModels.isEmpty) {
      final theme = Theme.of(context);
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isNotEmpty
                  ? Icons.search_off
                  : Icons.view_module_outlined,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No read models found'
                  : 'No read models yet',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try a different search term'
                  : 'Create your first read model',
              style: theme.textTheme.bodyMedium,
            ),
            if (_readModels.isEmpty) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _createReadModel,
                icon: const Icon(Icons.add),
                label: const Text('Create Read Model'),
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
      itemCount: filteredReadModels.length,
      itemBuilder: (context, index) {
        final readModel = filteredReadModels[index];
        return _ReadModelCard(
          readModel: readModel,
          isSelected: _selectedReadModel?.id == readModel.id,
          onTap: () {
            setState(() {
              _selectedReadModel = readModel;
            });
          },
        );
      },
    );
  }
}

/// Info row widget.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

/// Read model card widget.
class _ReadModelCard extends StatelessWidget {
  const _ReadModelCard({
    required this.readModel,
    required this.isSelected,
    required this.onTap,
  });

  final ReadModelDefinition readModel;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              Icon(
                Icons.view_module,
                size: 32,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                readModel.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  readModel.description ?? 'No description',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Divider(),
              Row(
                children: [
                  Icon(
                    Icons.label,
                    size: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${readModel.fields.length} fields',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.source,
                    size: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${readModel.sources.length} sources',
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
}

/// Dialog for creating a new read model.
class _CreateReadModelDialog extends StatefulWidget {
  const _CreateReadModelDialog({required this.entities});

  final List<EntityDefinition> entities;

  @override
  State<_CreateReadModelDialog> createState() => _CreateReadModelDialogState();
}

class _CreateReadModelDialogState extends State<_CreateReadModelDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Read Model'),
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
}
