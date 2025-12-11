// Placeholder for connection designer screen - implementation shortened for file size
import 'package:flutter/material.dart';

class ConnectionDesignerScreen extends StatelessWidget {
  const ConnectionDesignerScreen({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  final String projectId;
  final String projectName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connections')),
      body: const Center(child: Text('Connection Designer - Coming Soon')),
    );
  }
}
