import 'package:flutter/material.dart';

import 'package:stormforge_modeler/models/entity_model.dart';
import 'package:stormforge_modeler/screens/entities/widgets/invariant_editor.dart';
import 'package:stormforge_modeler/screens/entities/widgets/method_editor.dart';
import 'package:stormforge_modeler/screens/entities/widgets/property_grid_editor.dart';
import 'package:stormforge_modeler/services/api/entity_service.dart';

/// Details panel for editing an entity.
class EntityDetailsPanel extends StatefulWidget {
  const EntityDetailsPanel({
    super.key,
    required this.entity,
    required this.entityService,
    required this.onEntityUpdated,
  });

  final EntityDefinition entity;
  final EntityService entityService;
  final void Function(EntityDefinition) onEntityUpdated;

  @override
  State<EntityDetailsPanel> createState() => _EntityDetailsPanelState();
}

class _EntityDetailsPanelState extends State<EntityDetailsPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _updateControllers();
  }

  @override
  void didUpdateWidget(EntityDetailsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entity.id != widget.entity.id) {
      _updateControllers();
    }
  }

  void _updateControllers() {
    _nameController.text = widget.entity.name;
    _descriptionController.text = widget.entity.description ?? '';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _updateBasicInfo() async {
    try {
      final updated = await widget.entityService.updateEntity(
        entityId: widget.entity.id,
        name: _nameController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
      );
      widget.onEntityUpdated(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entity updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update entity: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Basic info section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _updateBasicInfo,
                    child: const Text('Save'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  Chip(
                    label: Text(_formatEntityType(widget.entity.entityType)),
                    avatar: const Icon(Icons.label, size: 16),
                  ),
                  Chip(
                    label: Text('${widget.entity.properties.length} Properties'),
                  ),
                  Chip(
                    label: Text('${widget.entity.methods.length} Methods'),
                  ),
                  Chip(
                    label: Text('${widget.entity.invariants.length} Invariants'),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Tabs section
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Properties'),
            Tab(text: 'Methods'),
            Tab(text: 'Invariants'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Overview tab
              _buildOverviewTab(),
              // Properties tab
              PropertyGridEditor(
                entity: widget.entity,
                entityService: widget.entityService,
                onEntityUpdated: widget.onEntityUpdated,
              ),
              // Methods tab
              MethodEditor(
                entity: widget.entity,
                entityService: widget.entityService,
                onEntityUpdated: widget.onEntityUpdated,
              ),
              // Invariants tab
              InvariantEditor(
                entity: widget.entity,
                entityService: widget.entityService,
                onEntityUpdated: widget.onEntityUpdated,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection('Entity Information', [
            _buildInfoRow('ID', widget.entity.id),
            _buildInfoRow('Project ID', widget.entity.projectId),
            _buildInfoRow('Type', _formatEntityType(widget.entity.entityType)),
            if (widget.entity.aggregateId != null)
              _buildInfoRow('Aggregate ID', widget.entity.aggregateId!),
          ]),
          const SizedBox(height: 24),
          _buildInfoSection('Statistics', [
            _buildInfoRow('Properties', widget.entity.properties.length.toString()),
            _buildInfoRow('Methods', widget.entity.methods.length.toString()),
            _buildInfoRow('Invariants', widget.entity.invariants.length.toString()),
          ]),
          const SizedBox(height: 24),
          _buildInfoSection('Timestamps', [
            _buildInfoRow('Created', _formatDateTime(widget.entity.createdAt)),
            _buildInfoRow('Updated', _formatDateTime(widget.entity.updatedAt)),
          ]),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatEntityType(EntityType type) {
    switch (type) {
      case EntityType.entity:
        return 'Entity';
      case EntityType.aggregateRoot:
        return 'Aggregate Root';
      case EntityType.valueObject:
        return 'Value Object';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
