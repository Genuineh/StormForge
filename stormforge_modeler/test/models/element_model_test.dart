import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stormforge_modeler/models/element_model.dart';

void main() {
  group('ElementType', () {
    test('displayName returns correct names', () {
      expect(ElementType.domainEvent.displayName, 'Domain Event');
      expect(ElementType.command.displayName, 'Command');
      expect(ElementType.aggregate.displayName, 'Aggregate');
      expect(ElementType.policy.displayName, 'Policy');
      expect(ElementType.readModel.displayName, 'Read Model');
      expect(ElementType.externalSystem.displayName, 'External System');
      expect(ElementType.ui.displayName, 'UI');
    });

    test('backgroundColor returns distinct colors', () {
      final colors = ElementType.values.map((e) => e.backgroundColor).toSet();
      expect(colors.length, ElementType.values.length);
    });

    test('textColor provides contrast', () {
      // Dark backgrounds should have white text
      expect(ElementType.domainEvent.textColor, Colors.white);
      expect(ElementType.command.textColor, Colors.white);
      expect(ElementType.policy.textColor, Colors.white);
      expect(ElementType.externalSystem.textColor, Colors.white);

      // Light backgrounds should have dark text
      expect(ElementType.aggregate.textColor, Colors.black87);
      expect(ElementType.ui.textColor, Colors.black87);
    });
  });

  group('StickyNoteElement', () {
    test('create generates unique IDs', () {
      final element1 = StickyNoteElement.create(
        type: ElementType.domainEvent,
        position: const Offset(100, 100),
      );
      final element2 = StickyNoteElement.create(
        type: ElementType.domainEvent,
        position: const Offset(100, 100),
      );

      expect(element1.id, isNot(equals(element2.id)));
    });

    test('create uses default label from type', () {
      final element = StickyNoteElement.create(
        type: ElementType.command,
        position: const Offset(0, 0),
      );

      expect(element.label, 'Command');
    });

    test('create uses custom label when provided', () {
      final element = StickyNoteElement.create(
        type: ElementType.domainEvent,
        position: const Offset(0, 0),
        label: 'OrderCreated',
      );

      expect(element.label, 'OrderCreated');
    });

    test('containsPoint returns correct results', () {
      final element = StickyNoteElement.create(
        type: ElementType.aggregate,
        position: const Offset(100, 100),
      );

      // Point inside the element
      expect(element.containsPoint(const Offset(150, 150)), isTrue);

      // Point outside the element
      expect(element.containsPoint(const Offset(50, 50)), isFalse);
      expect(element.containsPoint(const Offset(300, 300)), isFalse);
    });

    test('bounds returns correct rectangle', () {
      final element = StickyNoteElement(
        id: 'test-id',
        type: ElementType.aggregate,
        position: const Offset(100, 200),
        size: const Size(150, 100),
        label: 'Test',
      );

      expect(element.bounds, const Rect.fromLTWH(100, 200, 150, 100));
    });

    test('copyWith creates modified copy', () {
      final element = StickyNoteElement(
        id: 'test-id',
        type: ElementType.aggregate,
        position: const Offset(100, 100),
        size: const Size(150, 100),
        label: 'Original',
        description: 'Original description',
        isSelected: false,
      );

      final modified = element.copyWith(
        position: const Offset(200, 200),
        label: 'Modified',
        isSelected: true,
      );

      expect(modified.id, element.id);
      expect(modified.type, element.type);
      expect(modified.position, const Offset(200, 200));
      expect(modified.size, element.size);
      expect(modified.label, 'Modified');
      expect(modified.description, element.description);
      expect(modified.isSelected, isTrue);
    });
  });

  group('ConnectionElement', () {
    test('create generates unique IDs', () {
      final conn1 = ConnectionElement.create(
        sourceId: 'source',
        targetId: 'target',
      );
      final conn2 = ConnectionElement.create(
        sourceId: 'source',
        targetId: 'target',
      );

      expect(conn1.id, isNot(equals(conn2.id)));
    });

    test('copyWith creates modified copy', () {
      final connection = ConnectionElement(
        id: 'test-id',
        sourceId: 'source',
        targetId: 'target',
        label: 'Original',
        isSelected: false,
      );

      final modified = connection.copyWith(label: 'Modified', isSelected: true);

      expect(modified.id, connection.id);
      expect(modified.sourceId, connection.sourceId);
      expect(modified.targetId, connection.targetId);
      expect(modified.label, 'Modified');
      expect(modified.isSelected, isTrue);
    });
  });
}
