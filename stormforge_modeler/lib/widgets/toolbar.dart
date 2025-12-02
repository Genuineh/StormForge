import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stormforge_modeler/canvas/canvas_controller.dart';
import 'package:stormforge_modeler/services/yaml_service.dart';

/// The toolbar widget at the top of the modeler.
class ModelerToolbar extends ConsumerWidget {
  /// Creates a modeler toolbar.
  const ModelerToolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final viewport = ref.watch(canvasViewportProvider);

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Row(
        children: [
          // Logo/App name
          Row(
            children: [
              Icon(
                Icons.flash_on,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'StormForge',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(width: 24),

          // File operations
          _ToolbarSection(
            children: [
              _ToolbarButton(
                icon: Icons.folder_open,
                tooltip: 'Open Project',
                onPressed: () => _openProject(context, ref),
              ),
              _ToolbarButton(
                icon: Icons.save,
                tooltip: 'Save Project',
                onPressed: () => _saveProject(context, ref),
              ),
              _ToolbarButton(
                icon: Icons.file_download,
                tooltip: 'Export YAML',
                onPressed: () => _exportYaml(context, ref),
              ),
              _ToolbarButton(
                icon: Icons.file_upload,
                tooltip: 'Import YAML',
                onPressed: () => _importYaml(context, ref),
              ),
            ],
          ),

          const SizedBox(width: 16),

          // Edit operations
          _ToolbarSection(
            children: [
              _ToolbarButton(
                icon: Icons.undo,
                tooltip: 'Undo',
                onPressed: () {
                  // TODO: Implement undo
                },
              ),
              _ToolbarButton(
                icon: Icons.redo,
                tooltip: 'Redo',
                onPressed: () {
                  // TODO: Implement redo
                },
              ),
              _ToolbarButton(
                icon: Icons.delete_outline,
                tooltip: 'Delete Selected',
                onPressed: () {
                  final model = ref.read(canvasModelProvider);
                  if (model.selectedElementId != null) {
                    ref.read(canvasModelProvider.notifier).removeElement(
                          model.selectedElementId!,
                        );
                  }
                },
              ),
            ],
          ),

          const Spacer(),

          // Zoom controls
          _ToolbarSection(
            children: [
              _ToolbarButton(
                icon: Icons.zoom_out,
                tooltip: 'Zoom Out',
                onPressed: () {
                  ref.read(canvasViewportProvider.notifier).zoom(
                        0.8,
                        Offset.zero,
                      );
                },
              ),
              Container(
                width: 60,
                alignment: Alignment.center,
                child: Text(
                  '${(viewport.scale * 100).round()}%',
                  style: theme.textTheme.bodySmall,
                ),
              ),
              _ToolbarButton(
                icon: Icons.zoom_in,
                tooltip: 'Zoom In',
                onPressed: () {
                  ref.read(canvasViewportProvider.notifier).zoom(
                        1.2,
                        Offset.zero,
                      );
                },
              ),
              _ToolbarButton(
                icon: Icons.fit_screen,
                tooltip: 'Fit to Content',
                onPressed: () {
                  // TODO: Implement fit to content
                  ref.read(canvasViewportProvider.notifier).reset();
                },
              ),
            ],
          ),

          const SizedBox(width: 16),

          // View controls
          _ToolbarSection(
            children: [
              _ToolbarButton(
                icon: Icons.grid_on,
                tooltip: 'Toggle Grid',
                onPressed: () {
                  // TODO: Implement grid toggle
                },
              ),
              _ToolbarButton(
                icon: Icons.dark_mode,
                tooltip: 'Toggle Theme',
                onPressed: () {
                  // TODO: Implement theme toggle
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openProject(BuildContext context, WidgetRef ref) {
    // TODO: Implement open project
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Open Project - Coming soon')),
    );
  }

  void _saveProject(BuildContext context, WidgetRef ref) {
    // TODO: Implement save project
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Project saved (demo)')),
    );
  }

  void _exportYaml(BuildContext context, WidgetRef ref) {
    final model = ref.read(canvasModelProvider);
    final yaml = ref.read(yamlServiceProvider).exportToYaml(model);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export YAML'),
        content: SizedBox(
          width: 600,
          height: 400,
          child: SingleChildScrollView(
            child: SelectableText(
              yaml,
              style: const TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 12,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _importYaml(BuildContext context, WidgetRef ref) {
    // TODO: Implement import YAML
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Import YAML - Coming soon')),
    );
  }
}

/// A section of related toolbar buttons.
class _ToolbarSection extends StatelessWidget {
  const _ToolbarSection({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

/// A toolbar button.
class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.isActive = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isActive
                ? theme.colorScheme.primaryContainer
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isActive
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
