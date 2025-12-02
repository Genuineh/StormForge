import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stormforge_modeler/canvas/canvas_widget.dart';
import 'package:stormforge_modeler/widgets/toolbar.dart';
import 'package:stormforge_modeler/widgets/element_palette.dart';
import 'package:stormforge_modeler/widgets/property_panel.dart';

/// The main StormForge Modeler application.
class StormForgeModelerApp extends StatelessWidget {
  const StormForgeModelerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StormForge Modeler',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const ModelerHomePage(),
    );
  }
}

/// The main home page containing the modeling workspace.
class ModelerHomePage extends ConsumerStatefulWidget {
  const ModelerHomePage({super.key});

  @override
  ConsumerState<ModelerHomePage> createState() => _ModelerHomePageState();
}

class _ModelerHomePageState extends ConsumerState<ModelerHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top toolbar
          const ModelerToolbar(),

          // Main content area
          Expanded(
            child: Row(
              children: [
                // Left panel - Element palette
                const SizedBox(width: 250, child: ElementPalette()),

                // Vertical divider
                const VerticalDivider(width: 1),

                // Center - Canvas
                const Expanded(child: EventStormingCanvas()),

                // Vertical divider
                const VerticalDivider(width: 1),

                // Right panel - Property panel
                const SizedBox(width: 300, child: PropertyPanel()),
              ],
            ),
          ),

          // Bottom status bar
          const _StatusBar(),
        ],
      ),
    );
  }
}

/// Status bar at the bottom of the window.
class _StatusBar extends ConsumerWidget {
  const _StatusBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Text('StormForge Modeler v0.1.0', style: theme.textTheme.bodySmall),
          const Spacer(),
          Text('Ready', style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
