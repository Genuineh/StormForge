# StormForge TODO

> StormForge平台开发追踪文档
> 
> Last Updated: 2025-12-12
> 
> **重要说明**: 本文档反映实际实施进度。所有进度百分比基于**实际代码实现**，而非设计文档完成度。
> 
> **项目状态**: 
> - Phase 0 (POC): ✅ 已完成 - 基础建模器和生成器原型可工作
> - Phase 1 (MVP): 🚧 约45%完成 - 后端API完整，前端UI完整，集成进行中
> - Modeler 2.0: ✅ 设计完成，实现约65%完成 - UI和API已完整实现，集成待加强

---

## 📋 Phase 0: Foundation & POC ✅ (2025.10 - 2025.11)

**目标**: 建立项目基础，完成核心概念验证

### 已完成工作

**Sprint S00: 项目初始化** ✅
- [x] Git仓库初始化
- [x] 项目文档框架 (README, TODO, ROADMAP, ARCHITECTURE, CONTRIBUTING)
- [x] 项目目录结构定义
- [x] 基础CI/CD配置

**Sprint S01-S02: 建模器原型** ✅
- [x] Flutter建模器项目初始化 (stormforge_modeler)
- [x] 基础EventStorming画布实现
- [x] EventStorming元素类型定义
- [x] 基础交互功能 (拖放、缩放、平移)
- [x] IR v1.0 YAML schema定义
- [x] YAML导入导出功能
- [x] 多领域上下文支持
- [x] Git集成基础

**Sprint S03: Rust生成器原型** ✅
- [x] Rust生成器项目初始化 (stormforge_generator)
- [x] IR解析器实现
- [x] Axum项目脚手架生成
- [x] 基础领域实体代码生成
- [x] 命令处理器生成
- [x] 事件溯源基础设施
- [x] Repository模式实现
- [x] 基础API端点生成
- [x] utoipa/Swagger文档生成

---

## 📋 Phase 1: MVP 开发 🚧 (2025.11 - 2026.Q2)

**目标**: 
1. 完善Rust微服务生成器
2. 实现Flutter API包生成器
3. 增强建模器功能 (Modeler 2.0特性)
4. 建立后台系统支持项目管理

**当前状态**: 🚧 进行中 (~45%完成)

### 当前进展

**Sprint S04: Flutter API包生成器** 📋 (规划阶段)
- [x] Dart生成器项目规划 (stormforge_dart_generator)
- [ ] 项目结构搭建
- [ ] 从IR生成Dart类型
- [ ] Command类生成
- [ ] Query类生成
- [ ] HTTP客户端封装
- [ ] 错误处理类型
- [ ] event_bus集成
- [ ] WebSocket客户端（用于事件）
- [ ] 生成的包pubspec.yaml
- [ ] 包文档生成

**说明**: 目前只有README文档，无实际代码实现

**Modeler 2.0 架构与后台系统** 🚧 (早期开发阶段)

*基础框架已搭建*:
- [x] 后台系统项目 (stormforge_backend) - Rust/Axum
- [x] 数据模型定义 (User, Project, TeamMember, Entity, Connection, ReadModel, Command, Library)
- [x] 双数据库架构设计 (SQLite本地 + MongoDB云端)
- [x] JWT认证系统基础
- [x] 基础REST API框架
- [x] 权限系统设计 (3种全局角色, 4种团队角色, 12种权限)

*详细设计文档已完成* (位于 `docs/sprints/planning/`):
- [x] 项目管理系统设计 (Sprint M1)
- [x] 组件连接系统设计 (Sprint M2 - 8种连接类型)
- [x] 实体建模系统设计 (Sprint M3)
- [x] 读模型设计器设计 (Sprint M4)
- [x] 命令数据模型设计 (Sprint M5)
- [x] 企业全局库设计 (Sprint M6 - 三层架构)
- [x] 画布集成设计 (Sprint M7)
- [x] IR Schema v2.0设计 (Sprint M8)

*核心功能待实现* (实际代码实现):
- [x] ✅ 完整的前端UI实现 (导航抽屉、工作区布局、所有管理界面)
  - 项目管理UI (列表/网格/仪表板视图，搜索，统计)
  - 实体管理UI (网格视图，类型过滤，详情面板，编辑器)
  - 命令设计器UI (管理界面，字段编辑器，验证规则)
  - 读模型设计器UI (管理界面，字段映射，源实体跟踪)
  - 全局库UI (多级过滤，组件浏览器，发布工作流)
  - 连接可视化UI (8种连接类型，类型过滤)
  - 团队管理UI (成员列表，角色管理)
  - 认证UI (登录/注册)
  - 设置UI (项目设置)
- [x] ✅ 所有后台API端点完整实现 (JWT认证，69个handler函数，完整CRUD操作)
  - 用户管理API (注册、登录、获取、列表、更新)
  - 项目管理API (创建、读取、更新、删除、按所有者列表)
  - 团队成员API (添加、列表、更新、移除)
  - 实体管理API (完整CRUD + 属性/方法/不变量管理)
  - 连接管理API (完整CRUD + 按元素查询)
  - 读模型API (完整CRUD + 字段/源管理)
  - 命令API (完整CRUD + 字段/验证/前置条件管理)
  - 全局库API (发布、搜索、版本、引用、影响分析)
- [ ] 前后端API集成 (约40%完成)
  - [x] API client和service层定义
  - [x] 数据模型序列化/反序列化
  - [ ] 所有UI组件连接到实际API
  - [ ] 错误处理和加载状态
  - [ ] 数据缓存和状态管理
- [ ] IR v2.0解析器实现
- [ ] IR v1到v2迁移工具实现
- [ ] 测试覆盖率提升 (目标>60%)

**实际实施状态**:
- 后台: 37个Rust文件，完整实现：
  - JWT认证系统 (token生成/验证，密码哈希)
  - 认证中间件 (FromRequestParts提取器)
  - 69个API handler函数，覆盖所有核心功能
  - 双数据库支持 (MongoDB + SQLite)
  - 完整CRUD操作：用户、项目、团队成员、实体、连接、读模型、命令、全局库
  - OpenAPI/Swagger文档自动生成
- 前端: 80个Dart文件，完整UI实现：
  - **核心导航**: 统一导航抽屉、可重用工作区布局
  - **项目管理**: 列表/网格/仪表板视图，搜索，统计卡片
  - **实体管理**: 网格视图，类型过滤(聚合根/实体/值对象)，详情面板，属性/方法编辑器
  - **命令设计器**: 管理界面，字段编辑器，必填项指示，验证规则
  - **读模型设计器**: 管理界面，字段映射，源实体跟踪
  - **全局库**: 多级过滤(范围/类型/状态)，组件网格，详情面板，发布工作流
  - **连接可视化**: 8种连接类型的可视化卡片和过滤
  - **团队管理**: 成员列表，角色管理
  - **认证**: 登录/注册界面
  - **设置**: 项目设置界面
- 集成度: ~40% (后端API完整，前端UI完整，但API调用集成待完成)

**说明**: Sprint M1-M9的"完成报告"实际上是设计文档，已移至 `docs/sprints/planning/`。这些文档描述了预期的功能和架构，但大部分功能尚未实现。

**设计文档** (已完成 - 位于 `docs/sprints/planning/` 和 `docs/designs/`):
- [docs/sprints/planning/README.md](docs/sprints/planning/README.md) - Sprint M1-M9设计文档索引
- [docs/designs/entity_modeling_system.md](docs/designs/entity_modeling_system.md)
- [docs/designs/connection_system.md](docs/designs/connection_system.md)
- [docs/designs/read_model_designer.md](docs/designs/read_model_designer.md)
- [docs/designs/global_library.md](docs/designs/global_library.md)

### 下一步计划 (Near-term Roadmap)

**当前Sprint (2025.12)**:
1. ✅ 完成Modeler 2.0前端UI框架 (2025-12-11)
   - 统一导航系统和工作区布局
   - 项目管理UI (列表/网格/仪表板)
   - 实体、命令、读模型管理界面
   - 全局库浏览器
   - 连接可视化基础
2. ✅ 完成后端API实现 (2025-12-11)
   - JWT认证和权限系统
   - 所有核心模块的CRUD操作
   - OpenAPI文档生成
3. 🚧 前后端集成 (进行中 - 约40%)
   - API client层已定义
   - 需要连接所有UI到实际API
   - 需要完善错误处理和加载状态
4. 📋 开始实现Sprint S04 (Flutter API包生成器)
   - 创建基础项目结构
   - 实现类型生成器
   - 实现Command和Query生成

**2026.Q1 规划**:
1. 完成前后端API集成 (目标100%)
2. 完成Dart API包生成器MVP
3. 端到端演示案例（一个完整的bounded context）
4. 提升测试覆盖率 (目标>60%)
5. 画布与实体/命令设计器的双向集成

**2026.Q2+ 规划**:
1. 多微服务生成支持
2. IR v2.0完整实现和迁移工具
3. AI模型生成集成
4. 跨域事件和消息队列支持
5. 一键部署功能

---

## 📋 Phase 2-4: 未来规划 (2026.Q3+)

**说明**: Phase 2-4的详细规划将根据Phase 1的实际进展和用户反馈动态调整。

### Phase 2: 生态系统扩展 (预计2026.Q3-Q4)
- 插件市场
- 多语言后端生成器 (Java/Nest/Go/Kotlin等)
- 外部系统集成插件
- 跨域事件自动桥接

### Phase 3: 企业级特性 (预计2027.Q1-Q2)
- 增量生成和变更影响分析
- 逆向建模能力
- 多租户支持
- 大规模项目支持

### Phase 4: 平台化和商业化 (预计2027.Q3-Q4)
- 核心开源
- 商业版功能
- iPad专业版
- 实时协作建模

---

## 🔧 当前技术债务和改进点

### 高优先级
- [x] ✅ 完整的前端UI实现 (2025-12-11)
- [x] ✅ 完整的后端API实现 (2025-12-11)
- [ ] 前后端API完整集成 (进行中 40%)
- [ ] 错误处理和用户反馈机制优化
- [ ] 完善单元测试覆盖率 (目标: >60%)
- [ ] 集成测试框架搭建
- [ ] 性能基准测试

### 中优先级
- [ ] API文档完善
- [ ] 部署指南
- [ ] 代码质量工具配置 (linting, formatting)
- [ ] CI/CD流水线优化
- [ ] 日志和监控基础设施

### 低优先级
- [ ] 插件开发指南
- [ ] 故障排除指南
- [ ] E2E测试套件
- [ ] 性能分析和优化

---

## 📊 Progress Summary

| Phase | Component | Progress | Status |
|-------|-----------|----------|--------|
| Phase 0 | POC (S00-S03) | 100% | ✅ 已完成 |
| Phase 1 | Rust生成器 (S03) | 60% | ✅ 基础完成 |
| Phase 1 | Dart生成器 (S04) | 0% | 📋 规划中 |
| Phase 1 | Modeler 2.0后台 | 85% | ✅ API完整实现 |
| Phase 1 | Modeler 2.0前端 | 70% | ✅ UI完整实现 |
| Phase 1 | 前后端集成 | 40% | 🚧 进行中 |
| Phase 1 | 设计文档 | 100% | ✅ 已完成 |
| Phase 2-4 | 未来规划 | 0% | 📋 已规划 |

**整体进度**: 
- Phase 0 (POC): ✅ 100% 完成
- Phase 1 (MVP): 🚧 约45% 完成 (UI完整，后端API完整，集成40%完成)
- Modeler 2.0: 📋 设计100%完成，实现约65%完成 (UI完整，后端API完整，集成待加强)

**实际代码状态**:
- stormforge_modeler: 80个Dart文件
  - 28个screen文件 (17个主屏幕 + 11个widget子组件)
  - 完整UI实现：项目、实体、命令、读模型、库、连接、团队、认证、设置
  - 导航系统和工作区布局完整
- stormforge_backend: 37个Rust文件
  - 69个API handler函数
  - JWT认证和权限系统完整
  - 所有核心模块的CRUD操作完整
- stormforge_generator: 7个Rust生成器文件 (基础生成器可用)
- stormforge_dart_generator: 仅README，0%实现
- 测试覆盖率: 较低 (<20%)

---

## 📝 重要说明

### 关于Sprint M1-M9的说明

**Sprint M1-M9文档现已移至 `docs/sprints/planning/` 目录**

这些文档是**设计和规划文档**，而非实际完成报告。它们详细描述了Modeler 2.0的完整架构和功能设计。

**重要**: 这些Sprint文档使用了未来日期（2026年），这是因为它们是作为规划文档创建的。**日期不代表实际完成时间**，请以文档中的功能描述和本TODO中的实际进度为准。

**当前实际状态**:
- ✅ 设计文档已完成（100%） - 详细的架构和功能规划
- ✅ 后台数据模型已定义（100%） - 完整的数据模型和服务层
- ✅ 后台API实现已完成（85%） - 69个handler函数，JWT认证保护，完整CRUD
- ✅ 前端UI框架已完成（70%） - 28个screen文件，完整的UI组件和布局
- 🚧 完整功能集成进行中（40%） - 前后端连接待完成，数据持久化测试待加强

**实施时间表**: 
- 2025.12: 启动基础实现，重点是项目管理和实体编辑
- 2026.Q1: 核心UI功能实现
- 2026.Q2: 完整集成和测试

详细的设计文档索引和实施状态，请查看 [docs/sprints/planning/README.md](docs/sprints/planning/README.md)。

### 进度计算标准

为保证进度透明度和一致性，本文档使用以下标准计算完成百分比：

- **设计阶段**: 需求分析 + 架构设计 + 详细设计文档 (占总工作量的20%)
- **实现阶段**: 后端API + 前端UI + 数据集成 (占总工作量的60%)
- **测试阶段**: 单元测试 + 集成测试 + 用户验收测试 (占总工作量的20%)

**进度仅基于实际代码实现**，设计文档完成不计入实现进度。

例如：
- Modeler 2.0后台15%完成 = 设计20% (不计入) + 实现9% (60%×15%) + 测试0%
- Rust生成器60%完成 = 实现36% (60%×60%) + 测试0% (基础功能可用但测试不足)

### 架构决策

1. **Flutter-first approach**: 所有建模工作在Flutter中完成，真正的跨平台支持
2. **Rust for backend**: 生成的微服务使用Rust，保证性能和安全性
3. **YAML as IR**: 人类可读、版本可控的中间表示格式
4. **No UI generation**: 专注于纯粹的、强类型的API包，不生成UI代码
5. **Separation of Concerns**: 画布(可视化) ↔ 实体编辑器(详细定义) ↔ 全局库(可重用组件)

### 开发方法

- **迭代开发**: 优先完成核心功能的可工作版本，再逐步完善
- **文档驱动**: 先完成详细设计，再进行实现
- **质量优先**: 保证每个功能的质量，而不是追求功能数量
- **用户反馈**: 根据实际使用反馈调整优先级和设计

---

## 📚 文档导航

- **Sprint规划**: [docs/sprints/planning/](docs/sprints/planning/README.md) - Sprint M1-M9设计和规划文档
- **Sprint归档**: [docs/sprints/](docs/sprints/README.md) - Sprint历史和实际完成工作
- **设计文档**: [docs/designs/](docs/designs/) - 详细设计文档
- **用户指南**: [docs/guides/](docs/guides/) - 用户和开发者指南
- **项目路线图**: [docs/ROADMAP.md](docs/ROADMAP.md) - 详细的Sprint规划
- **架构文档**: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) - 系统架构设计

---

*此TODO文档持续维护中。Last Updated: 2025-12-12*
