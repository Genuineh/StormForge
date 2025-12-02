# StormForge Dart Generator

> Flutter/Dart API package generator from IR models

## Overview

The StormForge Dart Generator creates strongly-typed Dart packages from IR models. These packages provide a clean API for Flutter applications to interact with generated microservices, including commands, queries, and real-time event handling.

## Features (Planned)

- **Type Generation**: Generate Dart classes from domain models
- **Command Classes**: CQRS command implementation
- **Query Classes**: Type-safe query methods
- **Event Bus Integration**: Real-time event handling
- **HTTP Client**: Generated API client
- **Package Publishing**: Auto-publish to private pub or git

## Project Structure

```
stormforge_dart_generator/
├── lib/
│   ├── generators/       # Code generation logic
│   ├── templates/        # Code templates
│   ├── ir/               # IR reading utilities
│   └── output/           # File output handling
└── test/                 # Test files
```

## Getting Started

> This project is in the initialization phase. Code implementation will follow.

### Prerequisites

- Dart SDK 3.5+

### Building

```bash
cd stormforge_dart_generator
dart pub get
```

### Usage

```bash
# Generate Dart package from IR
dart run stormforge_dart_generator generate --input model.yaml --output ./packages/order_service
```

## Generated Package Structure

```
order_service/
├── pubspec.yaml
├── lib/
│   ├── order_service.dart      # Main export
│   ├── src/
│   │   ├── types/              # Domain types
│   │   │   └── order.dart
│   │   ├── commands/           # Command classes
│   │   │   └── order_commands.dart
│   │   ├── queries/            # Query classes
│   │   │   └── order_queries.dart
│   │   ├── events/             # Event types
│   │   │   └── order_events.dart
│   │   └── client/             # HTTP client
│   │       └── order_client.dart
└── test/
```

## Usage Example

```dart
// In your Flutter app
import 'package:order_service/order_service.dart';

// Initialize client
final orderService = OrderService(baseUrl: 'https://api.example.com');

// Send command
await orderService.commands.createOrder(CreateOrderPayload(
  customerId: 'cust_123',
  items: [OrderItem(productId: 'prod_456', quantity: 2)],
));

// Query data
final order = await orderService.queries.getOrder('order_789');

// Listen to events
orderService.events.on<OrderPaid>((event) {
  print('Order ${event.orderId} was paid!');
});
```

## Development Status

- [x] Project structure defined
- [ ] Type generator implementation
- [ ] Command class generation
- [ ] Query class generation
- [ ] Event handling generation
- [ ] HTTP client generation
- [ ] Package configuration generation

## License

MIT License - See [LICENSE](../LICENSE) for details.
