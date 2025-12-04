import 'package:flutter/material.dart';
import 'package:stormforge_modeler/models/command_model.dart';
import 'package:stormforge_modeler/models/entity_model.dart';
import 'package:stormforge_modeler/services/api/api_client.dart';
import 'package:stormforge_modeler/services/api/command_service.dart';
import 'package:stormforge_modeler/services/api/entity_service.dart';

/// Command Designer Screen - main editor for commands
class CommandDesignerScreen extends StatefulWidget {
  const CommandDesignerScreen({
    super.key,
    required this.projectId,
  });

  final String projectId;

  @override
  State<CommandDesignerScreen> createState() => _CommandDesignerScreenState();
}

class _CommandDesignerScreenState extends State<CommandDesignerScreen> {
  final CommandService _commandService = CommandService(ApiClient());
  final EntityService _entityService = EntityService();
  
  List<CommandDefinition> _commands = [];
  List<EntityDefinition> _entities = [];
  CommandDefinition? _selectedCommand;
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
      final commands =
          await _commandService.listCommandsForProject(widget.projectId);
      final entities =
          await _entityService.listEntitiesForProject(widget.projectId);
      
      setState(() {
        _commands = commands;
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

  Future<void> _createCommand() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _CreateCommandDialog(entities: _entities),
    );

    if (result == null) return;

    try {
      final command = await _commandService.createCommand(
        projectId: widget.projectId,
        name: result['name'] as String,
        description: result['description'] as String?,
        aggregateId: result['aggregateId'] as String?,
      );

      setState(() {
        _commands.add(command);
        _selectedCommand = command;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Command created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create command: $e')),
        );
      }
    }
  }

  Future<void> _deleteCommand(CommandDefinition command) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Command'),
        content: Text('Are you sure you want to delete "${command.name}"?'),
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
      await _commandService.deleteCommand(command.id);
      
      setState(() {
        _commands.remove(command);
        if (_selectedCommand?.id == command.id) {
          _selectedCommand = null;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Command deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete command: $e')),
        );
      }
    }
  }

  Future<void> _addField() async {
    if (_selectedCommand == null) return;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const _AddFieldDialog(),
    );

    if (result == null) return;

    try {
      final updatedCommand = await _commandService.addField(
        commandId: _selectedCommand!.id,
        name: result['name'] as String,
        fieldType: result['fieldType'] as String,
        required: result['required'] as bool,
        source: result['source'] as FieldSource,
        description: result['description'] as String?,
      );

      setState(() {
        final index = _commands.indexWhere((c) => c.id == _selectedCommand!.id);
        if (index != -1) {
          _commands[index] = updatedCommand;
          _selectedCommand = updatedCommand;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Field added successfully')),
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

  Future<void> _removeField(CommandField field) async {
    if (_selectedCommand == null) return;

    try {
      final updatedCommand = await _commandService.removeField(
        commandId: _selectedCommand!.id,
        fieldId: field.id,
      );

      setState(() {
        final index = _commands.indexWhere((c) => c.id == _selectedCommand!.id);
        if (index != -1) {
          _commands[index] = updatedCommand;
          _selectedCommand = updatedCommand;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Command Designer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createCommand,
            tooltip: 'Create Command',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
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
      );
    }

    return Row(
      children: [
        // Left panel - Command list
        Container(
          width: 300,
          decoration: BoxDecoration(
            border: Border(right: BorderSide(color: Colors.grey.shade300)),
          ),
          child: _buildCommandList(),
        ),
        // Right panel - Command details
        Expanded(
          child: _selectedCommand == null
              ? const Center(
                  child: Text(
                    'Select a command to view details',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : _buildCommandDetails(),
        ),
      ],
    );
  }

  Widget _buildCommandList() {
    if (_commands.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No commands yet.\nClick + to create one.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: _commands.length,
      itemBuilder: (context, index) {
        final command = _commands[index];
        final isSelected = _selectedCommand?.id == command.id;

        return ListTile(
          selected: isSelected,
          title: Text(command.name),
          subtitle: Text(
            '${command.payload.fields.length} fields',
            style: const TextStyle(fontSize: 12),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete, size: 20),
            onPressed: () => _deleteCommand(command),
          ),
          onTap: () {
            setState(() {
              _selectedCommand = command;
            });
          },
        );
      },
    );
  }

  Widget _buildCommandDetails() {
    final command = _selectedCommand!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    command.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (command.description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      command.description!,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                  if (command.aggregateId != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Aggregate: ${command.aggregateId}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Payload Fields Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payload Fields',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add'),
                onPressed: _addField,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Card(
            child: command.payload.fields.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'No fields yet. Click "Add" to add one.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: command.payload.fields.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final field = command.payload.fields[index];
                      return ListTile(
                        title: Text(field.name),
                        subtitle: Text(
                          '${field.fieldType} • Source: ${field.source.type.name}${field.required ? " • Required" : ""}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          onPressed: () => _removeField(field),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
          
          // Validations Section
          Text(
            'Validations',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            child: command.validations.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'No validations',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: command.validations.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final validation = command.validations[index];
                      return ListTile(
                        title: Text(validation.fieldName),
                        subtitle: Text(
                          '${validation.operator.name}: ${validation.errorMessage}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
          
          // Preconditions Section
          Text(
            'Preconditions',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            child: command.preconditions.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'No preconditions',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: command.preconditions.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final precondition = command.preconditions[index];
                      return ListTile(
                        title: Text(precondition.description),
                        subtitle: Text(
                          precondition.expression,
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
          
          // Produced Events Section
          Text(
            'Produced Events',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            child: command.producedEvents.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'No events specified',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: command.producedEvents.length,
                    itemBuilder: (context, index) {
                      final event = command.producedEvents[index];
                      return ListTile(
                        leading: const Icon(Icons.event, size: 20),
                        title: Text(event),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Dialog for creating a new command
class _CreateCommandDialog extends StatefulWidget {
  const _CreateCommandDialog({required this.entities});

  final List<EntityDefinition> entities;

  @override
  State<_CreateCommandDialog> createState() => _CreateCommandDialogState();
}

class _CreateCommandDialogState extends State<_CreateCommandDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedAggregateId;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Command'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g., CreateOrder',
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
                hintText: 'Brief description of the command',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedAggregateId,
              decoration: const InputDecoration(
                labelText: 'Target Aggregate (optional)',
              ),
              items: widget.entities.map((entity) {
                return DropdownMenuItem(
                  value: entity.id,
                  child: Text(entity.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedAggregateId = value;
                });
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
                'name': _nameController.text,
                'description': _descriptionController.text.isEmpty
                    ? null
                    : _descriptionController.text,
                'aggregateId': _selectedAggregateId,
              });
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}

/// Dialog for adding a field to command payload
class _AddFieldDialog extends StatefulWidget {
  const _AddFieldDialog();

  @override
  State<_AddFieldDialog> createState() => _AddFieldDialogState();
}

class _AddFieldDialogState extends State<_AddFieldDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _required = false;
  FieldSourceType _sourceType = FieldSourceType.uiInput;

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Field'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
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
                controller: _typeController,
                decoration: const InputDecoration(
                  labelText: 'Field Type',
                  hintText: 'e.g., String, int, CustomerId',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a field type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<FieldSourceType>(
                value: _sourceType,
                decoration: const InputDecoration(
                  labelText: 'Source Type',
                ),
                items: FieldSourceType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _sourceType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Required'),
                value: _required,
                onChanged: (value) {
                  setState(() {
                    _required = value ?? false;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Brief description',
                ),
                maxLines: 2,
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
              FieldSource source;
              switch (_sourceType) {
                case FieldSourceType.uiInput:
                  source = const FieldSource.uiInput();
                  break;
                case FieldSourceType.custom:
                  source = const FieldSource.custom();
                  break;
                default:
                  source = const FieldSource.uiInput();
              }

              Navigator.pop(context, {
                'name': _nameController.text,
                'fieldType': _typeController.text,
                'required': _required,
                'source': source,
                'description': _descriptionController.text.isEmpty
                    ? null
                    : _descriptionController.text,
              });
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
