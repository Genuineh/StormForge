import 'package:flutter/material.dart';
import 'package:stormforge_modeler/models/models.dart';
import 'package:stormforge_modeler/services/api/api_client.dart';
import 'package:stormforge_modeler/services/api/entity_service.dart';
import 'package:stormforge_modeler/services/api/read_model_service.dart';

/// Read Model Designer Screen - main editor for read models
class ReadModelDesignerScreen extends StatefulWidget {
  const ReadModelDesignerScreen({
    super.key,
    required this.projectId,
  });

  final String projectId;

  @override
  State<ReadModelDesignerScreen> createState() =>
      _ReadModelDesignerScreenState();
}

class _ReadModelDesignerScreenState extends State<ReadModelDesignerScreen> {
  final ReadModelService _readModelService = ReadModelService(ApiClient());
  final EntityService _entityService = EntityService();
  
  List<ReadModelDefinition> _readModels = [];
  List<EntityDefinition> _entities = [];
  ReadModelDefinition? _selectedReadModel;
  bool _isLoading = true;
  String? _error;

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

  Future<void> _createReadModel() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const _CreateReadModelDialog(),
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
          const SnackBar(content: Text('Read model created successfully')),
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

  Future<void> _deleteReadModel(ReadModelDefinition readModel) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Read Model'),
        content: Text('Are you sure you want to delete "${readModel.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _readModelService.deleteReadModel(readModel.id);
      
      setState(() {
        _readModels.remove(readModel);
        if (_selectedReadModel?.id == readModel.id) {
          _selectedReadModel = null;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Read model deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete read model: $e')),
        );
      }
    }
  }

  Future<void> _addSource() async {
    if (_selectedReadModel == null) return;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _AddSourceDialog(entities: _entities),
    );

    if (result == null) return;

    try {
      final updated = await _readModelService.addSource(
        readModelId: _selectedReadModel!.id,
        entityId: result['entityId'] as String,
        alias: result['alias'] as String,
        joinType: result['joinType'] as JoinType,
        joinCondition: result['joinCondition'] as JoinCondition?,
      );

      setState(() {
        _selectedReadModel = updated;
        final index = _readModels.indexWhere((rm) => rm.id == updated.id);
        if (index != -1) {
          _readModels[index] = updated;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data source added')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add source: $e')),
        );
      }
    }
  }

  Future<void> _addField() async {
    if (_selectedReadModel == null) return;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _AddFieldDialog(
        readModel: _selectedReadModel!,
        entities: _entities,
      ),
    );

    if (result == null) return;

    try {
      final updated = await _readModelService.addField(
        readModelId: _selectedReadModel!.id,
        name: result['name'] as String,
        fieldType: result['fieldType'] as String,
        sourceType: result['sourceType'] as FieldSourceType,
        sourcePath: result['sourcePath'] as String,
        transform: result['transform'] as FieldTransform?,
        nullable: result['nullable'] as bool? ?? false,
        description: result['description'] as String?,
      );

      setState(() {
        _selectedReadModel = updated;
        final index = _readModels.indexWhere((rm) => rm.id == updated.id);
        if (index != -1) {
          _readModels[index] = updated;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Field added')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add field: $e')),
        );
      }
    }
  }

  Future<void> _removeField(ReadModelField field) async {
    if (_selectedReadModel == null) return;

    try {
      final updated = await _readModelService.removeField(
        readModelId: _selectedReadModel!.id,
        fieldId: field.id,
      );

      setState(() {
        _selectedReadModel = updated;
        final index = _readModels.indexWhere((rm) => rm.id == updated.id);
        if (index != -1) {
          _readModels[index] = updated;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Field removed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove field: $e')),
        );
      }
    }
  }

  Future<void> _removeSource(int index) async {
    if (_selectedReadModel == null) return;

    try {
      final updated = await _readModelService.removeSource(
        readModelId: _selectedReadModel!.id,
        sourceIndex: index,
      );

      setState(() {
        _selectedReadModel = updated;
        final rmIndex = _readModels.indexWhere((rm) => rm.id == updated.id);
        if (rmIndex != -1) {
          _readModels[rmIndex] = updated;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Source removed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove source: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Read Model Designer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createReadModel,
            tooltip: 'Create Read Model',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Row(
                  children: [
                    // Left panel: Read model list
                    SizedBox(
                      width: 300,
                      child: _buildReadModelList(),
                    ),
                    const VerticalDivider(width: 1),
                    // Right panel: Read model details
                    Expanded(
                      child: _selectedReadModel == null
                          ? const Center(
                              child: Text('Select a read model to edit'),
                            )
                          : _buildReadModelDetails(),
                    ),
                  ],
                ),
    );
  }

  Widget _buildReadModelList() {
    if (_readModels.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.view_module, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No read models yet'),
            Text('Click + to create one', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _readModels.length,
      itemBuilder: (context, index) {
        final readModel = _readModels[index];
        final isSelected = _selectedReadModel?.id == readModel.id;

        return ListTile(
          selected: isSelected,
          leading: const Icon(Icons.view_module),
          title: Text(readModel.name),
          subtitle: Text(
            '${readModel.sources.length} sources, ${readModel.fields.length} fields',
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete, size: 20),
            onPressed: () => _deleteReadModel(readModel),
          ),
          onTap: () {
            setState(() {
              _selectedReadModel = readModel;
            });
          },
        );
      },
    );
  }

  Widget _buildReadModelDetails() {
    final readModel = _selectedReadModel!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      readModel.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    if (readModel.description != null)
                      Text(
                        readModel.description!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Data Sources Section
          _buildSectionHeader('Data Sources', _addSource),
          const SizedBox(height: 8),
          _buildSourcesList(),
          const SizedBox(height: 24),

          // Fields Section
          _buildSectionHeader('Fields', _addField),
          const SizedBox(height: 8),
          _buildFieldsList(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onAdd) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add'),
        ),
      ],
    );
  }

  Widget _buildSourcesList() {
    final readModel = _selectedReadModel!;

    if (readModel.sources.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text('No data sources yet')),
        ),
      );
    }

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: readModel.sources.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final source = readModel.sources[index];
          final entity = _entities.firstWhere(
            (e) => e.id == source.entityId,
            orElse: () => EntityDefinition.create(
              projectId: widget.projectId,
              name: 'Unknown',
              entityType: EntityType.entity,
            ),
          );

          return ListTile(
            leading: CircleAvatar(
              child: Text('${index + 1}'),
            ),
            title: Text('${entity.name} (${source.alias})'),
            subtitle: Text('${source.joinType.name} join'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, size: 20),
              onPressed: () => _removeSource(index),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFieldsList() {
    final readModel = _selectedReadModel!;

    if (readModel.fields.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text('No fields yet')),
        ),
      );
    }

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: readModel.fields.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final field = readModel.fields[index];

          return ListTile(
            leading: Icon(
              field.nullable ? Icons.radio_button_unchecked : Icons.circle,
              size: 16,
            ),
            title: Text(field.name),
            subtitle: Text(
              '${field.fieldType} ← ${field.sourcePath}',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (field.transform != null)
                  Chip(
                    label: Text(
                      field.transform!.transformType.name,
                      style: const TextStyle(fontSize: 10),
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: () => _removeField(field),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Create Read Model Dialog
class _CreateReadModelDialog extends StatefulWidget {
  const _CreateReadModelDialog();

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g., OrderSummary',
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
                labelText: 'Description',
                hintText: 'Optional description',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
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

// Add Source Dialog
class _AddSourceDialog extends StatefulWidget {
  const _AddSourceDialog({required this.entities});

  final List<EntityDefinition> entities;

  @override
  State<_AddSourceDialog> createState() => _AddSourceDialogState();
}

class _AddSourceDialogState extends State<_AddSourceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _aliasController = TextEditingController();
  String? _selectedEntityId;
  JoinType _joinType = JoinType.inner;

  @override
  void dispose() {
    _aliasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Data Source'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedEntityId,
              decoration: const InputDecoration(labelText: 'Entity'),
              items: widget.entities.map((entity) {
                return DropdownMenuItem(
                  value: entity.id,
                  child: Text(entity.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedEntityId = value;
                  if (_aliasController.text.isEmpty && value != null) {
                    final entity = widget.entities.firstWhere((e) => e.id == value);
                    _aliasController.text = entity.name.toLowerCase();
                  }
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select an entity';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _aliasController,
              decoration: const InputDecoration(
                labelText: 'Alias',
                hintText: 'e.g., order',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an alias';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<JoinType>(
              value: _joinType,
              decoration: const InputDecoration(labelText: 'Join Type'),
              items: JoinType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _joinType = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'entityId': _selectedEntityId!,
                'alias': _aliasController.text,
                'joinType': _joinType,
                'joinCondition': null,
              });
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

// Add Field Dialog
class _AddFieldDialog extends StatefulWidget {
  const _AddFieldDialog({
    required this.readModel,
    required this.entities,
  });

  final ReadModelDefinition readModel;
  final List<EntityDefinition> entities;

  @override
  State<_AddFieldDialog> createState() => _AddFieldDialogState();
}

class _AddFieldDialogState extends State<_AddFieldDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _fieldTypeController = TextEditingController(text: 'String');
  final _sourcePathController = TextEditingController();
  FieldSourceType _sourceType = FieldSourceType.direct;
  bool _nullable = false;

  @override
  void dispose() {
    _nameController.dispose();
    _fieldTypeController.dispose();
    _sourcePathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Field'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Field Name',
                  hintText: 'e.g., customerId',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a field name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fieldTypeController,
                decoration: const InputDecoration(
                  labelText: 'Field Type',
                  hintText: 'e.g., String, int',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a field type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _sourcePathController,
                decoration: const InputDecoration(
                  labelText: 'Source Path',
                  hintText: 'e.g., customer.id',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a source path';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<FieldSourceType>(
                value: _sourceType,
                decoration: const InputDecoration(labelText: 'Source Type'),
                items: FieldSourceType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.name),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _sourceType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Nullable'),
                value: _nullable,
                onChanged: (value) {
                  setState(() {
                    _nullable = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
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
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'name': _nameController.text,
                'fieldType': _fieldTypeController.text,
                'sourcePath': _sourcePathController.text,
                'sourceType': _sourceType,
                'nullable': _nullable,
                'transform': null,
                'description': null,
              });
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
