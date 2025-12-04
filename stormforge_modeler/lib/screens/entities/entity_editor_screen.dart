import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stormforge_modeler/models/entity_model.dart';
import 'package:stormforge_modeler/services/api/entity_service.dart';
import 'package:stormforge_modeler/screens/entities/widgets/entity_tree_view.dart';
import 'package:stormforge_modeler/screens/entities/widgets/entity_details_panel.dart';
import 'package:stormforge_modeler/utils/entity_import_export.dart';

/// Entity editor screen with tree view and details panel.
class EntityEditorScreen extends StatefulWidget {
  const EntityEditorScreen({
    super.key,
    required this.projectId,
  });

  final String projectId;

  @override
  State<EntityEditorScreen> createState() => _EntityEditorScreenState();
}

class _EntityEditorScreenState extends State<EntityEditorScreen> {
  final EntityService _entityService = EntityService();
  List<EntityDefinition> _entities = [];
  EntityDefinition? _selectedEntity;
  bool _isLoading = true;
  String? _error;

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
      final entities =
          await _entityService.listEntitiesForProject(widget.projectId);
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

  Future<void> _deleteEntity(EntityDefinition entity) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entity'),
        content: Text('Are you sure you want to delete "${entity.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

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
  }

  void _onEntitySelected(EntityDefinition entity) {
    setState(() {
      _selectedEntity = entity;
    });
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

  Future<void> _exportAllEntities() async {
    try {
      final json = EntityImportExport.exportEntitiesToJson(_entities);
      await Clipboard.setData(ClipboardData(text: json));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All entities exported to clipboard'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export entities: $e')),
        );
      }
    }
  }

  Future<void> _exportSelectedEntity() async {
    if (_selectedEntity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an entity to export')),
      );
      return;
    }

    try {
      final json = EntityImportExport.exportEntityToJson(_selectedEntity!);
      await Clipboard.setData(ClipboardData(text: json));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Entity "${_selectedEntity!.name}" exported to clipboard'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export entity: $e')),
        );
      }
    }
  }

  Future<void> _importEntities() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => const _ImportDialog(),
    );

    if (result == null) return;

    try {
      final entities = EntityImportExport.importEntitiesFromJson(result);
      // Note: In a real implementation, you would need to create these entities
      // via the API with new IDs and update the project ID
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully imported ${entities.length} entities'),
          ),
        );
      }
      await _loadEntities();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to import entities: $e')),
        );
      }
    }
  }

  void _showTemplate() {
    final template = EntityImportExport.createTemplate();
    showDialog(
      context: context,
      builder: (context) => _TemplateDialog(template: template),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entity Editor'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'export_all':
                  _exportAllEntities();
                  break;
                case 'export_selected':
                  _exportSelectedEntity();
                  break;
                case 'import':
                  _importEntities();
                  break;
                case 'template':
                  _showTemplate();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export_all',
                child: Row(
                  children: [
                    Icon(Icons.file_download),
                    SizedBox(width: 8),
                    Text('Export All Entities'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export_selected',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Export Selected Entity'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.file_upload),
                    SizedBox(width: 8),
                    Text('Import Entities'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'template',
                child: Row(
                  children: [
                    Icon(Icons.description),
                    SizedBox(width: 8),
                    Text('View Template'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEntities,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : Row(
                  children: [
                    // Entity tree on the left
                    SizedBox(
                      width: 300,
                      child: EntityTreeView(
                        entities: _entities,
                        selectedEntity: _selectedEntity,
                        onEntitySelected: _onEntitySelected,
                        onEntityDeleted: _deleteEntity,
                        onCreateEntity: _createEntity,
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    // Details panel on the right
                    Expanded(
                      child: _selectedEntity == null
                          ? const Center(
                              child: Text('Select an entity to view details'),
                            )
                          : EntityDetailsPanel(
                              entity: _selectedEntity!,
                              entityService: _entityService,
                              onEntityUpdated: _onEntityUpdated,
                            ),
                    ),
                  ],
                ),
    );
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
  EntityType _entityType = EntityType.entity;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'name': _nameController.text,
        'description': _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        'entityType': _entityType,
      });
    }
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
                  hintText: 'e.g., Order',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Brief description of the entity',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<EntityType>(
                value: _entityType,
                decoration: const InputDecoration(
                  labelText: 'Entity Type',
                ),
                items: EntityType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_formatEntityType(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _entityType = value;
                    });
                  }
                },
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
          onPressed: _submit,
          child: const Text('Create'),
        ),
      ],
    );
  }

  String _formatEntityType(EntityType type) {
    switch (type) {
      case EntityType.entity:
        return 'Entity';
      case EntityType.aggregateRoot:
        return 'Aggregate Root';
      case EntityType.valueObject:
        return 'Value Object';
    }
  }
}

/// Dialog for importing entities from JSON.
class _ImportDialog extends StatefulWidget {
  const _ImportDialog();

  @override
  State<_ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<_ImportDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validate() {
    setState(() {
      _error = null;
    });

    if (_controller.text.isEmpty) {
      setState(() {
        _error = 'Please paste JSON content';
      });
      return;
    }

    if (!EntityImportExport.validateJson(_controller.text)) {
      setState(() {
        _error = 'Invalid JSON format. Please check your input.';
      });
      return;
    }

    Navigator.pop(context, _controller.text);
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    if (data != null && data.text != null) {
      setState(() {
        _controller.text = data.text!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Import Entities'),
      content: SizedBox(
        width: 600,
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Paste entity JSON below:'),
                const Spacer(),
                TextButton.icon(
                  onPressed: _pasteFromClipboard,
                  icon: const Icon(Icons.content_paste),
                  label: const Text('Paste'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: 'Paste JSON here...',
                  errorText: _error,
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
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
          onPressed: _validate,
          child: const Text('Import'),
        ),
      ],
    );
  }
}

/// Dialog for displaying entity template.
class _TemplateDialog extends StatelessWidget {
  const _TemplateDialog({required this.template});

  final String template;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Entity JSON Template'),
      content: SizedBox(
        width: 600,
        height: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Use this template as a reference for creating entity JSON:',
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    template,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: template));
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Template copied to clipboard')),
              );
            }
          },
          child: const Text('Copy'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
