import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:stormforge_modeler/models/library_model.dart';
import 'package:stormforge_modeler/screens/library/widgets/component_card.dart';
import 'package:stormforge_modeler/screens/library/widgets/component_details_dialog.dart';
import 'package:stormforge_modeler/screens/library/widgets/publish_component_dialog.dart';
import 'package:stormforge_modeler/services/api/library_service.dart';
import 'package:stormforge_modeler/services/providers.dart';

/// Library browser screen for browsing and managing library components.
class LibraryBrowserScreen extends ConsumerStatefulWidget {
  const LibraryBrowserScreen({
    super.key,
    required this.projectId,
  });

  final String projectId;

  @override
  ConsumerState<LibraryBrowserScreen> createState() => _LibraryBrowserScreenState();
}

class _LibraryBrowserScreenState extends ConsumerState<LibraryBrowserScreen> {
  late LibraryService _libraryService;
  List<LibraryComponent> _components = [];
  List<LibraryComponent> _filteredComponents = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  LibraryScope? _selectedScope;
  ComponentType? _selectedType;
  ComponentStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _libraryService = ref.read(libraryServiceProvider);
    _loadComponents();
  }

  Future<void> _loadComponents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final components = await _libraryService.searchComponents(
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
          final matchesName = component.name.toLowerCase().contains(searchLower);
          final matchesDescription = component.description.toLowerCase().contains(searchLower);
          final matchesTags = component.tags.any((tag) => tag.toLowerCase().contains(searchLower));
          if (!matchesName && !matchesDescription && !matchesTags) {
            return false;
          }
        }

        // Scope filter
        if (_selectedScope != null && component.scope != _selectedScope) {
          return false;
        }

        // Type filter
        if (_selectedType != null && component.type != _selectedType) {
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

  void _onScopeFilterChanged(LibraryScope? scope) {
    setState(() {
      _selectedScope = scope;
      _applyFilters();
    });
  }

  void _onTypeFilterChanged(ComponentType? type) {
    setState(() {
      _selectedType = type;
      _applyFilters();
    });
  }

  void _onStatusFilterChanged(ComponentStatus? status) {
    setState(() {
      _selectedStatus = status;
      _applyFilters();
    });
  }

  Future<void> _showComponentDetails(LibraryComponent component) async {
    await showDialog(
      context: context,
      builder: (context) => ComponentDetailsDialog(
        component: component,
        projectId: widget.projectId,
        libraryService: _libraryService,
        onRefresh: _loadComponents,
      ),
    );
  }

  Future<void> _publishComponent() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => PublishComponentDialog(
        projectId: widget.projectId,
        libraryService: _libraryService,
      ),
    );

    if (result == true) {
      _loadComponents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Component Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadComponents,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _publishComponent,
            tooltip: 'Publish Component',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search components...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => _onSearchChanged(''),
                          )
                        : null,
                  ),
                  onChanged: _onSearchChanged,
                ),
                const SizedBox(height: 16),
                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Scope filter
                      _buildFilterChip<LibraryScope>(
                        label: 'Scope',
                        value: _selectedScope,
                        items: LibraryScope.values,
                        onChanged: _onScopeFilterChanged,
                        displayName: (scope) => scope.displayName,
                      ),
                      const SizedBox(width: 8),
                      // Type filter
                      _buildFilterChip<ComponentType>(
                        label: 'Type',
                        value: _selectedType,
                        items: ComponentType.values,
                        onChanged: _onTypeFilterChanged,
                        displayName: (type) => type.displayName,
                      ),
                      const SizedBox(width: 8),
                      // Status filter
                      _buildFilterChip<ComponentStatus>(
                        label: 'Status',
                        value: _selectedStatus,
                        items: ComponentStatus.values,
                        onChanged: _onStatusFilterChanged,
                        displayName: (status) => status.displayName,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Component grid
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              onPressed: _loadComponents,
            ),
          ],
        ),
      );
    }

    if (_filteredComponents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.library_books, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty || _selectedScope != null || _selectedType != null
                  ? 'No components found matching your filters'
                  : 'No components in library yet',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            if (_searchQuery.isEmpty && _selectedScope == null && _selectedType == null)
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Publish First Component'),
                onPressed: _publishComponent,
              ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredComponents.length,
      itemBuilder: (context, index) {
        final component = _filteredComponents[index];
        return ComponentCard(
          component: component,
          onTap: () => _showComponentDetails(component),
        );
      },
    );
  }

  Widget _buildFilterChip<T>({
    required String label,
    required T? value,
    required List<T> items,
    required void Function(T?) onChanged,
    required String Function(T) displayName,
  }) {
    return PopupMenuButton<T?>(
      child: Chip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value != null ? displayName(value) : label),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 18),
          ],
        ),
        backgroundColor: value != null ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
      ),
      itemBuilder: (context) => [
        PopupMenuItem<T?>(
          value: null,
          child: Text('All ${label}s'),
        ),
        ...items.map((item) => PopupMenuItem<T?>(
              value: item,
              child: Text(displayName(item)),
            )),
      ],
      onSelected: onChanged,
    );
  }
}
