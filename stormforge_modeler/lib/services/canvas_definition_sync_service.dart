import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stormforge_modeler/canvas/canvas_controller.dart';
import 'package:stormforge_modeler/models/models.dart';
import 'package:stormforge_modeler/services/api/entity_service.dart';
import 'package:stormforge_modeler/services/api/command_service.dart';
import 'package:stormforge_modeler/services/api/read_model_service.dart';
import 'package:stormforge_modeler/services/providers.dart';

/// Service for bidirectional synchronization between canvas elements and definitions.
class CanvasDefinitionSyncService {
  CanvasDefinitionSyncService({
    required this.ref,
    required this.entityService,
    required this.commandService,
    required this.readModelService,
  });

  final Ref ref;
  final EntityService entityService;
  final CommandService commandService;
  final ReadModelService readModelService;

  /// Synchronizes an aggregate element with its linked entity definition.
  /// Updates the entity's name and description to match the canvas element.
  Future<void> syncAggregateToEntity(CanvasElement aggregate) async {
    if (aggregate.type != ElementType.aggregate || aggregate.entityId == null) {
      return;
    }

    try {
      // Update entity name and description to match canvas element
      await entityService.updateEntity(
        entityId: aggregate.entityId!,
        name: aggregate.label,
        description: aggregate.description.isEmpty ? null : aggregate.description,
      );
    } catch (e) {
      // Log error but don't throw - sync is best-effort
      print('Failed to sync aggregate to entity: $e');
    }
  }

  /// Synchronizes a command element with its linked command definition.
  /// Updates the command's name and description to match the canvas element.
  Future<void> syncCommandToDefinition(CanvasElement command) async {
    if (command.type != ElementType.command || command.commandDefinitionId == null) {
      return;
    }

    try {
      // Update command definition name and description to match canvas element
      await commandService.updateCommand(
        id: command.commandDefinitionId!,
        name: command.label,
        description: command.description.isEmpty ? null : command.description,
      );
    } catch (e) {
      // Log error but don't throw - sync is best-effort
      print('Failed to sync command to definition: $e');
    }
  }

  /// Synchronizes a read model element with its linked read model definition.
  /// Updates the read model's name and description to match the canvas element.
  Future<void> syncReadModelToDefinition(CanvasElement readModel) async {
    if (readModel.type != ElementType.readModel ||
        readModel.readModelDefinitionId == null) {
      return;
    }

    try {
      // Update read model definition name and description to match canvas element
      await readModelService.updateReadModel(
        id: readModel.readModelDefinitionId!,
        name: readModel.label,
        description: readModel.description.isEmpty ? null : readModel.description,
      );
    } catch (e) {
      // Log error but don't throw - sync is best-effort
      print('Failed to sync read model to definition: $e');
    }
  }

  /// Synchronizes canvas element back from its definition.
  /// Pulls the latest name and description from the definition to the canvas.
  Future<void> syncDefinitionToCanvas(CanvasElement element) async {
    try {
      if (element.type == ElementType.aggregate && element.entityId != null) {
        final entity = await entityService.getEntity(element.entityId!);
        _updateCanvasElement(
          element,
          label: entity.name,
          description: entity.description,
        );
      } else if (element.type == ElementType.command &&
          element.commandDefinitionId != null) {
        final command = await commandService.getCommand(element.commandDefinitionId!);
        _updateCanvasElement(
          element,
          label: command.name,
          description: command.description,
        );
      } else if (element.type == ElementType.readModel &&
          element.readModelDefinitionId != null) {
        final readModel =
            await readModelService.getReadModel(element.readModelDefinitionId!);
        _updateCanvasElement(
          element,
          label: readModel.name,
          description: readModel.description,
        );
      }
    } catch (e) {
      // Log error but don't throw - sync is best-effort
      print('Failed to sync definition to canvas: $e');
    }
  }

  void _updateCanvasElement(
    CanvasElement element, {
    required String label,
    String? description,
  }) {
    // Update canvas element using the controller
    ref.read(canvasModelProvider.notifier).updateElement(
          element.copyWith(
            label: label,
            description: description ?? '',
          ),
        );
  }

  /// Synchronizes all linked elements in the canvas.
  /// This can be called periodically or after significant changes.
  Future<void> syncAllLinkedElements() async {
    final canvasModel = ref.read(canvasModelProvider);

    for (final element in canvasModel.elements) {
      // Sync canvas to definitions
      if (element.entityId != null) {
        await syncAggregateToEntity(element);
      }
      if (element.commandDefinitionId != null) {
        await syncCommandToDefinition(element);
      }
      if (element.readModelDefinitionId != null) {
        await syncReadModelToDefinition(element);
      }
    }
  }

  /// Performs a full bidirectional sync for a specific element.
  Future<void> syncElement(CanvasElement element) async {
    // First sync from canvas to definition
    await syncAggregateToEntity(element);
    await syncCommandToDefinition(element);
    await syncReadModelToDefinition(element);

    // Then sync back from definition to canvas (to get any server-side changes)
    await syncDefinitionToCanvas(element);
  }
}

/// Provider for the canvas-definition sync service.
final canvasDefinitionSyncServiceProvider = Provider<CanvasDefinitionSyncService>((ref) {
  return CanvasDefinitionSyncService(
    ref: ref,
    entityService: ref.read(entityServiceProvider),
    commandService: ref.read(commandServiceProvider),
    readModelService: ref.read(readModelServiceProvider),
  );
});
