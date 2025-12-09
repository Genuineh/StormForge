# StormForge

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-3.24+-blue.svg)](https://flutter.dev)
[![Rust](https://img.shields.io/badge/Rust-1.75+-orange.svg)](https://www.rust-lang.org)

**全球第一个「AI + EventStorming + 多微服务 + 同时生成 Rust 后端 + Flutter 前端专属 API 包」的企业级低代码平台**

*The world's first enterprise-grade low-code platform combining AI + EventStorming + Multi-microservices + Automatic Rust Backend + Flutter API Package Generation*

## 🎯 Core Vision

- **All business modeling** done on Flutter cross-platform canvas (Web + Windows + macOS + iPad)
- **Each Bounded Context** = 1 independent Rust microservice + 1 independent Flutter API package (Dart)
- **Frontend integration**: Just `flutter pub add acme_order_service` → All domain interfaces, types, and real-time events ready, truly zero integration work
- **Pure domain API packages** - No UI generation, only the cleanest, strongly-typed domain API packages

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                     StormForge Platform                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌─────────────────────┐    ┌─────────────────────┐                │
│  │   Flutter Modeler   │    │     AI Assistant    │                │
│  │  (EventStorming     │◄──►│  (Claude/Grok/      │                │
│  │   Canvas)           │    │   通义千问)          │                │
│  └─────────┬───────────┘    └─────────────────────┘                │
│            │                                                        │
│            ▼                                                        │
│  ┌─────────────────────┐                                           │
│  │   IR (YAML Model)   │ ◄── Model as Code (Git Versioned)        │
│  └─────────┬───────────┘                                           │
│            │                                                        │
│    ┌───────┴───────┐                                               │
│    ▼               ▼                                               │
│  ┌───────────┐  ┌───────────────┐                                  │
│  │   Rust    │  │  Dart Package │                                  │
│  │ Generator │  │   Generator   │                                  │
│  └─────┬─────┘  └───────┬───────┘                                  │
│        │                │                                          │
│        ▼                ▼                                          │
│  ┌───────────┐  ┌───────────────┐                                  │
│  │   Axum    │  │ Flutter API   │                                  │
│  │Microservice│  │   Package     │                                  │
│  │(EventSource)│  │(Types+Events)│                                  │
│  └───────────┘  └───────────────┘                                  │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

## 🛠️ Tech Stack

| Layer | Technology |
|-------|------------|
| Modeling Frontend | Flutter 3.24+ (Web + Desktop + iOS/Android) |
| Canvas Engine | Custom EventStorming Canvas (CustomPainter + Impeller) |
| Model Storage | Git + YAML (Model as Code) |
| AI Models | Claude 3.5 → Grok 4 → 通义千问-max |
| Backend Generator | Rust (Axum + sqlx + EventSourcing + utoipa) |
| Frontend API Package | Dart Package (auto-generated, published to private pub or git) |
| Cross-domain Events | Kafka / NATS / RabbitMQ (auto-generated publisher + subscriber) |
| Global Event Bus | Dart lightweight event_bus + auto WebSocket/NATS connection |
| Plugin System | VS Code Marketplace style (external systems, generators, adapters) |
| Deployment | GitOps + ArgoCD + Helm + Sealos |

## 📦 Project Structure

```
StormForge/
├── stormforge_modeler/          # Flutter modeling application
│   ├── lib/
│   │   ├── canvas/              # EventStorming canvas
│   │   ├── models/              # Domain models
│   │   ├── widgets/             # UI components
│   │   └── services/            # Business services
│   └── test/
├── stormforge_generator/         # Rust code generator
│   ├── src/
│   │   ├── rust/                # Rust microservice generator
│   │   ├── templates/           # Code templates
│   │   └── ir/                  # IR parser
│   └── tests/
├── stormforge_dart_generator/    # Flutter/Dart API package generator
│   ├── lib/
│   │   ├── generators/          # Package generators
│   │   └── templates/           # Dart templates
│   └── test/
├── ir_schema/                    # Intermediate Representation schema
│   ├── schema/                  # JSON Schema definitions
│   └── examples/                # Example IR files
├── examples/                     # Complete working examples
│   ├── acme_ecommerce/          # E-commerce example
│   └── hr_leave_system/         # HR leave system example
└── docs/                         # Documentation
    ├── ROADMAP.md               # Development roadmap
    ├── ARCHITECTURE.md          # Architecture details
    └── guides/                  # User guides
```

## 🚀 Quick Start

> **Note**: This project is currently in the initialization phase. Code implementation will follow the development roadmap.

### Prerequisites

- Flutter SDK 3.24+
- Rust 1.75+
- Docker (for local development)
- Git

### Installation

```bash
# Clone the repository
git clone https://github.com/Genuineh/StormForge.git
cd StormForge

# More installation steps will be added as the project develops
```

## 📅 Development Roadmap

See [docs/ROADMAP.md](docs/ROADMAP.md) for the complete development plan.

For detailed sprint progress and completion reports, see [docs/sprints/](docs/sprints/README.md).

### Key Milestones

| Phase | Timeline | Milestone | Description |
|-------|----------|-----------|-------------|
| 0 | 2025.10 - 2025.11 | POC | Complete end-to-end flow in 30 minutes |
| 1 | 2025.11 - 2026.Q2 | MVP | Rust + Flutter API Package MVP + Modeler 2.0 |
| 2 | 2026.Q3+ | Ecosystem | Multi-microservice + Plugin ecosystem |
| 3 | 2027.Q1+ | Enterprise | Enterprise-grade + Incremental + Reverse engineering |
| 4 | 2027.Q3+ | Platform | Platform-level + Open source + Commercialization |

### Current Progress

- ✅ **Phase 0**: POC Complete (Sprint S00-S03)
- 🚧 **Phase 1**: MVP In Progress 
  - Sprint S04: 90% complete (Dart generator)
  - Backend architecture: Established
  - Core features: In development
- 🚧 **Modeler 2.0**: Design Complete, Implementation In Progress
  - Detailed design documents: Complete
  - Backend models and API: 40% complete
  - Frontend UI: 15% complete

> **Note**: Progress percentages are calculated as: Design (20%) + Implementation (60%) + Testing (20%). See [TODO.md](TODO.md) for detailed progress tracking methodology.

## 🎨 Usage Example

Once fully developed, the generated Flutter API package will work like this:

```dart
// pub add acme_order_service
import 'package:acme_order_service/acme_order_service.dart';

// Send commands
await OrderCommand().createOrder(CreateOrderPayload(...));

// Query data
final order = await OrderQuery().getOrder('ord_123');
final list = await OrderQuery().listOrders(status: 'paid');

// Real-time events (auto-connected globally)
EventBus().on<OrderPaid>((event) {
  showToast('Payment successful: ${event.orderId}');
  ref.invalidate(orderListProvider);
});
```

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📚 Documentation

- **[TODO.md](TODO.md)** - Current project status and task tracking
- **[Sprint Archives](docs/sprints/README.md)** - Completed sprint reports and progress
- **[Roadmap](docs/ROADMAP.md)** - Complete development plan
- **[Architecture](docs/ARCHITECTURE.md)** - System architecture and design
- **[User Guides](docs/guides/)** - Getting started and user documentation
- **[Design Documents](docs/designs/)** - Detailed design specifications

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Contact

- **Project Lead**: Jerry
- **Start Date**: October 9, 2025

---

*StormForge - Revolutionizing enterprise software development through AI-powered domain-driven design.*