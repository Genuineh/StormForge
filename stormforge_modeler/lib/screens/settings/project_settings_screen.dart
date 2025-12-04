import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stormforge_modeler/models/project_model.dart';
import 'package:stormforge_modeler/services/providers.dart';

/// Project settings screen.
class ProjectSettingsScreen extends ConsumerStatefulWidget {
  const ProjectSettingsScreen({
    super.key,
    required this.projectId,
  });

  final String projectId;

  @override
  ConsumerState<ProjectSettingsScreen> createState() =>
      _ProjectSettingsScreenState();
}

class _ProjectSettingsScreenState
    extends ConsumerState<ProjectSettingsScreen> {
  Project? _project;
  bool _isLoading = true;

  // Git settings
  final _gitEnabledController = ValueNotifier<bool>(false);
  final _autoCommitController = ValueNotifier<bool>(true);
  final _commitMessageController = TextEditingController();
  final _repositoryUrlController = TextEditingController();
  final _branchController = TextEditingController();

  // AI settings
  final _aiEnabledController = ValueNotifier<bool>(false);
  final _aiProviderController = TextEditingController();
  final _aiModelController = TextEditingController();
  final _temperatureController = ValueNotifier<double>(0.7);

  @override
  void initState() {
    super.initState();
    _loadProject();
  }

  Future<void> _loadProject() async {
    setState(() => _isLoading = true);
    try {
      final projectService = ref.read(projectServiceProvider);
      final project = await projectService.getProject(widget.projectId);
      setState(() => _project = project);

      // Load Git settings
      final git = project.settings.gitIntegration;
      _gitEnabledController.value = git.enabled;
      _autoCommitController.value = git.autoCommit;
      _commitMessageController.text = git.commitMessage;
      _repositoryUrlController.text = git.repositoryUrl;
      _branchController.text = git.branch;

      // Load AI settings
      final ai = project.settings.aiSettings;
      _aiEnabledController.value = ai.enabled;
      _aiProviderController.text = ai.provider;
      _aiModelController.text = ai.model;
      _temperatureController.value = ai.temperature;
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
    _gitEnabledController.dispose();
    _autoCommitController.dispose();
    _commitMessageController.dispose();
    _repositoryUrlController.dispose();
    _branchController.dispose();
    _aiEnabledController.dispose();
    _aiProviderController.dispose();
    _aiModelController.dispose();
    _temperatureController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    if (_project == null) return;

    try {
      final newSettings = ProjectSettings(
        gitIntegration: GitIntegrationSettings(
          enabled: _gitEnabledController.value,
          autoCommit: _autoCommitController.value,
          commitMessage: _commitMessageController.text,
          repositoryUrl: _repositoryUrlController.text,
          branch: _branchController.text,
        ),
        aiSettings: AISettings(
          enabled: _aiEnabledController.value,
          provider: _aiProviderController.text,
          model: _aiModelController.text,
          temperature: _temperatureController.value,
        ),
      );

      final projectService = ref.read(projectServiceProvider);
      await projectService.updateProject(
        projectId: widget.projectId,
        settings: newSettings,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Project Settings')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_project == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Project Settings')),
        body: const Center(child: Text('Project not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${_project!.name} Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
            tooltip: 'Save Settings',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Git Integration Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.source),
                      const SizedBox(width: 8),
                      Text(
                        'Git Integration',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ValueListenableBuilder<bool>(
                    valueListenable: _gitEnabledController,
                    builder: (context, enabled, _) {
                      return SwitchListTile(
                        title: const Text('Enable Git Integration'),
                        subtitle: const Text('Auto-save to Git repository'),
                        value: enabled,
                        onChanged: (value) {
                          _gitEnabledController.value = value;
                        },
                      );
                    },
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: _gitEnabledController,
                    builder: (context, gitEnabled, _) {
                      if (!gitEnabled) return const SizedBox.shrink();
                      return Column(
                        children: [
                          ValueListenableBuilder<bool>(
                            valueListenable: _autoCommitController,
                            builder: (context, autoCommit, _) {
                              return SwitchListTile(
                                title: const Text('Auto-commit on save'),
                                value: autoCommit,
                                onChanged: (value) {
                                  _autoCommitController.value = value;
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _repositoryUrlController,
                            decoration: const InputDecoration(
                              labelText: 'Repository URL',
                              hintText: 'https://github.com/user/repo.git',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _branchController,
                            decoration: const InputDecoration(
                              labelText: 'Branch',
                              hintText: 'main',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _commitMessageController,
                            decoration: const InputDecoration(
                              labelText: 'Default Commit Message',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // AI Settings Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.smart_toy),
                      const SizedBox(width: 8),
                      Text(
                        'AI Generation',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ValueListenableBuilder<bool>(
                    valueListenable: _aiEnabledController,
                    builder: (context, enabled, _) {
                      return SwitchListTile(
                        title: const Text('Enable AI Generation'),
                        subtitle: const Text('Use AI to generate models'),
                        value: enabled,
                        onChanged: (value) {
                          _aiEnabledController.value = value;
                        },
                      );
                    },
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: _aiEnabledController,
                    builder: (context, aiEnabled, _) {
                      if (!aiEnabled) return const SizedBox.shrink();
                      return Column(
                        children: [
                          const SizedBox(height: 8),
                          TextField(
                            controller: _aiProviderController,
                            decoration: const InputDecoration(
                              labelText: 'Provider',
                              hintText: 'claude',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _aiModelController,
                            decoration: const InputDecoration(
                              labelText: 'Model',
                              hintText: 'claude-3-5-sonnet',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ValueListenableBuilder<double>(
                            valueListenable: _temperatureController,
                            builder: (context, temperature, _) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Temperature: ${temperature.toStringAsFixed(1)}'),
                                  Slider(
                                    value: temperature,
                                    min: 0.0,
                                    max: 1.0,
                                    divisions: 10,
                                    label: temperature.toStringAsFixed(1),
                                    onChanged: (value) {
                                      _temperatureController.value = value;
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: _saveSettings,
          child: const Padding(
            padding: EdgeInsets.all(12),
            child: Text('Save Settings'),
          ),
        ),
      ),
    );
  }
}
