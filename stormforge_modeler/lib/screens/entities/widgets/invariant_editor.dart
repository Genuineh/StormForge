import 'package:flutter/material.dart';
import 'package:stormforge_modeler/models/entity_model.dart';
import 'package:stormforge_modeler/services/api/entity_service.dart';

/// Invariant editor for entity business rules.
class InvariantEditor extends StatefulWidget {
  const InvariantEditor({
    super.key,
    required this.entity,
    required this.entityService,
    required this.onEntityUpdated,
  });

  final EntityDefinition entity;
  final EntityService entityService;
  final void Function(EntityDefinition) onEntityUpdated;

  @override
  State<InvariantEditor> createState() => _InvariantEditorState();
}

class _InvariantEditorState extends State<InvariantEditor> {
  Future<void> _addInvariant() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const _InvariantDialog(),
    );

    if (result == null) return;

    try {
      final updated = await widget.entityService.addInvariant(
        entityId: widget.entity.id,
        name: result['name'] as String,
        expression: result['expression'] as String,
        errorMessage: result['errorMessage'] as String,
        enabled: result['enabled'] as bool,
      );
      widget.onEntityUpdated(updated);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add invariant: $e')),
        );
      }
    }
  }

  Future<void> _editInvariant(EntityInvariant invariant) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _InvariantDialog(invariant: invariant),
    );

    if (result == null) return;

    try {
      final updated = await widget.entityService.updateInvariant(
        entityId: widget.entity.id,
        invariantId: invariant.id,
        name: result['name'] as String,
        expression: result['expression'] as String,
        errorMessage: result['errorMessage'] as String,
        enabled: result['enabled'] as bool,
      );
      widget.onEntityUpdated(updated);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update invariant: $e')),
        );
      }
    }
  }

  Future<void> _deleteInvariant(EntityInvariant invariant) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Invariant'),
        content: Text('Are you sure you want to delete "${invariant.name}"?'),
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
      final updated = await widget.entityService.removeInvariant(
        entityId: widget.entity.id,
        invariantId: invariant.id,
      );
      widget.onEntityUpdated(updated);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete invariant: $e')),
        );
      }
    }
  }

  Future<void> _toggleInvariant(EntityInvariant invariant) async {
    try {
      final updated = await widget.entityService.updateInvariant(
        entityId: widget.entity.id,
        invariantId: invariant.id,
        enabled: !invariant.enabled,
      );
      widget.onEntityUpdated(updated);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to toggle invariant: $e')),
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
                'Invariants',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _addInvariant,
                icon: const Icon(Icons.add),
                label: const Text('Add Invariant'),
              ),
            ],
          ),
        ),
        Expanded(
          child: widget.entity.invariants.isEmpty
              ? const Center(
                  child: Text('No invariants yet.\nClick "Add Invariant" to create one.'),
                )
              : ListView.builder(
                  itemCount: widget.entity.invariants.length,
                  itemBuilder: (context, index) {
                    final invariant = widget.entity.invariants[index];
                    return _InvariantListItem(
                      invariant: invariant,
                      onEdit: () => _editInvariant(invariant),
                      onDelete: () => _deleteInvariant(invariant),
                      onToggle: () => _toggleInvariant(invariant),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// List item for an invariant.
class _InvariantListItem extends StatelessWidget {
  const _InvariantListItem({
    required this.invariant,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  final EntityInvariant invariant;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: invariant.enabled ? null : Colors.grey.shade200,
      child: ListTile(
        leading: Icon(
          Icons.rule,
          color: invariant.enabled ? Colors.blue : Colors.grey,
        ),
        title: Text(
          invariant.name,
          style: TextStyle(
            decoration: invariant.enabled ? null : TextDecoration.lineThrough,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Expression: ${invariant.expression}'),
            Text('Error: ${invariant.errorMessage}'),
            Chip(
              label: Text(invariant.enabled ? 'Enabled' : 'Disabled'),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(invariant.enabled ? Icons.check_circle : Icons.cancel),
              onPressed: onToggle,
              tooltip: invariant.enabled ? 'Disable' : 'Enable',
            ),
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
}

/// Dialog for creating or editing an invariant.
class _InvariantDialog extends StatefulWidget {
  const _InvariantDialog({this.invariant});

  final EntityInvariant? invariant;

  @override
  State<_InvariantDialog> createState() => _InvariantDialogState();
}

class _InvariantDialogState extends State<_InvariantDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _expressionController;
  late TextEditingController _errorMessageController;
  late bool _enabled;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.invariant?.name ?? '');
    _expressionController = TextEditingController(text: widget.invariant?.expression ?? '');
    _errorMessageController = TextEditingController(text: widget.invariant?.errorMessage ?? '');
    _enabled = widget.invariant?.enabled ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _expressionController.dispose();
    _errorMessageController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'name': _nameController.text,
        'expression': _expressionController.text,
        'errorMessage': _errorMessageController.text,
        'enabled': _enabled,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.invariant == null ? 'Add Invariant' : 'Edit Invariant'),
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
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'e.g., OrderMustHaveItems',
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Name is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _expressionController,
                  decoration: const InputDecoration(
                    labelText: 'Expression',
                    hintText: 'e.g., items.length > 0',
                  ),
                  maxLines: 3,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Expression is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _errorMessageController,
                  decoration: const InputDecoration(
                    labelText: 'Error Message',
                    hintText: 'Message to display when invariant is violated',
                  ),
                  maxLines: 2,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Error message is required' : null,
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  title: const Text('Enabled'),
                  value: _enabled,
                  onChanged: (value) => setState(() => _enabled = value ?? true),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Invariant Tips:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text('• Use property names directly (e.g., total > 0)'),
                      Text('• Use collection operations (e.g., items.length > 0)'),
                      Text('• Combine conditions with && and ||'),
                      Text('• Invariants must always be true for the entity'),
                    ],
                  ),
                ),
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
}
