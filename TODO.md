# StormForge TODO

> Development tracking document for StormForge platform
> Last Updated: 2025-12-02

## 📋 Phase 0: Proof of Concept (2025.10.09 - 2025.10.31)

### Sprint S00: Project Initialization ✅
- [x] Initialize Git repository
- [x] Create README.md with project overview
- [x] Create TODO.md for tracking
- [x] Create development roadmap (ROADMAP.md)
- [x] Create architecture documentation (ARCHITECTURE.md)
- [x] Create contribution guidelines (CONTRIBUTING.md)
- [x] Set up .gitignore for Flutter/Rust/Dart
- [x] Define project directory structure
- [x] Set up CI/CD pipeline (GitHub Actions)
- [x] Set up code quality tools (linting, formatting)

### Sprint S01: Flutter Modeler Skeleton + IR v1.0 ✅ (2025.10.09 - 2025.10.22)
- [x] Initialize Flutter project (stormforge_modeler)
- [x] Implement basic canvas widget
- [x] Create EventStorming element types:
  - [x] Domain Events (Orange sticky notes)
  - [x] Commands (Blue sticky notes)
  - [x] Aggregates (Yellow sticky notes)
  - [x] Policies (Purple sticky notes)
  - [x] Read Models (Green sticky notes)
  - [x] External Systems (Pink sticky notes)
  - [x] UI (White sticky notes)
- [x] Implement drag & drop functionality
- [x] Implement zoom & pan
- [x] Define IR v1.0 YAML schema (JSON Schema)
- [x] Implement YAML export/import
- [x] Real-time YAML sync on canvas changes

### Sprint S02: Multi-domain Canvas + Git Storage (2025.10.23 - 2025.11.05)
- [ ] Support multiple Bounded Contexts in one canvas
- [ ] Implement swimlane view for contexts
- [ ] Add context boundaries visualization
- [ ] Implement Git integration:
  - [ ] Auto-commit on model save
  - [ ] Version history viewer
  - [ ] Branch management
- [ ] Model diff visualization
- [ ] Support 20+ Bounded Contexts per project

---

## 📋 Phase 1: Rust + Flutter API Package MVP (2025.11 - 2026.04)

### Sprint S03: Rust Single Microservice Generator (2025.11.06 - 2025.11.19)
- [ ] Initialize Rust generator project (stormforge_generator)
- [ ] IR parser implementation
- [ ] Axum project scaffold generator
- [ ] Domain entity code generation
- [ ] Command handlers generation
- [ ] Event sourcing infrastructure
- [ ] Repository pattern implementation
- [ ] Basic API endpoints generation
- [ ] utoipa/Swagger documentation
- [ ] cargo run verification

### Sprint S04: Flutter API Package Generator v0.9 (2025.11.20 - 2025.12.03)
- [ ] Initialize Dart generator project (stormforge_dart_generator)
- [ ] Dart type generation from IR
- [ ] Command classes generation
- [ ] Query classes generation
- [ ] HTTP client wrapper
- [ ] Error handling types
- [ ] event_bus integration
- [ ] WebSocket client for events
- [ ] Generated package pubspec.yaml
- [ ] Package documentation generation

### Sprint S05: Multi-microservice + Independent Dart Packages (2025.12.04 - 2025.12.17)
- [ ] Multi-service generation from single canvas
- [ ] Independent package per Bounded Context
- [ ] Service dependency resolution
- [ ] Shared types handling
- [ ] Cross-service event contracts
- [ ] Generate 4 microservices in one click
- [ ] Generate 4 independent dart packages

### Sprint S06: AI Model Generation (2025.12.18 - 2025.12.31)
- [ ] AI service integration layer
- [ ] Claude 3.5 API integration
- [ ] Natural language to IR conversion
- [ ] Model validation and suggestions
- [ ] Iterative refinement support
- [ ] 90% accuracy on domain modeling

### Sprint S07: Cross-domain Events + Kafka Bridge (2026.01.01 - 2026.01.14)
- [ ] Kafka producer generation
- [ ] Kafka consumer generation
- [ ] Event schema registry
- [ ] Dart WebSocket bridge
- [ ] Real-time event propagation
- [ ] OrderPaid → Inventory deduction demo

### Sprint S08: External System Plugins (2026.01.15 - 2026.01.28)
- [ ] Plugin architecture design
- [ ] Plugin manifest format
- [ ] Payment plugins:
  - [ ] Alipay integration
  - [ ] WeChat Pay integration
- [ ] Messaging plugins:
  - [ ] WeChat Work notification
  - [ ] DingTalk notification
- [ ] Plugin marketplace foundation

### Sprint S09: One-click Deploy + Private Pub (2026.02.01 - 2026.02.14)
- [ ] Docker image generation
- [ ] Kubernetes manifests generation
- [ ] Helm chart generation
- [ ] Private pub server integration
- [ ] Auto-publish Dart packages
- [ ] GitOps workflow setup

### Sprint S10: Complete E-commerce Case (2026.02.15 - 2026.02.28)
- [ ] Order service (Rust + Dart)
- [ ] Payment service (Rust + Dart)
- [ ] Inventory service (Rust + Dart)
- [ ] Notification service (Rust + Dart)
- [ ] Full integration test
- [ ] End-to-end demo application

### Sprint S11-S13: Hardening + Beta Testing (2026.03 - 2026.04)
- [ ] Test coverage > 93%
- [ ] Performance optimization
- [ ] Security audit
- [ ] Documentation completion
- [ ] Video tutorials
- [ ] 500 beta user invitations
- [ ] Feedback collection system

---

## 📋 Phase 2: Multi-microservice + Plugin Ecosystem (2026.05 - 2026.10)

### Key Deliverables
- [ ] Plugin marketplace launch
- [ ] 5 official backend generators (Rust/Java/Nest/Go/Kotlin)
- [ ] 60+ external system plugins
- [ ] Infrastructure adapter full coverage
- [ ] Cross-domain event auto-bridging
- [ ] 10-second backend language switching

---

## 📋 Phase 3: Enterprise + Incremental + Reverse (2026.11 - 2027.04)

### Key Deliverables
- [ ] Incremental generation + change impact analysis
- [ ] Reverse modeling (existing code → Flutter canvas)
- [ ] Multi-tenant support
- [ ] Large-scale support (1000+ aggregates)
- [ ] AI automatic code review

---

## 📋 Phase 4: Platform + Open Source + Commercialization (2027.05 - 2027.12)

### Key Deliverables
- [ ] Core fully open source (MIT)
- [ ] Commercial version (private deployment + local AI + SLA)
- [ ] Flutter iPad professional modeling version
- [ ] Real-time collaborative modeling
- [ ] Monthly active teams > 10,000
- [ ] Plugin marketplace > 1,000 plugins

---

## 🔧 Technical Debt & Improvements

### Infrastructure
- [ ] Set up monitoring (Prometheus + Grafana)
- [ ] Set up logging (ELK stack)
- [ ] Set up tracing (Jaeger)
- [ ] Performance benchmarking suite

### Documentation
- [ ] API documentation
- [ ] Plugin development guide
- [ ] Deployment guide
- [ ] Troubleshooting guide

### Testing
- [ ] Unit test framework
- [ ] Integration test framework
- [ ] E2E test framework
- [ ] Performance test suite

---

## 📊 Progress Summary

| Phase | Progress | Status |
|-------|----------|--------|
| Phase 0: POC | 50% | 🚧 In Progress |
| Phase 1: MVP | 0% | ⏳ Planned |
| Phase 2: Ecosystem | 0% | ⏳ Planned |
| Phase 3: Enterprise | 0% | ⏳ Planned |
| Phase 4: Platform | 0% | ⏳ Planned |

---

## 📝 Notes

### Key Decisions
1. **Flutter-first approach**: All modeling done in Flutter for true cross-platform support
2. **Rust for backend**: Performance and safety for generated microservices
3. **YAML as IR**: Human-readable, version-controllable model format
4. **No UI generation**: Focus on pure, strongly-typed API packages

### Risks & Mitigations
1. **AI accuracy**: Start with simpler models, iterative improvement
2. **Cross-platform compatibility**: Extensive testing on all platforms
3. **Plugin ecosystem**: Start with official plugins, community later

---

*This TODO document is actively maintained. Check ROADMAP.md for detailed sprint planning.*
