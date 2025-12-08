import 'package:flutter/material.dart';
import 'package:stormforge_modeler/models/read_model_model.dart';
import 'package:stormforge_modeler/services/api/read_model_service.dart';

/// Dialog for selecting a read model definition to link to a read model element.
class ReadModelDefinitionSelectionDialog extends StatefulWidget {
  const ReadModelDefinitionSelectionDialog({
    super.key,
    required this.projectId,
    required this.readModelService,
    this.excludeReadModelIds = const [],
  });

  final String projectId;
  final ReadModelService readModelService;
  final List<String> excludeReadModelIds;

  @override
  State<ReadModelDefinitionSelectionDialog> createState() =>
      _ReadModelDefinitionSelectionDialogState();
}

class _ReadModelDefinitionSelectionDialogState
    extends State<ReadModelDefinitionSelectionDialog> {
  List<ReadModelDefinition>? _readModels;
  List<ReadModelDefinition>? _filteredReadModels;
  bool _isLoading = false;
  String? _error;
  final _searchController = TextEditingController();
  ReadModelDefinition? _selectedReadModel;

  @override
  void initState() {
    super.initState();
    _loadReadModels();
    _searchController.addListener(_filterReadModels);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadReadModels() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final readModels = await widget.readModelService
          .listReadModelsForProject(widget.projectId);

      // Filter out excluded read models
      final filtered = readModels
          .where((rm) => !widget.excludeReadModelIds.contains(rm.id))
          .toList();

      setState(() {
        _readModels = filtered;
        _filteredReadModels = filtered;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterReadModels() {
    if (_readModels == null) return;

    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredReadModels = _readModels;
      });
      return;
    }

    setState(() {
      _filteredReadModels = _readModels!
          .where((readModel) =>
              readModel.name.toLowerCase().contains(query) ||
              (readModel.description?.toLowerCase().contains(query) ?? false))
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
                  Icons.visibility,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Select Read Model Definition',
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
                hintText: 'Search read model definitions...',
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
                  onPressed: _selectedReadModel == null
                      ? null
                      : () => Navigator.of(context).pop(_selectedReadModel),
                  child: const Text('Link Read Model'),
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
              'Failed to load read model definitions',
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
              onPressed: _loadReadModels,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredReadModels == null || _filteredReadModels!.isEmpty) {
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
                  ? 'No read model definitions found'
                  : 'No matching read model definitions',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isEmpty
                  ? 'Create read model definitions in the Read Model Designer first'
                  : 'Try a different search term',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredReadModels!.length,
      itemBuilder: (context, index) {
        final readModel = _filteredReadModels![index];
        final isSelected = _selectedReadModel?.id == readModel.id;

        return Card(
          elevation: isSelected ? 2 : 0,
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surface,
          child: ListTile(
            leading: Icon(
              Icons.visibility,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            title: Text(
              readModel.name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            subtitle: readModel.description != null && readModel.description!.isNotEmpty
                ? Text(readModel.description!)
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (readModel.sources.isNotEmpty)
                  Chip(
                    label: Text(
                      '${readModel.sources.length} sources',
                      style: theme.textTheme.labelSmall,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                if (readModel.fields.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Chip(
                      label: Text(
                        '${readModel.fields.length} fields',
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
                _selectedReadModel = readModel;
              });
            },
          ),
        );
      },
    );
  }
}
