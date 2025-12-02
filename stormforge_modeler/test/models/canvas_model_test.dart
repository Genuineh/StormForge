import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stormforge_modeler/models/canvas_model.dart';
import 'package:stormforge_modeler/models/element_model.dart';

void main() {
  group('CanvasModel', () {
    test('creates with empty collections', () {
      const model = CanvasModel();

      expect(model.elements, isEmpty);
      expect(model.connections, isEmpty);
      expect(model.contexts, isEmpty);
      expect(model.selectedElementId, isNull);
    });

    test('addElement adds and selects element', () {
      const model = CanvasModel();
      final element = StickyNoteElement.create(
        type: ElementType.domainEvent,
        position: const Offset(100, 100),
      );

      final updated = model.addElement(element);

      expect(updated.elements, hasLength(1));
      expect(updated.elements.first.id, element.id);
      expect(updated.selectedElementId, element.id);
    });

    test('removeElement removes element and clears selection', () {
      final element = StickyNoteElement.create(
        type: ElementType.domainEvent,
        position: const Offset(100, 100),
      );
      final model = CanvasModel(
        elements: [element],
        selectedElementId: element.id,
      );

      final updated = model.removeElement(element.id);

      expect(updated.elements, isEmpty);
      expect(updated.selectedElementId, isNull);
    });

    test('removeElement removes associated connections', () {
      final element1 = StickyNoteElement.create(
        type: ElementType.command,
        position: const Offset(100, 100),
      );
      final element2 = StickyNoteElement.create(
        type: ElementType.domainEvent,
        position: const Offset(300, 100),
      );
      final connection = ConnectionElement.create(
        sourceId: element1.id,
        targetId: element2.id,
      );
      final model = CanvasModel(
        elements: [element1, element2],
        connections: [connection],
      );

      final updated = model.removeElement(element1.id);

      expect(updated.elements, hasLength(1));
      expect(updated.connections, isEmpty);
    });

    test('updateElement updates existing element', () {
      final element = StickyNoteElement.create(
        type: ElementType.aggregate,
        position: const Offset(100, 100),
        label: 'Original',
      );
      final model = CanvasModel(elements: [element]);

      final updatedElement = element.copyWith(label: 'Updated');
      final updated = model.updateElement(updatedElement);

      expect(updated.elements.first.label, 'Updated');
    });

    test('selectElement updates selection', () {
      final element = StickyNoteElement.create(
        type: ElementType.policy,
        position: const Offset(100, 100),
      );
      final model = CanvasModel(elements: [element]);

      final updated = model.selectElement(element.id);

      expect(updated.selectedElementId, element.id);
    });

    test('clearSelection removes all selections', () {
      final element = StickyNoteElement.create(
        type: ElementType.readModel,
        position: const Offset(100, 100),
      );
      final connection = ConnectionElement.create(
        sourceId: 'source',
        targetId: 'target',
      );
      final model = CanvasModel(
        elements: [element],
        connections: [connection],
        selectedElementId: element.id,
        selectedConnectionId: connection.id,
      );

      final updated = model.clearSelection();

      expect(updated.selectedElementId, isNull);
      expect(updated.selectedConnectionId, isNull);
      expect(updated.selectedContextId, isNull);
    });

    test('getElementById returns correct element', () {
      final element = StickyNoteElement.create(
        type: ElementType.externalSystem,
        position: const Offset(100, 100),
      );
      final model = CanvasModel(elements: [element]);

      expect(model.getElementById(element.id), element);
      expect(model.getElementById('nonexistent'), isNull);
    });

    test('selectedElement returns selected element', () {
      final element = StickyNoteElement.create(
        type: ElementType.ui,
        position: const Offset(100, 100),
      );
      final model = CanvasModel(
        elements: [element],
        selectedElementId: element.id,
      );

      expect(model.selectedElement, element);
    });
  });

  group('CanvasViewport', () {
    test('creates with default values', () {
      const viewport = CanvasViewport();

      expect(viewport.offset, Offset.zero);
      expect(viewport.scale, 1.0);
    });

    test('copyWith respects scale limits', () {
      const viewport = CanvasViewport();

      final tooSmall = viewport.copyWith(scale: 0.01);
      final tooLarge = viewport.copyWith(scale: 10.0);

      expect(tooSmall.scale, CanvasViewport.minScale);
      expect(tooLarge.scale, CanvasViewport.maxScale);
    });

    test('screenToCanvas transforms correctly', () {
      const viewport = CanvasViewport(offset: Offset(100, 50), scale: 2.0);

      final canvasPos = viewport.screenToCanvas(const Offset(200, 150));

      expect(canvasPos, const Offset(50, 50));
    });

    test('canvasToScreen transforms correctly', () {
      const viewport = CanvasViewport(offset: Offset(100, 50), scale: 2.0);

      final screenPos = viewport.canvasToScreen(const Offset(50, 50));

      expect(screenPos, const Offset(200, 150));
    });

    test('transformations are inverse', () {
      const viewport = CanvasViewport(offset: Offset(123, 456), scale: 1.5);
      const original = Offset(100, 200);

      final canvasPos = viewport.screenToCanvas(original);
      final backToScreen = viewport.canvasToScreen(canvasPos);

      expect(backToScreen.dx, closeTo(original.dx, 0.001));
      expect(backToScreen.dy, closeTo(original.dy, 0.001));
    });
  });

  group('BoundedContext', () {
    test('create generates unique ID', () {
      final ctx1 = BoundedContext.create(
        name: 'Context',
        namespace: 'com.example',
      );
      final ctx2 = BoundedContext.create(
        name: 'Context',
        namespace: 'com.example',
      );

      expect(ctx1.id, isNot(equals(ctx2.id)));
    });

    test('containsPoint returns correct results', () {
      final context = BoundedContext.create(
        name: 'Order',
        namespace: 'com.example.order',
        bounds: const Rect.fromLTWH(100, 100, 400, 300),
      );

      expect(context.containsPoint(const Offset(200, 200)), isTrue);
      expect(context.containsPoint(const Offset(50, 50)), isFalse);
    });
  });
}
