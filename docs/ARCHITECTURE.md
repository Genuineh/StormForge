# StormForge Architecture

> Technical architecture documentation for StormForge platform
> Version: 1.0.0 (Initial)

---

## 📐 System Architecture

### High-Level Overview

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              StormForge Platform                                 │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  ┌──────────────────────────────────────────────────────────────────────────┐  │
│  │                         MODELING LAYER                                    │  │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────────────┐  │  │
│  │  │ Flutter Modeler │  │  AI Assistant   │  │  Collaboration Engine   │  │  │
│  │  │  (Canvas App)   │◄─┤ (Claude/Grok)   │  │  (Real-time Sync)       │  │  │
│  │  └────────┬────────┘  └─────────────────┘  └─────────────────────────┘  │  │
│  └───────────┼──────────────────────────────────────────────────────────────┘  │
│              │                                                                  │
│              ▼                                                                  │
│  ┌──────────────────────────────────────────────────────────────────────────┐  │
│  │                      INTERMEDIATE REPRESENTATION                          │  │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────────────┐  │  │
│  │  │   IR Schema     │  │  YAML Storage   │  │  Git Version Control    │  │  │
│  │  │   (JSON Schema) │  │  (Model Files)  │  │  (History + Branching)  │  │  │
│  │  └────────┬────────┘  └────────┬────────┘  └─────────────────────────┘  │  │
│  └───────────┼────────────────────┼─────────────────────────────────────────┘  │
│              │                    │                                             │
│              ▼                    ▼                                             │
│  ┌──────────────────────────────────────────────────────────────────────────┐  │
│  │                        GENERATION LAYER                                   │  │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────────────┐  │  │
│  │  │ Backend         │  │ Frontend        │  │  Plugin Generators      │  │  │
│  │  │ Generators      │  │ Package         │  │  (Community)            │  │  │
│  │  │ (Rust/Java/...)│  │ Generator       │  │                         │  │  │
│  │  └────────┬────────┘  └────────┬────────┘  └─────────────────────────┘  │  │
│  └───────────┼────────────────────┼─────────────────────────────────────────┘  │
│              │                    │                                             │
│              ▼                    ▼                                             │
│  ┌──────────────────────────────────────────────────────────────────────────┐  │
│  │                         OUTPUT LAYER                                      │  │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────────────┐  │  │
│  │  │ Rust Microservice│  │ Dart Package   │  │  Infrastructure         │  │  │
│  │  │ (Axum+sqlx)     │  │ (API + Events) │  │  (Docker/K8s/Helm)     │  │  │
│  │  └─────────────────┘  └─────────────────┘  └─────────────────────────┘  │  │
│  └──────────────────────────────────────────────────────────────────────────┘  │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## 🏗️ Component Architecture

### 1. Flutter Modeler (stormforge_modeler)

The cross-platform modeling application built with Flutter.

```
stormforge_modeler/
├── lib/
│   ├── main.dart                    # Application entry point
│   ├── app.dart                     # App configuration
│   │
│   ├── canvas/                      # EventStorming canvas
│   │   ├── canvas_widget.dart       # Main canvas CustomPainter
│   │   ├── canvas_controller.dart   # State management
│   │   ├── elements/                # Canvas element types
│   │   │   ├── domain_event.dart    # Orange - Domain Event
│   │   │   ├── command.dart         # Blue - Command
│   │   │   ├── aggregate.dart       # Yellow - Aggregate
│   │   │   ├── policy.dart          # Purple - Policy
│   │   │   ├── read_model.dart      # Green - Read Model
│   │   │   ├── external_system.dart # Pink - External System
│   │   │   └── ui_element.dart      # White - UI Element
│   │   ├── interactions/            # User interactions
│   │   │   ├── drag_handler.dart
│   │   │   ├── zoom_handler.dart
│   │   │   └── selection_handler.dart
│   │   └── rendering/               # Rendering engine
│   │       ├── impeller_renderer.dart
│   │       └── layout_engine.dart
│   │
│   ├── models/                      # Domain models
│   │   ├── bounded_context.dart     # Bounded Context model
│   │   ├── aggregate_model.dart     # Aggregate model
│   │   ├── event_model.dart         # Domain event model
│   │   └── relationship.dart        # Element relationships
│   │
│   ├── ir/                          # Intermediate Representation
│   │   ├── ir_schema.dart           # IR type definitions
│   │   ├── yaml_serializer.dart     # YAML serialization
│   │   └── yaml_parser.dart         # YAML parsing
│   │
│   ├── services/                    # Business services
│   │   ├── project_service.dart     # Project management
│   │   ├── git_service.dart         # Git integration
│   │   ├── ai_service.dart          # AI model generation
│   │   └── export_service.dart      # Export functionality
│   │
│   └── widgets/                     # Reusable UI components
│       ├── toolbar.dart
│       ├── property_panel.dart
│       ├── context_menu.dart
│       └── element_palette.dart
│
├── test/                            # Test files
│   ├── canvas/
│   ├── models/
│   └── services/
│
└── pubspec.yaml
```

### 2. Rust Generator (stormforge_generator)

The code generator for Rust microservices.

```
stormforge_generator/
├── src/
│   ├── main.rs                      # CLI entry point
│   │
│   ├── ir/                          # IR parsing
│   │   ├── mod.rs
│   │   ├── parser.rs                # YAML IR parser
│   │   └── types.rs                 # IR type definitions
│   │
│   ├── generators/                  # Code generators
│   │   ├── mod.rs
│   │   ├── rust/                    # Rust generator
│   │   │   ├── mod.rs
│   │   │   ├── project.rs           # Project scaffold
│   │   │   ├── entity.rs            # Entity generation
│   │   │   ├── command.rs           # Command handlers
│   │   │   ├── query.rs             # Query handlers
│   │   │   ├── event.rs             # Event definitions
│   │   │   ├── repository.rs        # Repository pattern
│   │   │   └── api.rs               # API endpoints
│   │   │
│   │   └── common/                  # Shared utilities
│   │       ├── naming.rs            # Naming conventions
│   │       └── formatting.rs        # Code formatting
│   │
│   ├── templates/                   # Code templates
│   │   ├── axum/
│   │   │   ├── main.rs.tera
│   │   │   ├── cargo.toml.tera
│   │   │   └── entity.rs.tera
│   │   └── sqlx/
│   │       └── migrations.sql.tera
│   │
│   └── output/                      # Output handling
│       ├── mod.rs
│       ├── file_writer.rs
│       └── project_structure.rs
│
├── tests/
│   ├── integration/
│   └── fixtures/
│
└── Cargo.toml
```

### 3. Dart Package Generator (stormforge_dart_generator)

Generator for Flutter API packages.

```
stormforge_dart_generator/
├── lib/
│   ├── stormforge_dart_generator.dart    # Library entry point
│   │
│   ├── generators/                        # Code generators
│   │   ├── package_generator.dart         # Package scaffold
│   │   ├── type_generator.dart            # Dart type generation
│   │   ├── command_generator.dart         # Command class generation
│   │   ├── query_generator.dart           # Query class generation
│   │   ├── event_generator.dart           # Event class generation
│   │   └── client_generator.dart          # HTTP client generation
│   │
│   ├── templates/                         # Code templates
│   │   ├── pubspec.yaml.dart              # pubspec.yaml template
│   │   ├── types.dart.dart                # Types template
│   │   ├── commands.dart.dart             # Commands template
│   │   ├── queries.dart.dart              # Queries template
│   │   └── events.dart.dart               # Events template
│   │
│   ├── ir/                                # IR handling
│   │   ├── ir_reader.dart                 # IR file reader
│   │   └── type_mapper.dart               # IR to Dart type mapping
│   │
│   └── output/                            # Output handling
│       ├── file_writer.dart
│       └── formatter.dart                 # dart format integration
│
├── test/
│   └── generators/
│
└── pubspec.yaml
```

### 4. IR Schema (ir_schema)

The Intermediate Representation format definition.

```
ir_schema/
├── schema/
│   ├── ir.schema.json               # JSON Schema for IR
│   ├── bounded_context.schema.json  # Bounded Context schema
│   ├── aggregate.schema.json        # Aggregate schema
│   ├── event.schema.json            # Event schema
│   ├── command.schema.json          # Command schema
│   └── value_object.schema.json     # Value Object schema
│
├── examples/
│   ├── ecommerce/
│   │   ├── order_context.yaml       # Order Bounded Context
│   │   ├── payment_context.yaml     # Payment Bounded Context
│   │   └── inventory_context.yaml   # Inventory Bounded Context
│   │
│   └── hr/
│       └── leave_context.yaml       # Leave Management Context
│
└── docs/
    └── ir_specification.md          # IR format specification
```

---

## 🔄 Data Flow

### Model to Code Flow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   User      │     │   Canvas    │     │   IR        │     │   Git       │
│   Modeling  │────►│   State     │────►│   YAML      │────►│   Commit    │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
                                               │
                    ┌──────────────────────────┼──────────────────────────┐
                    │                          │                          │
                    ▼                          ▼                          ▼
           ┌─────────────┐            ┌─────────────┐            ┌─────────────┐
           │   Rust      │            │   Dart      │            │   Deploy    │
           │   Generator │            │   Generator │            │   Generator │
           └──────┬──────┘            └──────┬──────┘            └──────┬──────┘
                  │                          │                          │
                  ▼                          ▼                          ▼
           ┌─────────────┐            ┌─────────────┐            ┌─────────────┐
           │   Axum      │            │   Flutter   │            │   Docker    │
           │   Service   │            │   Package   │            │   K8s       │
           └─────────────┘            └─────────────┘            └─────────────┘
```

### Event Flow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Flutter   │     │   HTTP      │     │   Rust      │     │   Kafka     │
│   App       │────►│   Request   │────►│   Service   │────►│   Topic     │
└─────────────┘     └─────────────┘     └─────────────┘     └──────┬──────┘
      ▲                                                           │
      │                                                           ▼
      │             ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
      │             │   Event     │     │   WebSocket │     │   Other     │
      └─────────────┤   Bus       │◄────┤   Bridge    │◄────┤   Services  │
                    └─────────────┘     └─────────────┘     └─────────────┘
```

---

## 📝 IR Schema Overview

### Bounded Context

```yaml
# Example: Order Bounded Context
bounded_context:
  name: Order
  namespace: acme.order
  description: Handles order lifecycle management
  
  aggregates:
    - name: Order
      root_entity: OrderEntity
      
  events:
    - name: OrderCreated
    - name: OrderPaid
    - name: OrderShipped
    
  commands:
    - name: CreateOrder
    - name: PayOrder
    - name: ShipOrder
      
  queries:
    - name: GetOrder
    - name: ListOrders
```

### Aggregate Definition

```yaml
aggregate:
  name: Order
  
  root_entity:
    name: OrderEntity
    properties:
      - name: id
        type: OrderId
        identifier: true
      - name: customerId
        type: CustomerId
      - name: items
        type: List<OrderItem>
      - name: status
        type: OrderStatus
      - name: totalAmount
        type: Money
        
  value_objects:
    - name: OrderItem
      properties:
        - name: productId
          type: ProductId
        - name: quantity
          type: int
        - name: unitPrice
          type: Money
          
    - name: Money
      properties:
        - name: amount
          type: decimal
        - name: currency
          type: string
```

---

## 🔌 Plugin Architecture

### Plugin Types

1. **Generator Plugins**: Additional code generators (Java, Go, etc.)
2. **External System Plugins**: Third-party integrations (Payment, Messaging)
3. **Infrastructure Plugins**: Database, cache, queue adapters
4. **AI Plugins**: Alternative AI model integrations

### Plugin Manifest

```yaml
plugin:
  name: stormforge-java-generator
  version: 1.0.0
  type: generator
  description: Java Spring Boot microservice generator
  
  author: StormForge Team
  license: MIT
  
  requires:
    stormforge: ">=1.0.0"
    
  provides:
    generators:
      - name: java-spring
        language: java
        framework: spring-boot
        
  configuration:
    java_version:
      type: string
      default: "17"
    spring_version:
      type: string
      default: "3.2.0"
```

---

## 🔒 Security Architecture

### Authentication & Authorization

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   User          │     │   Auth          │     │   RBAC          │
│   (Flutter App) │────►│   Service       │────►│   Engine        │
└─────────────────┘     └─────────────────┘     └─────────────────┘
                               │
                               ▼
                        ┌─────────────────┐
                        │   JWT Token     │
                        │   Generation    │
                        └─────────────────┘
```

### Data Security

- All model data encrypted at rest
- TLS for all network communication
- Git repository encryption optional
- API key management for AI services

---

## 📊 Performance Considerations

### Canvas Performance

- Impeller rendering for smooth 60fps
- Virtual canvas for large models (1000+ elements)
- Incremental rendering for updates
- Web Workers for heavy computation (WebAssembly)

### Generation Performance

- Parallel generation for multiple services
- Incremental generation for changes
- Template caching
- Async file operations

### Runtime Performance

- Generated Rust services optimized for low latency
- Connection pooling for databases
- Event batching for Kafka
- WebSocket connection management

---

## 🧪 Testing Strategy

### Unit Testing

- Canvas element rendering
- IR serialization/deserialization
- Code generation templates
- Type mapping

### Integration Testing

- Git operations
- AI service integration
- Full generation pipeline
- Plugin system

### End-to-End Testing

- Complete modeling flow
- Generated service functionality
- Cross-service communication
- Deployment pipeline

---

## 📈 Scalability

### Horizontal Scaling

```
                    ┌─────────────────┐
                    │   Load          │
                    │   Balancer      │
                    └────────┬────────┘
                             │
          ┌──────────────────┼──────────────────┐
          │                  │                  │
          ▼                  ▼                  ▼
   ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
   │   Service   │    │   Service   │    │   Service   │
   │   Instance  │    │   Instance  │    │   Instance  │
   └─────────────┘    └─────────────┘    └─────────────┘
```

### Multi-Tenant Architecture (Phase 3+)

- Tenant isolation at database level
- Per-tenant resource quotas
- Tenant-specific configurations
- Billing integration

---

## 🔗 External Integrations

### AI Services

| Provider | Use Case | Priority |
|----------|----------|----------|
| Claude 3.5 | Primary model generation | High |
| Grok 4 | Alternative option | Medium |
| 通义千问-max | China region | High |

### Version Control

- GitHub integration
- GitLab integration
- Bitbucket integration
- Self-hosted Git support

### Deployment Targets

- Kubernetes (any distribution)
- Docker Compose (development)
- Sealos (managed K8s)
- AWS EKS, GKE, AKS

---

*This architecture document will evolve as the project develops.*
