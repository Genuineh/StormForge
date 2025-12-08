import 'package:flutter/material.dart';
import 'package:stormforge_modeler/models/entity_model.dart';
import 'package:stormforge_modeler/services/api/entity_service.dart';

/// Method editor for entity methods.
class MethodEditor extends StatefulWidget {
  const MethodEditor({
    super.key,
    required this.entity,
    required this.entityService,
    required this.onEntityUpdated,
  });

  final EntityDefinition entity;
  final EntityService entityService;
  final void Function(EntityDefinition) onEntityUpdated;

  @override
  State<MethodEditor> createState() => _MethodEditorState();
}

class _MethodEditorState extends State<MethodEditor> {
  Future<void> _addMethod() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const _MethodDialog(),
    );

    if (result == null) return;

    try {
      final updated = await widget.entityService.addMethod(
        entityId: widget.entity.id,
        name: result['name'] as String,
        methodType: result['methodType'] as MethodType,
        returnType: result['returnType'] as String,
        description: result['description'] as String?,
        parameters: result['parameters'] as List<MethodParameter>?,
      );
      widget.onEntityUpdated(updated);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add method: $e')),
        );
      }
    }
  }

  Future<void> _editMethod(EntityMethod method) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _MethodDialog(method: method),
    );

    if (result == null) return;

    try {
      final updated = await widget.entityService.updateMethod(
        entityId: widget.entity.id,
        methodId: method.id,
        name: result['name'] as String,
        methodType: result['methodType'] as MethodType,
        returnType: result['returnType'] as String,
        description: result['description'] as String?,
        parameters: result['parameters'] as List<MethodParameter>?,
      );
      widget.onEntityUpdated(updated);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update method: $e')),
        );
      }
    }
  }

  Future<void> _deleteMethod(EntityMethod method) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Method'),
        content: Text('Are you sure you want to delete "${method.name}"?'),
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
      final updated = await widget.entityService.removeMethod(
        entityId: widget.entity.id,
        methodId: method.id,
      );
      widget.onEntityUpdated(updated);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete method: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const Text(
                'Methods',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _addMethod,
                icon: const Icon(Icons.add),
                label: const Text('Add Method'),
              ),
            ],
          ),
        ),
        Expanded(
          child: widget.entity.methods.isEmpty
              ? const Center(
                  child: Text('No methods yet.\nClick "Add Method" to create one.'),
                )
              : ListView.builder(
                  itemCount: widget.entity.methods.length,
                  itemBuilder: (context, index) {
                    final method = widget.entity.methods[index];
                    return _MethodListItem(
                      method: method,
                      onEdit: () => _editMethod(method),
                      onDelete: () => _deleteMethod(method),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// List item for a method.
class _MethodListItem extends StatelessWidget {
  const _MethodListItem({
    required this.method,
    required this.onEdit,
    required this.onDelete,
  });

  final EntityMethod method;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  IconData _getMethodIcon() {
    switch (method.methodType) {
      case MethodType.constructor:
        return Icons.build;
      case MethodType.command:
        return Icons.send;
      case MethodType.query:
        return Icons.search;
      case MethodType.domainLogic:
        return Icons.functions;
    }
  }

  @override
  Widget build(BuildContext context) {
    final params = method.parameters
        .map((p) => '${p.name}: ${p.parameterType}')
        .join(', ');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Icon(_getMethodIcon()),
        title: Text(method.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Returns: ${method.returnType}'),
            if (params.isNotEmpty) Text('Parameters: $params'),
            if (method.description != null) Text(method.description!),
            Chip(
              label: Text(_formatMethodType(method.methodType)),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }

  String _formatMethodType(MethodType type) {
    switch (type) {
      case MethodType.constructor:
        return 'Constructor';
      case MethodType.command:
        return 'Command';
      case MethodType.query:
        return 'Query';
      case MethodType.domainLogic:
        return 'Domain Logic';
    }
  }
}

/// Dialog for creating or editing a method.
class _MethodDialog extends StatefulWidget {
  const _MethodDialog({this.method});

  final EntityMethod? method;

  @override
  State<_MethodDialog> createState() => _MethodDialogState();
}

class _MethodDialogState extends State<_MethodDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _returnTypeController;
  late TextEditingController _descriptionController;
  late MethodType _methodType;
  List<MethodParameter> _parameters = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.method?.name ?? '');
    _returnTypeController = TextEditingController(text: widget.method?.returnType ?? 'void');
    _descriptionController = TextEditingController(text: widget.method?.description ?? '');
    _methodType = widget.method?.methodType ?? MethodType.domainLogic;
    _parameters = List.from(widget.method?.parameters ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _returnTypeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _addParameter() async {
    final result = await showDialog<MethodParameter>(
      context: context,
      builder: (context) => const _ParameterDialog(),
    );

    if (result != null) {
      setState(() {
        _parameters.add(result);
      });
    }
  }

  void _deleteParameter(int index) {
    setState(() {
      _parameters.removeAt(index);
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'name': _nameController.text,
        'methodType': _methodType,
        'returnType': _returnTypeController.text,
        'description': _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        'parameters': _parameters,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.method == null ? 'Add Method' : 'Edit Method'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Name is required' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<MethodType>(
                  value: _methodType,
                  decoration: const InputDecoration(labelText: 'Method Type'),
                  items: MethodType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_formatMethodType(type)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _methodType = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _returnTypeController,
                  decoration: const InputDecoration(labelText: 'Return Type'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Return type is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Parameters', style: TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _addParameter,
                      tooltip: 'Add Parameter',
                    ),
                  ],
                ),
                ..._parameters.asMap().entries.map((entry) {
                  final index = entry.key;
                  final param = entry.value;
                  return ListTile(
                    dense: true,
                    title: Text('${param.name}: ${param.parameterType}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, size: 18),
                      onPressed: () => _deleteParameter(index),
                    ),
                  );
                }),
              ],
            ),
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
          child: const Text('Save'),
        ),
      ],
    );
  }

  String _formatMethodType(MethodType type) {
    switch (type) {
      case MethodType.constructor:
        return 'Constructor';
      case MethodType.command:
        return 'Command';
      case MethodType.query:
        return 'Query';
      case MethodType.domainLogic:
        return 'Domain Logic';
    }
  }
}

/// Dialog for creating a parameter.
class _ParameterDialog extends StatefulWidget {
  const _ParameterDialog();

  @override
  State<_ParameterDialog> createState() => _ParameterDialogState();
}

class _ParameterDialogState extends State<_ParameterDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _defaultValueController = TextEditingController();
  bool _required = true;

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _defaultValueController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final param = MethodParameter(
        name: _nameController.text,
        parameterType: _typeController.text,
        required: _required,
        defaultValue: _defaultValueController.text.isEmpty
            ? null
            : _defaultValueController.text,
      );
      Navigator.pop(context, param);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Parameter'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Name is required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _typeController,
              decoration: const InputDecoration(labelText: 'Type'),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Type is required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _defaultValueController,
              decoration: const InputDecoration(labelText: 'Default Value (optional)'),
            ),
            CheckboxListTile(
              title: const Text('Required'),
              value: _required,
              onChanged: (value) => setState(() => _required = value ?? true),
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
          onPressed: _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
