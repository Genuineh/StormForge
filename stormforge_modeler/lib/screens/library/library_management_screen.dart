import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:stormforge_modeler/models/library_model.dart';
import 'package:stormforge_modeler/screens/library/widgets/component_card.dart';
import 'package:stormforge_modeler/screens/library/widgets/component_details_dialog.dart';
import 'package:stormforge_modeler/screens/library/widgets/publish_component_dialog.dart';
import 'package:stormforge_modeler/services/api/library_service.dart';
import 'package:stormforge_modeler/services/providers.dart';
import 'package:stormforge_modeler/widgets/workspace_layout.dart';

/// Enhanced library browser screen with workspace layout.
class LibraryManagementScreen extends ConsumerStatefulWidget {
  const LibraryManagementScreen({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  final String projectId;
  final String projectName;

  @override
  ConsumerState<LibraryManagementScreen> createState() =>
      _LibraryManagementScreenState();
}

class _LibraryManagementScreenState
    extends ConsumerState<LibraryManagementScreen> {
  LibraryService? _libraryService;
  List<LibraryComponent> _components = [];
  List<LibraryComponent> _filteredComponents = [];
  LibraryComponent? _selectedComponent;
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  LibraryScope? _selectedScope;
  ComponentType? _selectedType;
  ComponentStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _libraryService = ref.read(libraryServiceProvider);
      _loadComponents();
    });
  }

  Future<void> _loadComponents() async {
    if (_libraryService == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final components = await _libraryService!.searchComponents(
        scope: _selectedScope,
      );
      setState(() {
        _components = components;
        _filteredComponents = components;
        _isLoading = false;
        _applyFilters();
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load components: $e';
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredComponents = _components.where((component) {
        // Search query filter
        if (_searchQuery.isNotEmpty) {
          final searchLower = _searchQuery.toLowerCase();
          final matchesName =
              component.name.toLowerCase().contains(searchLower);
          final matchesDescription =
              component.description.toLowerCase().contains(searchLower);
          final matchesTags = component.tags
              .any((tag) => tag.toLowerCase().contains(searchLower));
          if (!matchesName && !matchesDescription && !matchesTags) {
            return false;
          }
        }

        // Scope filter
        if (_selectedScope != null && component.scope != _selectedScope) {
          return false;
        }

        // Type filter
        if (_selectedType != null &&
            component.componentType != _selectedType) {
          return false;
        }

        // Status filter
        if (_selectedStatus != null && component.status != _selectedStatus) {
          return false;
        }

        return true;
      }).toList();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  Future<void> _publishComponent() async {
    if (_libraryService == null) return;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => PublishComponentDialog(
        projectId: widget.projectId,
        libraryService: _libraryService!,
      ),
    );

    if (result == true) {
      _loadComponents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WorkspaceLayout(
      projectId: widget.projectId,
      projectName: widget.projectName,
      leftPanel: _buildLeftPanel(),
      rightPanel:
          _selectedComponent != null ? _buildDetailsPanel() : _buildEmptyPanel(),
      child: _buildMainContent(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _publishComponent,
        icon: const Icon(Icons.publish),
        label: const Text('Publish Component'),
      ),
    );
  }

  Widget _buildLeftPanel() {
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            'Filters',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              // Scope filter
              Text(
                'Scope',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...LibraryScope.values.map((scope) => CheckboxListTile(
                    title: Text(_getScopeLabel(scope)),
                    value: _selectedScope == scope,
                    onChanged: (checked) {
                      setState(() {
                        _selectedScope = checked == true ? scope : null;
                        _applyFilters();
                      });
                    },
                    dense: true,
                  )),
              const SizedBox(height: 16),

              // Type filter
              Text(
                'Component Type',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...ComponentType.values.map((type) => CheckboxListTile(
                    title: Text(_getTypeLabel(type)),
                    value: _selectedType == type,
                    onChanged: (checked) {
                      setState(() {
                        _selectedType = checked == true ? type : null;
                        _applyFilters();
                      });
                    },
                    dense: true,
                  )),
              const SizedBox(height: 16),

              // Status filter
              Text(
                'Status',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...ComponentStatus.values.map((status) => CheckboxListTile(
                    title: Text(_getStatusLabel(status)),
                    value: _selectedStatus == status,
                    onChanged: (checked) {
                      setState(() {
                        _selectedStatus = checked == true ? status : null;
                        _applyFilters();
                      });
                    },
                    dense: true,
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsPanel() {
    if (_libraryService == null) return const SizedBox.shrink();

    return ComponentDetailsDialog(
      component: _selectedComponent!,
      projectId: widget.projectId,
      libraryService: _libraryService!,
      onRefresh: _loadComponents,
      isEmbedded: true,
    );
  }

  Widget _buildEmptyPanel() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            size: 48,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Select a component',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a component\nto view its details',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(_error!),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _loadComponents,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildToolbar(),
        const Divider(height: 1),
        Expanded(child: _buildComponentGrid()),
      ],
    );
  }

  Widget _buildToolbar() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          SizedBox(
            width: 300,
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search library...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          const Spacer(),
          Text(
            '${_filteredComponents.length} of ${_components.length} components',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComponentGrid() {
    if (_filteredComponents.isEmpty) {
      final theme = Theme.of(context);
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isNotEmpty
                  ? Icons.search_off
                  : Icons.library_books_outlined,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No components found'
                  : 'No components in library',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try adjusting your filters'
                  : 'Publish your first component',
              style: theme.textTheme.bodyMedium,
            ),
            if (_components.isEmpty) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _publishComponent,
                icon: const Icon(Icons.publish),
                label: const Text('Publish Component'),
              ),
            ],
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,
        childAspectRatio: 0.9,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredComponents.length,
      itemBuilder: (context, index) {
        final component = _filteredComponents[index];
        return ComponentCard(
          component: component,
          onTap: () {
            setState(() {
              _selectedComponent = component;
            });
          },
        );
      },
    );
  }

  String _getScopeLabel(LibraryScope scope) {
    switch (scope) {
      case LibraryScope.personal:
        return 'Personal';
      case LibraryScope.team:
        return 'Team';
      case LibraryScope.public:
        return 'Public';
    }
  }

  String _getTypeLabel(ComponentType type) {
    switch (type) {
      case ComponentType.entity:
        return 'Entity';
      case ComponentType.valueObject:
        return 'Value Object';
      case ComponentType.aggregate:
        return 'Aggregate';
      case ComponentType.command:
        return 'Command';
      case ComponentType.readModel:
        return 'Read Model';
      case ComponentType.policy:
        return 'Policy';
      case ComponentType.saga:
        return 'Saga';
    }
  }

  String _getStatusLabel(ComponentStatus status) {
    switch (status) {
      case ComponentStatus.draft:
        return 'Draft';
      case ComponentStatus.published:
        return 'Published';
      case ComponentStatus.deprecated:
        return 'Deprecated';
    }
  }
}
