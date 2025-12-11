import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stormforge_modeler/widgets/navigation_drawer.dart';

/// Provider for the current workspace view.
final workspaceViewProvider = StateProvider<WorkspaceView>((ref) => WorkspaceView.canvas);

/// Different workspace views available in the modeler.
enum WorkspaceView {
  canvas,
  entities,
  readModels,
  commands,
  library,
  settings,
}

extension WorkspaceViewExtension on WorkspaceView {
  String get displayName {
    switch (this) {
      case WorkspaceView.canvas:
        return 'Canvas';
      case WorkspaceView.entities:
        return 'Entities';
      case WorkspaceView.readModels:
        return 'Read Models';
      case WorkspaceView.commands:
        return 'Commands';
      case WorkspaceView.library:
        return 'Library';
      case WorkspaceView.settings:
        return 'Settings';
    }
  }

  IconData get icon {
    switch (this) {
      case WorkspaceView.canvas:
        return Icons.dashboard;
      case WorkspaceView.entities:
        return Icons.category;
      case WorkspaceView.readModels:
        return Icons.view_module;
      case WorkspaceView.commands:
        return Icons.send;
      case WorkspaceView.library:
        return Icons.library_books;
      case WorkspaceView.settings:
        return Icons.settings;
    }
  }
}

/// Main workspace layout for the modeler.
class WorkspaceLayout extends ConsumerWidget {
  const WorkspaceLayout({
    super.key,
    required this.projectId,
    required this.projectName,
    required this.child,
    this.showLeftPanel = true,
    this.showRightPanel = true,
    this.leftPanel,
    this.rightPanel,
    this.floatingActionButton,
  });

  final String projectId;
  final String projectName;
  final Widget child;
  final bool showLeftPanel;
  final bool showRightPanel;
  final Widget? leftPanel;
  final Widget? rightPanel;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentView = ref.watch(workspaceViewProvider);

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            tooltip: 'Open navigation',
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: Row(
          children: [
            Icon(Icons.bolt, size: 24, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    projectName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    currentView.displayName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Quick navigation tabs
          _ViewTabButton(
            view: WorkspaceView.canvas,
            projectId: projectId,
          ),
          _ViewTabButton(
            view: WorkspaceView.entities,
            projectId: projectId,
          ),
          _ViewTabButton(
            view: WorkspaceView.readModels,
            projectId: projectId,
          ),
          _ViewTabButton(
            view: WorkspaceView.commands,
            projectId: projectId,
          ),
          const VerticalDivider(),
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save',
            onPressed: () {
              // TODO: Implement save
            },
          ),
          IconButton(
            icon: const Icon(Icons.undo),
            tooltip: 'Undo',
            onPressed: () {
              // TODO: Implement undo
            },
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            tooltip: 'Redo',
            onPressed: () {
              // TODO: Implement redo
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: AppNavigationDrawer(projectId: projectId),
      body: Row(
        children: [
          // Left panel
          if (showLeftPanel && leftPanel != null) ...[
            SizedBox(
              width: 280,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
                ),
                child: leftPanel,
              ),
            ),
          ],

          // Main content area
          Expanded(child: child),

          // Right panel
          if (showRightPanel && rightPanel != null) ...[
            SizedBox(
              width: 320,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
                ),
                child: rightPanel,
              ),
            ),
          ],
        ],
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: _WorkspaceStatusBar(projectName: projectName),
    );
  }
}

/// Quick view tab button in the app bar.
class _ViewTabButton extends ConsumerWidget {
  const _ViewTabButton({
    required this.view,
    required this.projectId,
  });

  final WorkspaceView view;
  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentView = ref.watch(workspaceViewProvider);
    final isActive = currentView == view;
    final theme = Theme.of(context);

    return Tooltip(
      message: view.displayName,
      child: InkWell(
        onTap: () {
          ref.read(workspaceViewProvider.notifier).state = view;
          
          // Navigate to the corresponding route
          switch (view) {
            case WorkspaceView.canvas:
              context.go('/canvas/$projectId');
              break;
            case WorkspaceView.entities:
              context.go('/projects/$projectId/entities');
              break;
            case WorkspaceView.readModels:
              context.go('/projects/$projectId/read-models');
              break;
            case WorkspaceView.commands:
              context.go('/projects/$projectId/commands');
              break;
            case WorkspaceView.library:
              context.go('/projects/$projectId/library');
              break;
            case WorkspaceView.settings:
              context.go('/projects/$projectId/settings');
              break;
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive
                    ? theme.colorScheme.primary
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Icon(
            view.icon,
            size: 20,
            color: isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}

/// Status bar at the bottom of the workspace.
class _WorkspaceStatusBar extends ConsumerWidget {
  const _WorkspaceStatusBar({required this.projectName});

  final String projectName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 14,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'Ready',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(width: 16),
          Text(
            '•',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              projectName,
              style: theme.textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'v0.1.0',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
