import 'package:flutter/material.dart';

/// Type selector dialog for choosing property types.
class TypeSelector extends StatefulWidget {
  const TypeSelector({super.key});

  @override
  State<TypeSelector> createState() => _TypeSelectorState();
}

class _TypeSelectorState extends State<TypeSelector> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Common types
  static const List<String> _primitiveTypes = [
    'String',
    'int',
    'double',
    'bool',
    'DateTime',
    'Duration',
  ];

  static const List<String> _commonTypes = [
    'UUID',
    'Email',
    'PhoneNumber',
    'URL',
    'Money',
    'Address',
    'GeoLocation',
  ];

  static const List<String> _collectionTypes = [
    'List<String>',
    'List<int>',
    'Set<String>',
    'Map<String, dynamic>',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> _getFilteredTypes() {
    if (_searchQuery.isEmpty) {
      return [..._primitiveTypes, ..._commonTypes, ..._collectionTypes];
    }
    
    final query = _searchQuery.toLowerCase();
    return [
      ..._primitiveTypes.where((t) => t.toLowerCase().contains(query)),
      ..._commonTypes.where((t) => t.toLowerCase().contains(query)),
      ..._collectionTypes.where((t) => t.toLowerCase().contains(query)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final filteredTypes = _getFilteredTypes();

    return AlertDialog(
      title: const Text('Select Type'),
      content: SizedBox(
        width: 400,
        height: 500,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search or enter custom type',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),
            if (_searchQuery.isNotEmpty) ...[
              ListTile(
                leading: const Icon(Icons.add_circle),
                title: Text('Use custom type: "$_searchQuery"'),
                onTap: () => Navigator.pop(context, _searchQuery),
              ),
              const Divider(),
            ],
            Expanded(
              child: ListView(
                children: [
                  if (_searchQuery.isEmpty) ...[
                    _buildTypeSection('Primitive Types', _primitiveTypes),
                    _buildTypeSection('Common Types', _commonTypes),
                    _buildTypeSection('Collection Types', _collectionTypes),
                  ] else ...[
                    ...filteredTypes.map((type) => ListTile(
                          title: Text(type),
                          onTap: () => Navigator.pop(context, type),
                        )),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget _buildTypeSection(String title, List<String> types) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        ...types.map((type) => ListTile(
              title: Text(type),
              onTap: () => Navigator.pop(context, type),
            )),
        const Divider(),
      ],
    );
  }
}
