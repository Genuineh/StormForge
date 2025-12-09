# StormForge TODO

> StormForge平台开发追踪文档
> 
> Last Updated: 2025-12-09
> 
> **重要说明**: 本文档已根据Modeler 2.0升级计划重新组织。Phase 1的代码生成器开发(Sprint S05-S13)将与Modeler 2.0升级(Sprint M1-M9)并行进行。
> 
> **文档归档**: 已完成的Sprint报告已归档至 [docs/sprints/](docs/sprints/README.md) 目录。

---

## 📋 Phase 0: Proof of Concept ✅ (2025.10.09 - 2025.10.31)

**目标**: 30分钟完成端到端流程：文本 → Flutter画布 → 1个Rust微服务 + 1个Flutter API包

**状态**: 已完成

包含Sprint S00 (项目初始化), S01 (Flutter建模器骨架 + IR v1.0), S02 (多域画布 + Git存储)

<details>
<summary>查看详细任务列表</summary>

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
- [x] Create EventStorming element types
- [x] Implement drag & drop functionality
- [x] Implement zoom & pan
- [x] Define IR v1.0 YAML schema (JSON Schema)
- [x] Implement YAML export/import
- [x] Real-time YAML sync on canvas changes

### Sprint S02: Multi-domain Canvas + Git Storage ✅ (2025.10.23 - 2025.11.05)
- [x] Support multiple Bounded Contexts in one canvas
- [x] Implement swimlane view for contexts
- [x] Add context boundaries visualization
- [x] Implement Git integration
- [x] Model diff visualization
- [x] Support 20+ Bounded Contexts per project

</details>

---

## 📋 Phase 1: Rust + Flutter API Package MVP (2025.11 - 2026.04)

**目标**: 
1. Flutter跨平台建模器 v1.0
2. IR v1.0标准
3. Rust多微服务生成器
4. 自动生成Flutter API包 (types + requests + event_bus)
5. AI一键模型生成
6. 一键Git + 一键部署

**并行开发**: 生成器开发 (Sprint S05-S13) 与 Modeler 2.0升级 (Sprint M1-M9) 并行进行

### Sprint S03: Rust Single Microservice Generator ✅ (2025.11.06 - 2025.11.19)

**完成报告**: [docs/sprint_s03_completion.md](docs/sprint_s03_completion.md)

<details>
<summary>查看详细任务列表</summary>

- [x] Initialize Rust generator project (stormforge_generator)
- [x] IR parser implementation
- [x] Axum project scaffold generator
- [x] Domain entity code generation
- [x] Command handlers generation
- [x] Event sourcing infrastructure
- [x] Repository pattern implementation
- [x] Basic API endpoints generation
- [x] utoipa/Swagger documentation
- [x] cargo run verification

</details>

### Sprint S04: Flutter API Package Generator v0.9 🚧 (2025.11.20 - 2025.12.03)
- [x] Initialize Dart generator project (stormforge_dart_generator)
- [x] Dart type generation from IR
- [x] Command classes generation
- [x] Query classes generation
- [ ] HTTP client wrapper
- [ ] Error handling types
- [ ] event_bus integration
- [ ] WebSocket client for events
- [ ] Generated package pubspec.yaml
- [ ] Package documentation generation

### Sprint S04.5: Modeler 2.0 Upgrade Planning ✅ (2025.12.03)
- [x] Analyze upgrade requirements (based on user feedback)
- [x] Design comprehensive improvement plan
- [x] Create MODELER_UPGRADE_PLAN.md document (24KB)
- [x] Design project management system
- [x] Design component connectivity system (8 connection types)
- [x] Design entity modeling system (dedicated editor)
- [x] Design read model field selection
- [x] Design command data model management
- [x] Plan enterprise global library (3-tier hierarchy)
- [x] Create detailed design documents (103KB total)
- [x] Update TODO.md with integrated roadmap

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

## 📋 Modeler 2.0 Upgrade (2025.12.04 - 2026.04.22)

**升级目标**: 将Modeler从基础EventStorming画布升级为完整的企业级建模和项目管理平台

**核心特性**:
1. **项目管理**: 完整项目生命周期，用户管理，权限控制，团队协作
2. **组件连接**: 可视化连接系统，8种连接类型 (Command→Aggregate, Aggregate→Event等)
3. **实体建模**: 独立实体编辑器，聚合引用完整定义的实体对象（属性、方法、不变量）
4. **读模型设计器**: 从实体选择字段的可视化工具，支持多实体联接和转换
5. **命令数据模型**: 命令的正确数据模型管理，字段源追踪（来自读模型、实体或自定义DTO）
6. **企业全局库**: 三层库系统 (Enterprise/Organization/Project)，可重用组件，版本管理

**设计文档**:
- 总体规划: [docs/MODELER_UPGRADE_PLAN.md](docs/MODELER_UPGRADE_PLAN.md) (24KB)
- 快速参考: [docs/MODELER_UPGRADE_SUMMARY.md](docs/MODELER_UPGRADE_SUMMARY.md) (6KB)
- 详细设计: [docs/designs/](docs/designs/) (73KB)
  - [entity_modeling_system.md](docs/designs/entity_modeling_system.md) - 实体建模系统
  - [connection_system.md](docs/designs/connection_system.md) - 组件连接系统
  - [read_model_designer.md](docs/designs/read_model_designer.md) - 读模型设计器
  - [global_library.md](docs/designs/global_library.md) - 企业全局库

**Sprint归档**: 已完成的Sprint M1-M8报告已归档至 [docs/sprints/](docs/sprints/README.md)

**并行开发**: 此升级与生成器开发 (Sprint S05-S13) 并行进行，互不影响

### Sprint M1-M8: 核心功能实现 ✅ (2025.12.04 - 2026.04.08)

**已完成的核心功能**:
1. ✅ **Sprint M1**: 项目管理基础 (用户系统、权限管理、项目持久化)
2. ✅ **Sprint M2**: 组件连接系统 (8种连接类型、可视化连接、流程追溯)
3. ✅ **Sprint M3**: 实体建模系统 (实体编辑器、属性/方法管理、不变量系统)
4. ✅ **Sprint M4**: 读模型设计器 (字段选择、多实体联接、字段转换)
5. ✅ **Sprint M5**: 命令数据模型设计器 (命令负载设计、数据源映射)
6. ✅ **Sprint M6**: 企业全局库 (三层库架构、组件版本管理、标准库)
7. ✅ **Sprint M7**: 增强画布集成 (画布-模型双向同步、多面板布局)
8. ✅ **Sprint M8**: IR Schema v2.0 (新IR格式、v1.0到v2.0迁移工具)

<details>
<summary>查看详细功能列表</summary>

### Sprint M1: 项目管理基础 ✅ (2025.12.04 - 2025.12.17)
**完成报告**: [docs/sprints/completed/SPRINT_M1_SUMMARY.md](docs/sprints/completed/SPRINT_M1_SUMMARY.md)

- [x] 数据模型设计与实现 (Project, User, TeamMember)
- [x] 数据库架构设计 (MongoDB + SQLite)
- [x] 权限系统设计 (12种权限, 3种全局角色, 4种团队角色)
- [x] 后端系统实现 (stormforge_backend)
- [x] 数据持久化层实现 (SQLite本地 + MongoDB云端)
- [x] 用户认证服务实现 (JWT)
- [x] REST API完整实现
- [x] 用户管理界面 (登录、注册界面)
- [x] 团队成员管理界面
- [x] 项目设置界面
- [x] Git集成增强

### Sprint M2: 组件连接系统 ✅ (2025.12.18 - 2025.12.31)
**完成报告**: [docs/sprints/completed/SPRINT_M2_SUMMARY.md](docs/sprints/completed/SPRINT_M2_SUMMARY.md)

- [x] 连接数据模型
- [x] 8种连接类型定义
- [x] 画布连接绘制
- [x] 连接验证逻辑
- [x] 连接属性面板
- [x] 自动路由算法
- [x] 连接模式工具栏
- [x] 连接编辑/删除
- [x] 连接样式系统
- [x] 后台系统流水线 (CI/CD)

### Sprint M3: 实体建模系统 ✅ (2026.01.01 - 2026.01.21)
**完成报告**: [docs/sprints/completed/SPRINT_M3_COMPLETION_REPORT.md](docs/sprints/completed/SPRINT_M3_COMPLETION_REPORT.md)

- [x] 实体定义数据模型
- [x] 实体属性模型（含验证）
- [x] 实体方法模型
- [x] 实体不变量系统
- [x] 后端API实现（Rust）
- [x] 前端数据模型（Flutter）
- [x] MongoDB集合和索引
- [x] REST API端点
- [x] 实体编辑器UI
- [x] 属性网格编辑器
- [x] 类型选择器
- [x] 验证规则构建器
- [x] 方法/行为编辑器
- [x] 实体-聚合关联
- [x] 实体关系图
- [x] 实体导入/导出

### Sprint M4: 读模型设计器 ✅ (2026.01.22 - 2026.02.04)
**完成报告**: [docs/sprints/completed/SPRINT_M4_COMPLETION_REPORT.md](docs/sprints/completed/SPRINT_M4_COMPLETION_REPORT.md)

- [x] 读模型定义模型
- [x] 字段源追踪
- [x] 数据源模型（多实体）
- [x] 联接条件构建器
- [x] 字段选择UI
- [x] 实体树浏览器
- [x] 拖放字段选择
- [x] 字段转换表达式
- [x] 字段重命名界面
- [x] 计算字段支持
- [x] 实时预览生成
- [x] 读模型验证

### Sprint M5: 命令数据模型设计器 ✅ (2026.02.05 - 2026.02.18)
**完成报告**: [docs/sprints/completed/SPRINT_M5_COMPLETION_REPORT.md](docs/sprints/completed/SPRINT_M5_COMPLETION_REPORT.md)

- [x] 命令定义模型
- [x] 命令负载模型
- [x] 命令字段源
- [x] 命令设计器UI
- [x] 负载字段编辑器
- [x] 数据源映射界面
- [x] 字段验证规则
- [x] 前置条件构建器
- [x] 事件关联系统
- [x] 命令-聚合关联
- [x] 从读模型映射命令
- [x] 自定义DTO支持

### Sprint M6: 企业全局库 ✅ (2026.02.19 - 2026.03.11)
**完成报告**: [docs/sprints/completed/SPRINT_M6_COMPLETION_REPORT.md](docs/sprints/completed/SPRINT_M6_COMPLETION_REPORT.md)

- [x] 库组件数据模型
- [x] 库范围层次结构 (Enterprise/Org/Project)
- [x] 组件版本系统
- [x] 库存储后端
- [x] 前端数据模型和服务
- [x] 库浏览器UI
- [x] 组件搜索和过滤
- [x] 组件详情视图
- [x] 组件发布工作流
- [x] 导入到项目
- [x] 引用vs复制模式
- [x] 使用跟踪和统计
- [x] 依赖管理
- [x] 影响分析工具
- [x] 库组件模板
- [x] 标准库组件 (Money, Address, Email等)

### Sprint M7: 增强画布集成 ✅ (2026.03.12 - 2026.03.25)
**完成报告**: [docs/sprints/completed/SPRINT_M7_COMPLETION_REPORT.md](docs/sprints/completed/SPRINT_M7_COMPLETION_REPORT.md)

- [x] 更新元素模型（添加引用）
- [x] 聚合-实体同步
- [x] 读模型-定义关联
- [x] 命令-定义关联
- [x] 画布-模型双向同步
- [x] 增强属性面板
- [x] 右键菜单改进
- [x] 多面板布局
- [x] 项目导航树
- [x] 快捷键和快速操作
- [x] 元素模板系统
- [x] 批量操作支持

### Sprint M8: IR Schema v2.0 ✅ (2026.03.26 - 2026.04.08)
**完成报告**: [docs/sprints/completed/SPRINT_M8_COMPLETION_REPORT.md](docs/sprints/completed/SPRINT_M8_COMPLETION_REPORT.md)

- [x] 设计IR v2.0 schema
- [x] 添加实体定义到IR
- [x] 添加读模型定义到IR
- [x] 添加命令数据模型到IR
- [x] 添加库引用到IR
- [x] 添加画布元数据（连接）到IR
- [x] 实现v2.0序列化
- [x] 实现v2.0反序列化
- [x] v1.0到v2.0迁移工具
- [x] 更新IR验证
- [x] 更新JSON Schema文件
- [x] 更新生成器支持v2.0

</details>

### Sprint M9: 测试、完善与文档 🚧 (2026.04.09 - 2026.04.22)
**核心**: 质量保证、性能优化
**Status**: 60% Complete (Documentation Complete, Testing and Implementation in Progress)
**进度文档**: [docs/sprints/in_progress/](docs/sprints/in_progress/)

- [x] 单元测试（已完成基础覆盖）
  - [x] 后端模型测试（49个测试通过）
  - [x] 前端测试（已存在）
- [x] 用户指南文档
- [x] 管理员指南文档
- [x] API文档
- [x] 测试指南文档
- [x] 迁移指南 (v1.0→v2.0)
- [ ] 集成测试
- [ ] UI/UX测试和改进
- [ ] 性能优化（1000+元素@60fps）
- [ ] 自动保存功能（30秒间隔）
- [ ] 错误处理和恢复
- [ ] 视频教程
- [ ] Beta测试（50+用户）
- [ ] Bug修复和完善

---

## 📋 Phase 2: Multi-microservice + Plugin Ecosystem (2026.05 - 2026.10)

**目标**:
1. 插件市场正式上线
2. 5个官方后端生成器 (Rust/Java/Nest/Go/Kotlin)
3. 60+外部系统插件
4. 基础设施适配器全覆盖
5. 跨域事件自动桥接

### Key Deliverables
- [ ] Plugin marketplace launch
- [ ] 5 official backend generators (Rust/Java/Nest/Go/Kotlin)
- [ ] 60+ external system plugins
- [ ] Infrastructure adapter full coverage
- [ ] Cross-domain event auto-bridging
- [ ] 10-second backend language switching

---

## 📋 Phase 3: Enterprise + Incremental + Reverse (2026.11 - 2027.04)

**目标**:
1. 增量生成 + 变更影响分析
2. 逆向建模 (现有代码 → Flutter画布)
3. 多租户支持
4. 大规模支持 (1000+ aggregates)
5. AI自动代码审查

### Key Deliverables
- [ ] Incremental generation + change impact analysis
- [ ] Reverse modeling (existing code → Flutter canvas)
- [ ] Multi-tenant support
- [ ] Large-scale support (1000+ aggregates)
- [ ] AI automatic code review

---

## 📋 Phase 4: Platform + Open Source + Commercialization (2027.05 - 2027.12)

**目标**:
1. 核心完全开源 (MIT)
2. 商业版 (私有部署 + 本地AI + SLA)
3. Flutter iPad专业建模版
4. 实时协作建模

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

| Phase | Sprint | Progress | Status |
|-------|--------|----------|--------|
| Phase 0: POC | S00-S02 | 100% | ✅ Completed |
| Phase 1: MVP | S03 | 100% | ✅ Completed |
| Phase 1: MVP | S04 | 90% | 🚧 In Progress |
| Phase 1: MVP | S05-S13 | 0% | ⏳ Planned |
| Modeler 2.0 | M1-M8 | 100% | ✅ Completed ([查看归档](docs/sprints/README.md)) |
| Modeler 2.0 | M9 | 60% | 🚧 In Progress (Documentation Complete) |
| Phase 2: Ecosystem | - | 0% | ⏳ Planned |
| Phase 3: Enterprise | - | 0% | ⏳ Planned |
| Phase 4: Platform | - | 0% | ⏳ Planned |

**总体进度**: Phase 0完成, Phase 1进行中(25%), Modeler 2.0进行中(96%)

---

## 📝 Notes

### Modeler 2.0 Upgrade (2025-12-03)

Modeler正在升级为完整的企业级建模和项目管理平台，新增6大核心功能：

1. **项目管理系统** - 完整项目生命周期，用户管理，权限控制，团队协作
2. **组件连接系统** - 可视化连接，8种连接类型，让EventStorming组件之间的关系显式化
3. **实体建模系统** - 独立实体编辑器，聚合引用结构化的实体定义（属性、方法、不变量）
4. **读模型设计器** - 从实体选择字段的可视化工具，支持多实体联接和字段转换
5. **命令数据模型** - 命令负载的正确数据模型管理，字段源追踪（UI输入、读模型、实体）
6. **企业全局库** - 三层库系统，组件版本管理，使用跟踪，影响分析

**设计文档**: 查看 [docs/MODELER_UPGRADE_PLAN.md](docs/MODELER_UPGRADE_PLAN.md) 了解完整设计

**并行开发**: 此升级与Phase 1生成器开发并行进行，计划于2026年Q2完成

### Key Architectural Decisions

1. **Flutter-first approach**: 所有建模工作在Flutter中完成，真正的跨平台支持
2. **Rust for backend**: 生成的微服务使用Rust，性能和安全性
3. **YAML as IR**: 人类可读，版本可控的模型格式
4. **No UI generation**: 专注于纯粹的、强类型的API包，不生成UI
5. **Separation of Concerns**: 画布(可视化) ↔ 实体编辑器(详细定义) ↔ 全局库(可重用组件)

### Development Timeline Adjustment

由于Modeler 2.0升级计划的加入，原Phase 1的部分Sprint时间略有调整：

- **S03-S04**: 已完成，为Modeler 2.0升级做准备
- **S05-S13**: 继续按原计划进行，与M1-M9并行开发
- **M1-M9**: 新增的Modeler 2.0升级Sprint，18周完成（2025.12.04 - 2026.04.22）
- **集成时间点**: 
  - M8 (2026.03.26-04.08): 统一更新IR Schema v2.0，两个团队协调
  - M9 + S11-S13 (2026.04.09-04.30): 综合集成测试，包含新功能

这种并行开发方式允许：
- 生成器团队继续推进代码生成功能（S05-S13）
- Modeler团队同时升级建模平台（M1-M9）
- Modeler团队同时升级建模平台
- 在M8中统一更新IR Schema v2.0
- 在M9和S11-S13中进行综合测试

### Risks & Mitigations

1. **并行开发协调**: 
   - 风险：两个团队可能在IR格式上产生冲突
   - 缓解：在M8统一更新IR v2.0，之前各自使用IR v1.0

2. **AI accuracy**: 
   - 风险：AI生成模型准确率不足
   - 缓解：从简单模型开始，迭代改进

3. **Cross-platform compatibility**: 
   - 风险：跨平台兼容性问题
   - 缓解：在所有平台上进行广泛测试

4. **Plugin ecosystem**: 
   - 风险：插件生态发展缓慢
   - 缓解：先做官方插件，再开放社区

5. **Performance at scale**:
   - 风险：1000+元素时性能下降
   - 缓解：虚拟画布、增量渲染、性能监控

---

## 📚 文档导航

- **Sprint归档**: [docs/sprints/](docs/sprints/README.md) - 查看所有已完成的Sprint报告
- **设计文档**: [docs/designs/](docs/designs/) - 详细设计文档
- **用户指南**: [docs/guides/](docs/guides/) - 用户和开发者指南
- **项目路线图**: [docs/ROADMAP.md](docs/ROADMAP.md) - 详细的Sprint规划
- **架构文档**: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) - 系统架构设计

---

*此TODO文档持续维护中。Last Updated: 2025-12-09*
