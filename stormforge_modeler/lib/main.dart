import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:stormforge_modeler/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize logger
  Logger.level = Level.debug;
  final logger = Logger();

  logger.d('Starting StormForge Modeler application...');
  logger.d('Flutter binding initialized');

  runApp(const ProviderScope(child: StormForgeModelerApp()));
}
