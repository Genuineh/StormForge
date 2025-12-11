import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stormforge_modeler/models/project_model.dart';
import 'package:stormforge_modeler/services/providers.dart';

/// Provider for projects list.
final projectsProvider = FutureProvider.autoDispose<List<Project>>((ref) async {
  final authState = ref.watch(authProvider);
  final projectService = ref.watch(projectServiceProvider);
  
  final user = authState.valueOrNull;
  if (user == null) return [];
  
  return await projectService.listProjects(user.id);
});

/// Projects list screen.
class ProjectsListScreen extends ConsumerStatefulWidget {
  const ProjectsListScreen({super.key});

  @override
  ConsumerState<ProjectsListScreen> createState() => _ProjectsListScreenState();
}

class _ProjectsListScreenState extends ConsumerState<ProjectsListScreen> {
  bool _isGridView = false;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Projects'),
        actions: [
          // Search
          SizedBox(
            width: 250,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search projects...',
                prefixIcon: const Icon(Icons.search),
                border: InputBorder.none,
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          // Toggle view
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            tooltip: _isGridView ? 'List View' : 'Grid View',
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => context.go('/profile'),
            tooltip: 'Profile',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            tooltip: 'Logout',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: projectsAsync.when(
        data: (projects) {
          // Filter projects based on search query
          final filteredProjects = projects.where((project) {
            if (_searchQuery.isEmpty) return true;
            final query = _searchQuery.toLowerCase();
            return project.name.toLowerCase().contains(query) ||
                project.description.toLowerCase().contains(query);
          }).toList();

          if (filteredProjects.isEmpty) {
            if (_searchQuery.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: theme.colorScheme.primary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No projects found',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try a different search term',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open,
                    size: 64,
                    color: theme.colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No projects yet',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first project to get started',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => context.go('/projects/new'),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Project'),
                  ),
                ],
              ),
            );
          }

          if (_isGridView) {
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                childAspectRatio: 1.2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: filteredProjects.length,
              itemBuilder: (context, index) {
                final project = filteredProjects[index];
                return _ProjectGridCard(project: project);
              },
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredProjects.length,
            itemBuilder: (context, index) {
              final project = filteredProjects[index];
              return _ProjectListCard(project: project);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading projects: $error'),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => ref.refresh(projectsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/projects/new'),
        icon: const Icon(Icons.add),
        label: const Text('New Project'),
      ),
    );
  }
}

/// Project list card widget.
class _ProjectListCard extends ConsumerWidget {
  const _ProjectListCard({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            Icons.folder,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(project.name),
        subtitle: Text(
          project.description.isEmpty
              ? 'No description'
              : project.description,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'open',
              child: ListTile(
                leading: Icon(Icons.open_in_new),
                title: Text('Open'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'dashboard',
              child: ListTile(
                leading: Icon(Icons.dashboard),
                title: Text('Dashboard'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'team',
              child: ListTile(
                leading: Icon(Icons.group),
                title: Text('Team Members'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'open':
                context.go('/canvas/${project.id}');
                break;
              case 'dashboard':
                context.go('/projects/${project.id}');
                break;
              case 'settings':
                context.go('/projects/${project.id}/settings');
                break;
              case 'team':
                context.go('/projects/${project.id}/team');
                break;
              case 'delete':
                _showDeleteDialog(context, ref, project);
                break;
            }
          },
        ),
        onTap: () => context.go('/projects/${project.id}'),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    Project project,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text('Are you sure you want to delete "${project.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              final projectService = ref.read(projectServiceProvider);
              try {
                await projectService.deleteProject(project.id);
                ref.invalidate(projectsProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Project deleted')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete project: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Project grid card widget.
class _ProjectGridCard extends ConsumerWidget {
  const _ProjectGridCard({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: () => context.go('/projects/${project.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      Icons.folder,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'open',
                        child: Text('Open Canvas'),
                      ),
                      const PopupMenuItem(
                        value: 'dashboard',
                        child: Text('Dashboard'),
                      ),
                      const PopupMenuItem(
                        value: 'settings',
                        child: Text('Settings'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                    onSelected: (value) {
                      switch (value) {
                        case 'open':
                          context.go('/canvas/${project.id}');
                          break;
                        case 'dashboard':
                          context.go('/projects/${project.id}');
                          break;
                        case 'settings':
                          context.go('/projects/${project.id}/settings');
                          break;
                        case 'delete':
                          // TODO: Show delete dialog
                          break;
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                project.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  project.description.isEmpty
                      ? 'No description'
                      : project.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Divider(),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Recently updated',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
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

