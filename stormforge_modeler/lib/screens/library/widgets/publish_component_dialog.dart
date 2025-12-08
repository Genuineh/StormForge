import 'package:flutter/material.dart';

import 'package:stormforge_modeler/models/library_model.dart';
import 'package:stormforge_modeler/services/api/library_service.dart';

/// Dialog for publishing a new component to the library.
class PublishComponentDialog extends StatefulWidget {
  const PublishComponentDialog({
    super.key,
    required this.projectId,
    required this.libraryService,
  });

  final String projectId;
  final LibraryService libraryService;

  @override
  State<PublishComponentDialog> createState() => _PublishComponentDialogState();
}

class _PublishComponentDialogState extends State<PublishComponentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _namespaceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _versionController = TextEditingController(text: '1.0.0');
  final _authorController = TextEditingController();
  final _tagsController = TextEditingController();

  LibraryScope _selectedScope = LibraryScope.project;
  ComponentType _selectedType = ComponentType.entity;
  bool _isPublishing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _namespaceController.dispose();
    _descriptionController.dispose();
    _versionController.dispose();
    _authorController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isPublishing = true);

    try {
      // Parse tags from comma-separated string
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      // Create a simple definition based on type
      final definition = {
        'type': _selectedType.toJson(),
        'name': _nameController.text,
        'description': _descriptionController.text,
      };

      await widget.libraryService.publishComponent(
        name: _nameController.text,
        namespace: _namespaceController.text,
        scope: _selectedScope,
        componentType: _selectedType,
        version: _versionController.text,
        description: _descriptionController.text,
        author: _authorController.text.isNotEmpty ? _authorController.text : null,
        tags: tags.isNotEmpty ? tags : null,
        definition: definition,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Component published successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to publish component: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPublishing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.publish, size: 32),
                  const SizedBox(width: 12),
                  Text(
                    'Publish Component',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Form fields
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name *',
                          hintText: 'e.g., Money',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Namespace
                      TextFormField(
                        controller: _namespaceController,
                        decoration: const InputDecoration(
                          labelText: 'Namespace *',
                          hintText: 'e.g., com.company.common.Money',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Namespace is required';
                          }
                          if (!RegExp(r'^[a-zA-Z][a-zA-Z0-9_.]*$').hasMatch(value)) {
                            return 'Invalid namespace format';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Type and Scope
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<ComponentType>(
                              value: _selectedType,
                              decoration: const InputDecoration(
                                labelText: 'Type *',
                                border: OutlineInputBorder(),
                              ),
                              items: ComponentType.values.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(type.displayName),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _selectedType = value);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<LibraryScope>(
                              value: _selectedScope,
                              decoration: const InputDecoration(
                                labelText: 'Scope *',
                                border: OutlineInputBorder(),
                              ),
                              items: LibraryScope.values.map((scope) {
                                return DropdownMenuItem(
                                  value: scope,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(scope.displayName),
                                      Text(
                                        scope.description,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _selectedScope = value);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Version
                      TextFormField(
                        controller: _versionController,
                        decoration: const InputDecoration(
                          labelText: 'Version *',
                          hintText: 'e.g., 1.0.0',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Version is required';
                          }
                          if (!RegExp(r'^\d+\.\d+\.\d+$').hasMatch(value)) {
                            return 'Version must be in format X.Y.Z';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description *',
                          hintText: 'Describe the component...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Description is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Author
                      TextFormField(
                        controller: _authorController,
                        decoration: const InputDecoration(
                          labelText: 'Author',
                          hintText: 'Your name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Tags
                      TextFormField(
                        controller: _tagsController,
                        decoration: const InputDecoration(
                          labelText: 'Tags',
                          hintText: 'comma, separated, tags',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Separate tags with commas',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isPublishing ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: _isPublishing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.publish),
                    label: Text(_isPublishing ? 'Publishing...' : 'Publish'),
                    onPressed: _isPublishing ? null : _publish,
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
