import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stormforge_modeler/models/project_model.dart';
import 'package:stormforge_modeler/services/providers.dart';
import 'package:stormforge_modeler/widgets/workspace_layout.dart';

/// Dashboard screen for a specific project.
class ProjectDashboardScreen extends ConsumerStatefulWidget {
  const ProjectDashboardScreen({
    super.key,
    required this.projectId,
  });

  final String projectId;

  @override
  ConsumerState<ProjectDashboardScreen> createState() => _ProjectDashboardScreenState();
}

class _ProjectDashboardScreenState extends ConsumerState<ProjectDashboardScreen> {
  Project? _project;
  bool _isLoading = true;
  String? _error;

  // Stats
  int _entityCount = 0;
  int _commandCount = 0;
  int _readModelCount = 0;
  int _connectionCount = 0;

  @override
  void initState() {
    super.initState();
    _loadProjectData();
  }

  Future<void> _loadProjectData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Use cached providers for better performance
      final projectAsync = ref.read(projectProvider(widget.projectId).future);
      final entitiesAsync = ref.read(entitiesProvider(widget.projectId).future);
      final commandsAsync = ref.read(commandsProvider(widget.projectId).future);
      final readModelsAsync = ref.read(readModelsProvider(widget.projectId).future);
      final connectionsAsync = ref.read(connectionsProvider(widget.projectId).future);

      // Load all data in parallel
      final results = await Future.wait([
        projectAsync,
        entitiesAsync,
        commandsAsync,
        readModelsAsync,
        connectionsAsync,
      ]);

      final project = results[0] as Project;
      final entities = results[1] as List;
      final commands = results[2] as List;
      final readModels = results[3] as List;
      final connections = results[4] as List;
      
      setState(() {
        _project = project;
        _entityCount = entities.length;
        _commandCount = commands.length;
        _readModelCount = readModels.length;
        _connectionCount = connections.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load project: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              Text(_error!),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loadProjectData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_project == null) {
      return const Scaffold(
        body: Center(child: Text('Project not found')),
      );
    }

    return WorkspaceLayout(
      projectId: widget.projectId,
      projectName: _project!.name,
      showLeftPanel: false,
      showRightPanel: false,
      child: _buildDashboardContent(context),
    );
  }

  Widget _buildDashboardContent(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () async {
        // Invalidate cached providers to force refresh
        ref.invalidate(projectProvider(widget.projectId));
        ref.invalidate(entitiesProvider(widget.projectId));
        ref.invalidate(commandsProvider(widget.projectId));
        ref.invalidate(readModelsProvider(widget.projectId));
        ref.invalidate(connectionsProvider(widget.projectId));
        await _loadProjectData();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Project header
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  Icons.folder,
                  size: 40,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _project!.name,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _project!.description.isEmpty
                          ? 'No description'
                          : _project!.description,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () => context.go('/canvas/${widget.projectId}'),
                icon: const Icon(Icons.dashboard),
                label: const Text('Open Canvas'),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Stats cards
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _StatCard(
                title: 'Entities',
                count: _entityCount,
                icon: Icons.category,
                color: Colors.blue,
                onTap: () => context.go('/projects/${widget.projectId}/entities'),
              ),
              _StatCard(
                title: 'Commands',
                count: _commandCount,
                icon: Icons.send,
                color: Colors.green,
                onTap: () => context.go('/projects/${widget.projectId}/commands'),
              ),
              _StatCard(
                title: 'Read Models',
                count: _readModelCount,
                icon: Icons.view_module,
                color: Colors.orange,
                onTap: () => context.go('/projects/${widget.projectId}/read-models'),
              ),
              _StatCard(
                title: 'Connections',
                count: _connectionCount,
                icon: Icons.link,
                color: Colors.purple,
                onTap: () => {},
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Quick actions
          Text(
            'Quick Actions',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _ActionButton(
                label: 'Create Entity',
                icon: Icons.add,
                onPressed: () => context.go('/projects/${widget.projectId}/entities'),
              ),
              _ActionButton(
                label: 'Create Command',
                icon: Icons.add,
                onPressed: () => context.go('/projects/${widget.projectId}/commands'),
              ),
              _ActionButton(
                label: 'Create Read Model',
                icon: Icons.add,
                onPressed: () => context.go('/projects/${widget.projectId}/read-models'),
              ),
              _ActionButton(
                label: 'Browse Library',
                icon: Icons.library_books,
                onPressed: () => context.go('/projects/${widget.projectId}/library'),
              ),
              _ActionButton(
                label: 'Team Settings',
                icon: Icons.group,
                onPressed: () => context.go('/projects/${widget.projectId}/team'),
              ),
              _ActionButton(
                label: 'Project Settings',
                icon: Icons.settings,
                onPressed: () => context.go('/projects/${widget.projectId}/settings'),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Recent activity (placeholder)
          Text(
            'Recent Activity',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.history,
                      size: 48,
                      color: theme.colorScheme.primary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No recent activity',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

/// A statistics card widget.
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 200,
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: color.withOpacity(0.2),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  count.toString(),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// An action button widget.
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
