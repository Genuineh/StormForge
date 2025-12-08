import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:stormforge_modeler/models/library_model.dart';
import 'package:stormforge_modeler/services/api/library_service.dart';

/// Dialog showing detailed information about a library component.
class ComponentDetailsDialog extends StatefulWidget {
  const ComponentDetailsDialog({
    super.key,
    required this.component,
    required this.projectId,
    required this.libraryService,
    required this.onRefresh,
  });

  final LibraryComponent component;
  final String projectId;
  final LibraryService libraryService;
  final VoidCallback onRefresh;

  @override
  State<ComponentDetailsDialog> createState() => _ComponentDetailsDialogState();
}

class _ComponentDetailsDialogState extends State<ComponentDetailsDialog> {
  List<ComponentVersion>? _versions;
  ImpactAnalysis? _impactAnalysis;
  bool _isLoadingVersions = false;
  bool _isLoadingImpact = false;

  @override
  void initState() {
    super.initState();
    _loadVersions();
    _loadImpact();
  }

  Future<void> _loadVersions() async {
    setState(() => _isLoadingVersions = true);
    try {
      final versions =
          await widget.libraryService.getComponentVersions(widget.component.id);
      setState(() {
        _versions = versions;
        _isLoadingVersions = false;
      });
    } catch (e) {
      setState(() => _isLoadingVersions = false);
    }
  }

  Future<void> _loadImpact() async {
    setState(() => _isLoadingImpact = true);
    try {
      final impact =
          await widget.libraryService.analyzeImpact(widget.component.id);
      setState(() {
        _impactAnalysis = impact;
        _isLoadingImpact = false;
      });
    } catch (e) {
      setState(() => _isLoadingImpact = false);
    }
  }

  Future<void> _useInProject(ComponentReferenceMode mode) async {
    try {
      await widget.libraryService.addReference(
        projectId: widget.projectId,
        componentId: widget.component.id,
        mode: mode,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Component added to project in ${mode.displayName} mode'),
          ),
        );
        widget.onRefresh();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add component: $e')),
        );
      }
    }
  }

  Future<void> _deleteComponent() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Component'),
        content: Text(
          'Are you sure you want to delete "${widget.component.name}"?\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await widget.libraryService.deleteComponent(widget.component.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Component deleted successfully')),
        );
        widget.onRefresh();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete component: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 800,
        height: 700,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            // Tabs
            Expanded(
              child: DefaultTabController(
                length: 4,
                child: Column(
                  children: [
                    TabBar(
                      tabs: const [
                        Tab(text: 'Overview'),
                        Tab(text: 'Definition'),
                        Tab(text: 'Versions'),
                        Tab(text: 'Usage & Impact'),
                      ],
                      labelColor: Theme.of(context).primaryColor,
                      unselectedLabelColor: Colors.grey,
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildOverviewTab(),
                          _buildDefinitionTab(),
                          _buildVersionsTab(),
                          _buildUsageTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Actions
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    IconData icon;
    Color color;

    switch (widget.component.componentType) {
      case ComponentType.entity:
        icon = Icons.layers;
        color = Colors.blue;
        break;
      case ComponentType.valueObject:
        icon = Icons.data_object;
        color = Colors.green;
        break;
      case ComponentType.enumType:
        icon = Icons.list;
        color = Colors.orange;
        break;
      case ComponentType.aggregate:
        icon = Icons.account_tree;
        color = Colors.purple;
        break;
      case ComponentType.command:
        icon = Icons.play_arrow;
        color = Colors.indigo;
        break;
      case ComponentType.event:
        icon = Icons.event_note;
        color = Colors.red;
        break;
      case ComponentType.readModel:
        icon = Icons.visibility;
        color = Colors.teal;
        break;
      case ComponentType.policy:
        icon = Icons.policy;
        color = Colors.brown;
        break;
      case ComponentType.interface:
        icon = Icons.integration_instructions;
        color = Colors.cyan;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 48, color: color),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.component.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.component.namespace,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                        fontFamily: 'monospace',
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          _buildSectionTitle('Description'),
          const SizedBox(height: 8),
          Text(widget.component.description),
          const SizedBox(height: 24),
          // Metadata
          _buildSectionTitle('Metadata'),
          const SizedBox(height: 12),
          _buildMetadataRow('Type', widget.component.componentType.displayName),
          _buildMetadataRow('Scope', widget.component.scope.displayName),
          _buildMetadataRow('Version', widget.component.version),
          _buildMetadataRow('Status', widget.component.status.displayName),
          if (widget.component.author != null)
            _buildMetadataRow('Author', widget.component.author!),
          _buildMetadataRow(
            'Created',
            _formatDate(widget.component.createdAt),
          ),
          _buildMetadataRow(
            'Updated',
            _formatDate(widget.component.updatedAt),
          ),
          // Tags
          if (widget.component.tags.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildSectionTitle('Tags'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.component.tags
                  .map((tag) => Chip(
                        label: Text(tag),
                        backgroundColor: Colors.grey[200],
                      ))
                  .toList(),
            ),
          ],
          // Usage Stats
          const SizedBox(height: 24),
          _buildSectionTitle('Usage Statistics'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.folder,
                  label: 'Projects',
                  value: '${widget.component.usageStats.projectCount}',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.link,
                  label: 'References',
                  value: '${widget.component.usageStats.referenceCount}',
                  color: Colors.green,
                ),
              ),
            ],
          ),
          if (widget.component.usageStats.lastUsed != null) ...[
            const SizedBox(height: 12),
            _buildMetadataRow(
              'Last Used',
              _formatDate(widget.component.usageStats.lastUsed!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDefinitionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Component Definition'),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: SelectableText(
              _formatDefinition(widget.component.definition),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionsTab() {
    if (_isLoadingVersions) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_versions == null || _versions!.isEmpty) {
      return const Center(
        child: Text('No version history available'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _versions!.length,
      itemBuilder: (context, index) {
        final version = _versions![index];
        final isLatest = index == 0;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isLatest ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.history,
                color: isLatest ? Colors.green : Colors.grey,
              ),
            ),
            title: Row(
              children: [
                Text(
                  'Version ${version.version}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (isLatest) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'LATEST',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(version.changeNotes),
                const SizedBox(height: 4),
                Text(
                  'By ${version.author} • ${_formatDate(version.createdAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildUsageTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Impact Analysis
          _buildSectionTitle('Impact Analysis'),
          const SizedBox(height: 16),
          if (_isLoadingImpact)
            const Center(child: CircularProgressIndicator())
          else if (_impactAnalysis != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_amber, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                          'Affected Projects: ${_impactAnalysis!.affectedProjects.length}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    if (_impactAnalysis!.affectedProjects.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      ..._impactAnalysis!.affectedProjects.map((project) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.folder, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${project.projectName} (${project.projectId})',
                                ),
                              ),
                              Text(
                                project.referenceMode.displayName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),
          ] else
            const Text('Impact analysis not available'),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Delete button (only for project-level components)
          if (widget.component.scope == LibraryScope.project)
            OutlinedButton.icon(
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: _deleteComponent,
            )
          else
            const SizedBox.shrink(),
          Row(
            children: [
              // Copy mode
              OutlinedButton.icon(
                icon: const Icon(Icons.content_copy),
                label: const Text('Copy to Project'),
                onPressed: () => _useInProject(ComponentReferenceMode.copy),
              ),
              const SizedBox(width: 8),
              // Reference mode
              ElevatedButton.icon(
                icon: const Icon(Icons.link),
                label: const Text('Reference in Project'),
                onPressed: () => _useInProject(ComponentReferenceMode.reference),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDefinition(dynamic definition) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(definition);
    } catch (e) {
      return definition.toString();
    }
  }
}
