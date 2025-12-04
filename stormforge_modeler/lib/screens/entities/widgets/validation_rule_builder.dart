import 'package:flutter/material.dart';
import 'package:stormforge_modeler/models/entity_model.dart';

/// Validation rule builder dialog.
class ValidationRuleBuilder extends StatefulWidget {
  const ValidationRuleBuilder({
    super.key,
    required this.validations,
  });

  final List<ValidationRule> validations;

  @override
  State<ValidationRuleBuilder> createState() => _ValidationRuleBuilderState();
}

class _ValidationRuleBuilderState extends State<ValidationRuleBuilder> {
  late List<ValidationRule> _validations;

  @override
  void initState() {
    super.initState();
    _validations = List.from(widget.validations);
  }

  Future<void> _addValidation() async {
    final rule = await showDialog<ValidationRule>(
      context: context,
      builder: (context) => const _ValidationRuleDialog(),
    );

    if (rule != null) {
      setState(() {
        _validations.add(rule);
      });
    }
  }

  Future<void> _editValidation(int index) async {
    final rule = await showDialog<ValidationRule>(
      context: context,
      builder: (context) => _ValidationRuleDialog(rule: _validations[index]),
    );

    if (rule != null) {
      setState(() {
        _validations[index] = rule;
      });
    }
  }

  void _deleteValidation(int index) {
    setState(() {
      _validations.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Validation Rules'),
      content: SizedBox(
        width: 500,
        height: 400,
        child: Column(
          children: [
            Row(
              children: [
                const Text('Define validation rules for this property'),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addValidation,
                  tooltip: 'Add Validation',
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: _validations.isEmpty
                  ? const Center(
                      child: Text('No validation rules.\nClick + to add one.'),
                    )
                  : ListView.builder(
                      itemCount: _validations.length,
                      itemBuilder: (context, index) {
                        final validation = _validations[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.rule),
                            title: Text(_formatValidationType(validation.validationType)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (validation.value != null)
                                  Text('Value: ${validation.value}'),
                                if (validation.errorMessage != null)
                                  Text('Error: ${validation.errorMessage}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _editValidation(index),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteValidation(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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
          onPressed: () => Navigator.pop(context, _validations),
          child: const Text('Save'),
        ),
      ],
    );
  }

  String _formatValidationType(ValidationType type) {
    switch (type) {
      case ValidationType.required:
        return 'Required';
      case ValidationType.minLength:
        return 'Minimum Length';
      case ValidationType.maxLength:
        return 'Maximum Length';
      case ValidationType.min:
        return 'Minimum Value';
      case ValidationType.max:
        return 'Maximum Value';
      case ValidationType.pattern:
        return 'Pattern (Regex)';
      case ValidationType.email:
        return 'Email';
      case ValidationType.url:
        return 'URL';
      case ValidationType.custom:
        return 'Custom';
    }
  }
}

/// Dialog for creating/editing a validation rule.
class _ValidationRuleDialog extends StatefulWidget {
  const _ValidationRuleDialog({this.rule});

  final ValidationRule? rule;

  @override
  State<_ValidationRuleDialog> createState() => _ValidationRuleDialogState();
}

class _ValidationRuleDialogState extends State<_ValidationRuleDialog> {
  final _formKey = GlobalKey<FormState>();
  late ValidationType _type;
  final _valueController = TextEditingController();
  final _errorMessageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _type = widget.rule?.validationType ?? ValidationType.required;
    _valueController.text = widget.rule?.value?.toString() ?? '';
    _errorMessageController.text = widget.rule?.errorMessage ?? '';
  }

  @override
  void dispose() {
    _valueController.dispose();
    _errorMessageController.dispose();
    super.dispose();
  }

  bool _requiresValue() {
    return _type != ValidationType.required &&
        _type != ValidationType.email &&
        _type != ValidationType.url;
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final rule = ValidationRule.create(
        validationType: _type,
        value: _requiresValue() && _valueController.text.isNotEmpty
            ? _parseValue(_valueController.text)
            : null,
        errorMessage: _errorMessageController.text.isEmpty
            ? null
            : _errorMessageController.text,
      );
      Navigator.pop(context, rule);
    }
  }

  dynamic _parseValue(String text) {
    // Try to parse as number if it's a numeric validation
    if (_type == ValidationType.min ||
        _type == ValidationType.max ||
        _type == ValidationType.minLength ||
        _type == ValidationType.maxLength) {
      return int.tryParse(text) ?? double.tryParse(text) ?? text;
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.rule == null ? 'Add Validation' : 'Edit Validation'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<ValidationType>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Validation Type'),
                items: ValidationType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_formatValidationType(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _type = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              if (_requiresValue())
                TextFormField(
                  controller: _valueController,
                  decoration: InputDecoration(
                    labelText: _getValueLabel(),
                    hintText: _getValueHint(),
                  ),
                  validator: (value) {
                    if (_requiresValue() && (value?.isEmpty ?? true)) {
                      return 'Value is required for this validation type';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _errorMessageController,
                decoration: const InputDecoration(
                  labelText: 'Error Message (optional)',
                  hintText: 'Custom error message',
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
          onPressed: _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }

  String _formatValidationType(ValidationType type) {
    switch (type) {
      case ValidationType.required:
        return 'Required';
      case ValidationType.minLength:
        return 'Minimum Length';
      case ValidationType.maxLength:
        return 'Maximum Length';
      case ValidationType.min:
        return 'Minimum Value';
      case ValidationType.max:
        return 'Maximum Value';
      case ValidationType.pattern:
        return 'Pattern (Regex)';
      case ValidationType.email:
        return 'Email';
      case ValidationType.url:
        return 'URL';
      case ValidationType.custom:
        return 'Custom';
    }
  }

  String _getValueLabel() {
    switch (_type) {
      case ValidationType.minLength:
      case ValidationType.maxLength:
        return 'Length';
      case ValidationType.min:
      case ValidationType.max:
        return 'Value';
      case ValidationType.pattern:
        return 'Regular Expression';
      case ValidationType.custom:
        return 'Custom Expression';
      default:
        return 'Value';
    }
  }

  String _getValueHint() {
    switch (_type) {
      case ValidationType.minLength:
      case ValidationType.maxLength:
        return 'e.g., 10';
      case ValidationType.min:
      case ValidationType.max:
        return 'e.g., 0';
      case ValidationType.pattern:
        return r'e.g., ^[A-Z][a-z]+$';
      case ValidationType.custom:
        return 'e.g., value > 0 && value < 100';
      default:
        return '';
    }
  }
}
