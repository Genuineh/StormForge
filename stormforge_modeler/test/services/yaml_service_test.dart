import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stormforge_modeler/services/yaml_service.dart';
import 'package:stormforge_modeler/models/models.dart';

void main() {
  late YamlService yamlService;

  setUp(() {
    yamlService = YamlService();
  });

  group('YamlService', () {
    group('exportToYaml', () {
      test('exports empty model with header', () {
        const model = CanvasModel();
        final yaml = yamlService.exportToYaml(model);

        expect(yaml, contains('version: "1.0"'));
        expect(yaml, contains('bounded_context:'));
        expect(yaml, contains('name: "GeneratedContext"'));
      });

      test('exports aggregates', () {
        final element = StickyNoteElement.create(
          type: ElementType.aggregate,
          position: const Offset(100, 100),
          label: 'Order',
        );
        final model = CanvasModel(elements: [element]);
        final yaml = yamlService.exportToYaml(model);

        expect(yaml, contains('aggregates:'));
        expect(yaml, contains('Order:'));
        expect(yaml, contains('name: "Order"'));
        expect(yaml, contains('root_entity:'));
      });

      test('exports domain events', () {
        final element = StickyNoteElement.create(
          type: ElementType.domainEvent,
          position: const Offset(100, 100),
          label: 'OrderCreated',
        );
        final model = CanvasModel(elements: [element]);
        final yaml = yamlService.exportToYaml(model);

        expect(yaml, contains('events:'));
        expect(yaml, contains('OrderCreated:'));
        expect(yaml, contains('name: "OrderCreated"'));
      });

      test('exports commands', () {
        final element = StickyNoteElement.create(
          type: ElementType.command,
          position: const Offset(100, 100),
          label: 'CreateOrder',
        );
        final model = CanvasModel(elements: [element]);
        final yaml = yamlService.exportToYaml(model);

        expect(yaml, contains('commands:'));
        expect(yaml, contains('CreateOrder:'));
        expect(yaml, contains('name: "CreateOrder"'));
      });

      test('exports read models as queries', () {
        final element = StickyNoteElement.create(
          type: ElementType.readModel,
          position: const Offset(100, 100),
          label: 'OrderList',
        );
        final model = CanvasModel(elements: [element]);
        final yaml = yamlService.exportToYaml(model);

        expect(yaml, contains('queries:'));
        expect(yaml, contains('GetOrderList:'));
      });

      test('exports policies as comments', () {
        final element = StickyNoteElement.create(
          type: ElementType.policy,
          position: const Offset(100, 100),
          label: 'NotifyOnOrder',
        ).copyWith(description: 'Send notification when order created');
        final model = CanvasModel(elements: [element]);
        final yaml = yamlService.exportToYaml(model);

        expect(yaml, contains('# Policies'));
        expect(yaml, contains('# - NotifyOnOrder'));
      });

      test('exports external systems as comments', () {
        final element = StickyNoteElement.create(
          type: ElementType.externalSystem,
          position: const Offset(100, 100),
          label: 'PaymentGateway',
        );
        final model = CanvasModel(elements: [element]);
        final yaml = yamlService.exportToYaml(model);

        expect(yaml, contains('# External Systems'));
        expect(yaml, contains('# - PaymentGateway'));
      });

      test('exports connections as comments', () {
        final cmd = StickyNoteElement.create(
          type: ElementType.command,
          position: const Offset(100, 100),
          label: 'CreateOrder',
        );
        final event = StickyNoteElement.create(
          type: ElementType.domainEvent,
          position: const Offset(300, 100),
          label: 'OrderCreated',
        );
        final connection = ConnectionElement.create(
          sourceId: cmd.id,
          targetId: event.id,
        );
        final model = CanvasModel(
          elements: [cmd, event],
          connections: [connection],
        );
        final yaml = yamlService.exportToYaml(model);

        expect(yaml, contains('# Connections/Flows'));
        expect(yaml, contains('CreateOrder -> OrderCreated'));
      });

      test('handles special characters in description', () {
        final element = StickyNoteElement.create(
          type: ElementType.aggregate,
          position: const Offset(100, 100),
          label: 'Order',
        ).copyWith(description: 'Test "quotes" and\nnewlines');
        final model = CanvasModel(elements: [element]);
        final yaml = yamlService.exportToYaml(model);

        expect(yaml, contains('\\"quotes\\"'));
        expect(yaml, contains('\\n'));
      });

      test('exports multiple elements of same type', () {
        final elements = [
          StickyNoteElement.create(
            type: ElementType.domainEvent,
            position: const Offset(100, 100),
            label: 'OrderCreated',
          ),
          StickyNoteElement.create(
            type: ElementType.domainEvent,
            position: const Offset(300, 100),
            label: 'OrderPaid',
          ),
          StickyNoteElement.create(
            type: ElementType.domainEvent,
            position: const Offset(500, 100),
            label: 'OrderShipped',
          ),
        ];
        final model = CanvasModel(elements: elements);
        final yaml = yamlService.exportToYaml(model);

        expect(yaml, contains('OrderCreated:'));
        expect(yaml, contains('OrderPaid:'));
        expect(yaml, contains('OrderShipped:'));
      });
    });

    group('importFromYaml', () {
      test('imports aggregates', () {
        const yaml = '''
version: "1.0"
bounded_context:
  name: "Order"
  namespace: "com.example.order"
aggregates:
  Order:
    name: "Order"
    description: "Order aggregate"
''';
        final model = yamlService.importFromYaml(yaml);

        expect(model.elements, hasLength(1));
        expect(model.elements.first.type, ElementType.aggregate);
        expect(model.elements.first.label, 'Order');
      });

      test('imports events', () {
        const yaml = '''
version: "1.0"
bounded_context:
  name: "Order"
  namespace: "com.example.order"
events:
  OrderCreated:
    name: "OrderCreated"
    description: "Order was created"
''';
        final model = yamlService.importFromYaml(yaml);

        expect(
          model.elements.any((e) => e.type == ElementType.domainEvent),
          isTrue,
        );
        expect(model.elements.any((e) => e.label == 'OrderCreated'), isTrue);
      });

      test('imports commands', () {
        const yaml = '''
version: "1.0"
bounded_context:
  name: "Order"
  namespace: "com.example.order"
commands:
  CreateOrder:
    name: "CreateOrder"
    description: "Create a new order"
''';
        final model = yamlService.importFromYaml(yaml);

        expect(
          model.elements.any((e) => e.type == ElementType.command),
          isTrue,
        );
        expect(model.elements.any((e) => e.label == 'CreateOrder'), isTrue);
      });

      test('imports queries as read models', () {
        const yaml = '''
version: "1.0"
bounded_context:
  name: "Order"
  namespace: "com.example.order"
queries:
  GetOrder:
    name: "GetOrder"
    description: "Get order by ID"
''';
        final model = yamlService.importFromYaml(yaml);

        expect(
          model.elements.any((e) => e.type == ElementType.readModel),
          isTrue,
        );
        expect(model.elements.any((e) => e.label == 'GetOrder'), isTrue);
      });

      test('throws on invalid YAML', () {
        const yaml = 'not a valid yaml map';

        expect(() => yamlService.importFromYaml(yaml), throwsFormatException);
      });
    });
  });
}
