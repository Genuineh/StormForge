import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stormforge_modeler/models/project_model.dart';
import 'package:stormforge_modeler/services/providers.dart';

/// Screen for creating a new project or editing an existing one.
class ProjectFormScreen extends ConsumerStatefulWidget {
  const ProjectFormScreen({
    super.key,
    this.projectId,
  });

  final String? projectId;

  @override
  ConsumerState<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends ConsumerState<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _namespaceController = TextEditingController();
  final _descriptionController = TextEditingController();
  ProjectVisibility _visibility = ProjectVisibility.private;
  bool _isLoading = false;

  bool get isEditing => widget.projectId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _loadProject();
    }
  }

  Future<void> _loadProject() async {
    setState(() => _isLoading = true);
    try {
      final projectService = ref.read(projectServiceProvider);
      final project = await projectService.getProject(widget.projectId!);
      _nameController.text = project.name;
      _namespaceController.text = project.namespace;
      _descriptionController.text = project.description;
      _visibility = project.visibility;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load project: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _namespaceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final projectService = ref.read(projectServiceProvider);
      final authState = ref.read(authProvider);
      final user = authState.valueOrNull;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      if (isEditing) {
        await projectService.updateProject(
          projectId: widget.projectId!,
          name: _nameController.text.trim(),
          namespace: _namespaceController.text.trim(),
          description: _descriptionController.text.trim(),
          visibility: _visibility,
        );
      } else {
        await projectService.createProject(
          name: _nameController.text.trim(),
          namespace: _namespaceController.text.trim(),
          ownerId: user.id,
          description: _descriptionController.text.trim(),
          visibility: _visibility,
        );
      }

      if (mounted) {
        context.go('/projects');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save project: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Project' : 'New Project'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Project Name',
                            hintText: 'My Awesome Project',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a project name';
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _namespaceController,
                          decoration: const InputDecoration(
                            labelText: 'Namespace',
                            hintText: 'my_project',
                            helperText: 'Used for code generation (lowercase, underscores)',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a namespace';
                            }
                            if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(value)) {
                              return 'Must start with lowercase letter, contain only lowercase letters, numbers, and underscores';
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description (Optional)',
                            hintText: 'A brief description of your project',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                          textInputAction: TextInputAction.done,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<ProjectVisibility>(
                          value: _visibility,
                          decoration: const InputDecoration(
                            labelText: 'Visibility',
                            border: OutlineInputBorder(),
                          ),
                          itemHeight: 60, // 增加每个选项的高度
                          items: [
                            DropdownMenuItem(
                              value: ProjectVisibility.private,
                              child: ClipRect(
                                child: Row(
                                  children: [
                                    const Icon(Icons.lock, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Private\nOnly you can see this',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        fontSize: 10,
                                        height: 1.0,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: ProjectVisibility.team,
                              child: ClipRect(
                                child: Row(
                                  children: [
                                    const Icon(Icons.group, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Team\nTeam members can see this',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        fontSize: 10,
                                        height: 1.0,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: ProjectVisibility.public,
                              child: ClipRect(
                                child: Row(
                                  children: [
                                    const Icon(Icons.public, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Public\nAnyone can see this',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        fontSize: 10,
                                        height: 1.0,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _visibility = value);
                            }
                          },
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => context.pop(),
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 16),
                            FilledButton(
                              onPressed: _handleSave,
                              child: Text(isEditing ? 'Save' : 'Create'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
