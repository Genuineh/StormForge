import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stormforge_modeler/services/providers.dart';

/// Navigation drawer for the main application.
class AppNavigationDrawer extends ConsumerWidget {
  const AppNavigationDrawer({
    super.key,
    this.projectId,
  });

  final String? projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.valueOrNull;
    final theme = Theme.of(context);

    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.bolt,
                      size: 40,
                      color: theme.colorScheme.onPrimary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'StormForge',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (user != null) ...[
                  Text(
                    user.username,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimary.withOpacity(0.8),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Navigation items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Projects section
                _DrawerSection(
                  title: 'Projects',
                  icon: Icons.folder,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.list),
                      title: const Text('All Projects'),
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/projects');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.add),
                      title: const Text('New Project'),
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/projects/new');
                      },
                    ),
                  ],
                ),

                const Divider(),

                // Current Project section (if a project is selected)
                if (projectId != null) ...[
                  _DrawerSection(
                    title: 'Current Project',
                    icon: Icons.folder_open,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.dashboard),
                        title: const Text('Canvas'),
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/canvas/$projectId');
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.category),
                        title: const Text('Entities'),
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/projects/$projectId/entities');
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.view_module),
                        title: const Text('Read Models'),
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/projects/$projectId/read-models');
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.send),
                        title: const Text('Commands'),
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/projects/$projectId/commands');
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.group),
                        title: const Text('Team'),
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/projects/$projectId/team');
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.settings),
                        title: const Text('Settings'),
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/projects/$projectId/settings');
                        },
                      ),
                    ],
                  ),
                  const Divider(),
                ],

                // Library section
                _DrawerSection(
                  title: 'Library',
                  icon: Icons.library_books,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.public),
                      title: const Text('Browse Library'),
                      onTap: () {
                        Navigator.pop(context);
                        if (projectId != null) {
                          context.go('/projects/$projectId/library');
                        }
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.upload),
                      title: const Text('My Components'),
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Navigate to user's components
                      },
                    ),
                  ],
                ),

                const Divider(),

                // Help & Settings
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('Help & Documentation'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to help
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.account_circle),
                  title: const Text('Profile'),
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/profile');
                  },
                ),
              ],
            ),
          ),

          // Logout button
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: theme.colorScheme.error),
            title: Text(
              'Logout',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onTap: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// A collapsible section in the drawer.
class _DrawerSection extends StatefulWidget {
  const _DrawerSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  State<_DrawerSection> createState() => _DrawerSectionState();
}

class _DrawerSectionState extends State<_DrawerSection> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        ListTile(
          leading: Icon(widget.icon, size: 20),
          title: Text(
            widget.title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          trailing: Icon(
            _isExpanded ? Icons.expand_less : Icons.expand_more,
            size: 20,
          ),
          dense: true,
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
        ),
        if (_isExpanded) ...widget.children,
      ],
    );
  }
}
