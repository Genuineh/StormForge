import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stormforge_modeler/models/connection_model.dart';
import 'package:stormforge_modeler/services/api/connection_service.dart';
import 'package:stormforge_modeler/services/providers.dart';
import 'package:stormforge_modeler/widgets/workspace_layout.dart';

/// Connection designer screen for visualizing and managing connections.
class ConnectionDesignerScreen extends ConsumerStatefulWidget {
  const ConnectionDesignerScreen({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  final String projectId;
  final String projectName;

  @override
  ConsumerState<ConnectionDesignerScreen> createState() =>
      _ConnectionDesignerScreenState();
}

class _ConnectionDesignerScreenState
    extends ConsumerState<ConnectionDesignerScreen> {
  List<ConnectionDefinition> _connections = [];
  ConnectionDefinition? _selectedConnection;
  bool _isLoading = true;
  String? _error;
  ConnectionType? _typeFilter;

  @override
  void initState() {
    super.initState();
    _loadConnections();
  }

  Future<void> _loadConnections() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final connectionService = ref.read(connectionServiceProvider);
      final connections =
          await connectionService.listConnectionsForProject(widget.projectId);

      setState(() {
        _connections = connections;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load connections: $e';
        _isLoading = false;
      });
    }
  }

  List<ConnectionDefinition> get _filteredConnections {
    if (_typeFilter == null) return _connections;
    return _connections
        .where((c) => c.connectionType == _typeFilter)
        .toList();
  }

  Future<void> _deleteConnection(ConnectionDefinition connection) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Connection'),
        content: Text(
          'Are you sure you want to delete this connection?\n\n'
          '${connection.connectionType.displayName}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final connectionService = ref.read(connectionServiceProvider);
      await connectionService.deleteConnection(
        projectId: widget.projectId,
        connectionId: connection.id,
      );

      setState(() {
        _connections.removeWhere((c) => c.id == connection.id);
        if (_selectedConnection?.id == connection.id) {
          _selectedConnection = null;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connection deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete connection: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WorkspaceLayout(
      projectId: widget.projectId,
      projectName: widget.projectName,
      showLeftPanel: false,
      showRightPanel: _selectedConnection != null,
      rightPanel: _selectedConnection != null
          ? _buildConnectionDetails(_selectedConnection!)
          : null,
      child: _buildMainContent(),
    );
  }

  Widget _buildMainContent() {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(_error!),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _loadConnections,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_connections.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.link_off,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No connections yet',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Connections will appear here',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filters
        Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('All Types'),
                selected: _typeFilter == null,
                onSelected: (_) {
                  setState(() {
                    _typeFilter = null;
                  });
                },
              ),
              ...ConnectionType.values.map((type) {
                return FilterChip(
                  label: Text(type.displayName),
                  selected: _typeFilter == type,
                  onSelected: (_) {
                    setState(() {
                      _typeFilter = type;
                    });
                  },
                );
              }),
            ],
          ),
        ),
        // Connection list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _filteredConnections.length,
            itemBuilder: (context, index) {
              final connection = _filteredConnections[index];
              return _ConnectionCard(
                connection: connection,
                isSelected: _selectedConnection?.id == connection.id,
                onTap: () {
                  setState(() {
                    _selectedConnection = connection;
                  });
                },
                onDelete: () => _deleteConnection(connection),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionDetails(ConnectionDefinition connection) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Connection Details',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Type', connection.connectionType.displayName),
          _buildDetailRow('Description', connection.connectionType.description),
          _buildDetailRow('Label', connection.label.isNotEmpty ? connection.label : 'None'),
          _buildDetailRow('Source ID', connection.sourceId),
          _buildDetailRow('Target ID', connection.targetId),
          const SizedBox(height: 16),
          Text(
            'Style',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildDetailRow('Line Style', connection.style.lineStyle.name),
          _buildDetailRow('Arrow Style', connection.style.arrowStyle.name),
          _buildDetailRow('Stroke Width', connection.style.strokeWidth.toString()),
          Row(
            children: [
              Text('Color: ', style: theme.textTheme.bodyMedium),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: connection.style.color,
                  border: Border.all(color: Colors.grey),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// Card widget for displaying a connection.
class _ConnectionCard extends StatelessWidget {
  const _ConnectionCard({
    required this.connection,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
  });

  final ConnectionDefinition connection;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected
          ? theme.colorScheme.primaryContainer.withOpacity(0.3)
          : null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                connection.connectionType.icon,
                color: connection.style.color,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      connection.connectionType.displayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      connection.connectionType.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    if (connection.label.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        connection.label,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: onDelete,
                tooltip: 'Delete',
                color: theme.colorScheme.error,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
