import 'package:flutter/material.dart';
import 'package:stormforge_modeler/models/command_model.dart';
import 'package:stormforge_modeler/services/api/command_service.dart';

/// Dialog for selecting a command definition to link to a command element.
class CommandDefinitionSelectionDialog extends StatefulWidget {
  const CommandDefinitionSelectionDialog({
    super.key,
    required this.projectId,
    required this.commandService,
    this.excludeCommandIds = const [],
  });

  final String projectId;
  final CommandService commandService;
  final List<String> excludeCommandIds;

  @override
  State<CommandDefinitionSelectionDialog> createState() =>
      _CommandDefinitionSelectionDialogState();
}

class _CommandDefinitionSelectionDialogState
    extends State<CommandDefinitionSelectionDialog> {
  List<CommandDefinition>? _commands;
  List<CommandDefinition>? _filteredCommands;
  bool _isLoading = false;
  String? _error;
  final _searchController = TextEditingController();
  CommandDefinition? _selectedCommand;

  @override
  void initState() {
    super.initState();
    _loadCommands();
    _searchController.addListener(_filterCommands);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCommands() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final commands = await widget.commandService
          .listCommandsForProject(widget.projectId);

      // Filter out excluded commands
      final filtered = commands
          .where((c) => !widget.excludeCommandIds.contains(c.id))
          .toList();

      setState(() {
        _commands = filtered;
        _filteredCommands = filtered;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterCommands() {
    if (_commands == null) return;

    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredCommands = _commands;
      });
      return;
    }

    setState(() {
      _filteredCommands = _commands!
          .where((command) =>
              command.name.toLowerCase().contains(query) ||
              (command.description?.toLowerCase().contains(query) ?? false))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: Container(
        width: 600,
        height: 700,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.play_arrow,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Select Command Definition',
                  style: theme.textTheme.headlineSmall,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search command definitions...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
              ),
            ),
            const SizedBox(height: 16),

            // Content
            Expanded(
              child: _buildContent(theme),
            ),

            const SizedBox(height: 16),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _selectedCommand == null
                      ? null
                      : () => Navigator.of(context).pop(_selectedCommand),
                  child: const Text('Link Command'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load command definitions',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _loadCommands,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredCommands == null || _filteredCommands!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty
                  ? 'No command definitions found'
                  : 'No matching command definitions',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isEmpty
                  ? 'Create command definitions in the Command Designer first'
                  : 'Try a different search term',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredCommands!.length,
      itemBuilder: (context, index) {
        final command = _filteredCommands![index];
        final isSelected = _selectedCommand?.id == command.id;

        return Card(
          elevation: isSelected ? 2 : 0,
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surface,
          child: ListTile(
            leading: Icon(
              Icons.play_arrow,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            title: Text(
              command.name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            subtitle: command.description != null && command.description!.isNotEmpty
                ? Text(command.description!)
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (command.payload.fields.isNotEmpty)
                  Chip(
                    label: Text(
                      '${command.payload.fields.length} fields',
                      style: theme.textTheme.labelSmall,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                if (command.producedEvents.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Chip(
                      label: Text(
                        '${command.producedEvents.length} events',
                        style: theme.textTheme.labelSmall,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),
            selected: isSelected,
            onTap: () {
              setState(() {
                _selectedCommand = command;
              });
            },
          ),
        );
      },
    );
  }
}
