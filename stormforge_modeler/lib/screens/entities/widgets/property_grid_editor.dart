import 'package:flutter/material.dart';
import 'package:stormforge_modeler/models/entity_model.dart';
import 'package:stormforge_modeler/services/api/entity_service.dart';
import 'package:stormforge_modeler/screens/entities/widgets/type_selector.dart';
import 'package:stormforge_modeler/screens/entities/widgets/validation_rule_builder.dart';

/// Grid editor for entity properties.
class PropertyGridEditor extends StatefulWidget {
  const PropertyGridEditor({
    super.key,
    required this.entity,
    required this.entityService,
    required this.onEntityUpdated,
  });

  final EntityDefinition entity;
  final EntityService entityService;
  final void Function(EntityDefinition) onEntityUpdated;

  @override
  State<PropertyGridEditor> createState() => _PropertyGridEditorState();
}

class _PropertyGridEditorState extends State<PropertyGridEditor> {
  Future<void> _addProperty() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const _PropertyDialog(),
    );

    if (result == null) return;

    try {
      final updated = await widget.entityService.addProperty(
        entityId: widget.entity.id,
        name: result['name'] as String,
        propertyType: result['propertyType'] as String,
        required: result['required'] as bool,
        isIdentifier: result['isIdentifier'] as bool,
        isReadOnly: result['isReadOnly'] as bool,
        defaultValue: result['defaultValue'],
        description: result['description'] as String?,
        validations: result['validations'] as List<ValidationRule>?,
      );
      widget.onEntityUpdated(updated);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add property: $e')),
        );
      }
    }
  }

  Future<void> _editProperty(EntityProperty property) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _PropertyDialog(property: property),
    );

    if (result == null) return;

    try {
      final updated = await widget.entityService.updateProperty(
        entityId: widget.entity.id,
        propertyId: property.id,
        name: result['name'] as String,
        propertyType: result['propertyType'] as String,
        required: result['required'] as bool,
        isIdentifier: result['isIdentifier'] as bool,
        isReadOnly: result['isReadOnly'] as bool,
        defaultValue: result['defaultValue'],
        description: result['description'] as String?,
        validations: result['validations'] as List<ValidationRule>?,
      );
      widget.onEntityUpdated(updated);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update property: $e')),
        );
      }
    }
  }

  Future<void> _deleteProperty(EntityProperty property) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Property'),
        content: Text('Are you sure you want to delete "${property.name}"?'),
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
      final updated = await widget.entityService.removeProperty(
        entityId: widget.entity.id,
        propertyId: property.id,
      );
      widget.onEntityUpdated(updated);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete property: $e')),
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
                'Properties',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _addProperty,
                icon: const Icon(Icons.add),
                label: const Text('Add Property'),
              ),
            ],
          ),
        ),
        Expanded(
          child: widget.entity.properties.isEmpty
              ? const Center(
                  child: Text('No properties yet.\nClick "Add Property" to create one.'),
                )
              : ListView.builder(
                  itemCount: widget.entity.properties.length,
                  itemBuilder: (context, index) {
                    final property = widget.entity.properties[index];
                    return _PropertyListItem(
                      property: property,
                      onEdit: () => _editProperty(property),
                      onDelete: () => _deleteProperty(property),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// List item for a property.
class _PropertyListItem extends StatelessWidget {
  const _PropertyListItem({
    required this.property,
    required this.onEdit,
    required this.onDelete,
  });

  final EntityProperty property;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Icon(
          property.isIdentifier
              ? Icons.key
              : property.isReadOnly
                  ? Icons.lock
                  : Icons.view_column,
        ),
        title: Text(property.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${property.propertyType}'),
            if (property.description != null) Text(property.description!),
            Wrap(
              spacing: 4,
              children: [
                if (property.required) const Chip(label: Text('Required'), padding: EdgeInsets.zero),
                if (property.isIdentifier) const Chip(label: Text('ID'), padding: EdgeInsets.zero),
                if (property.isReadOnly) const Chip(label: Text('Read-only'), padding: EdgeInsets.zero),
                if (property.validations.isNotEmpty)
                  Chip(
                    label: Text('${property.validations.length} validations'),
                    padding: EdgeInsets.zero,
                  ),
              ],
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
}

/// Dialog for creating or editing a property.
class _PropertyDialog extends StatefulWidget {
  const _PropertyDialog({this.property});

  final EntityProperty? property;

  @override
  State<_PropertyDialog> createState() => _PropertyDialogState();
}

class _PropertyDialogState extends State<_PropertyDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _typeController;
  late TextEditingController _descriptionController;
  late TextEditingController _defaultValueController;
  late bool _required;
  late bool _isIdentifier;
  late bool _isReadOnly;
  List<ValidationRule> _validations = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.property?.name ?? '');
    _typeController = TextEditingController(text: widget.property?.propertyType ?? '');
    _descriptionController = TextEditingController(text: widget.property?.description ?? '');
    _defaultValueController = TextEditingController(
      text: widget.property?.defaultValue?.toString() ?? '',
    );
    _required = widget.property?.required ?? false;
    _isIdentifier = widget.property?.isIdentifier ?? false;
    _isReadOnly = widget.property?.isReadOnly ?? false;
    _validations = List.from(widget.property?.validations ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _descriptionController.dispose();
    _defaultValueController.dispose();
    super.dispose();
  }

  Future<void> _selectType() async {
    final type = await showDialog<String>(
      context: context,
      builder: (context) => const TypeSelector(),
    );
    if (type != null) {
      setState(() {
        _typeController.text = type;
      });
    }
  }

  Future<void> _manageValidations() async {
    final result = await showDialog<List<ValidationRule>>(
      context: context,
      builder: (context) => ValidationRuleBuilder(validations: _validations),
    );
    if (result != null) {
      setState(() {
        _validations = result;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'name': _nameController.text,
        'propertyType': _typeController.text,
        'required': _required,
        'isIdentifier': _isIdentifier,
        'isReadOnly': _isReadOnly,
        'defaultValue': _defaultValueController.text.isEmpty
            ? null
            : _defaultValueController.text,
        'description': _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        'validations': _validations,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.property == null ? 'Add Property' : 'Edit Property'),
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
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _typeController,
                        decoration: const InputDecoration(labelText: 'Type'),
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Type is required' : null,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _selectType,
                      tooltip: 'Select Type',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _defaultValueController,
                  decoration: const InputDecoration(labelText: 'Default Value'),
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  title: const Text('Required'),
                  value: _required,
                  onChanged: (value) => setState(() => _required = value ?? false),
                ),
                CheckboxListTile(
                  title: const Text('Identifier'),
                  value: _isIdentifier,
                  onChanged: (value) => setState(() => _isIdentifier = value ?? false),
                ),
                CheckboxListTile(
                  title: const Text('Read-only'),
                  value: _isReadOnly,
                  onChanged: (value) => setState(() => _isReadOnly = value ?? false),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _manageValidations,
                  icon: const Icon(Icons.rule),
                  label: Text('Validations (${_validations.length})'),
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
