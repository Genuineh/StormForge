# StormForge 文档索引 / Documentation Index

> 完整的StormForge项目文档导航
>
> Complete navigation for StormForge project documentation
>
> Last Updated: 2025-12-12

---

## 📚 核心文档 / Core Documentation

### 项目概述和状态 / Project Overview and Status

| 文档 | 说明 | 状态 |
|------|------|------|
| [README.md](../README.md) | 项目介绍、快速开始、技术栈 | ✅ 最新 |
| [TODO.md](../TODO.md) | **实际项目进度追踪** - 当前状态、已完成工作、下一步计划 | ✅ 最新 (2025-12-12) |
| [ROADMAP.md](ROADMAP.md) | 详细开发路线图、阶段规划 | ✅ 最新 |
| [ARCHITECTURE.md](ARCHITECTURE.md) | 系统架构设计、技术选型 | ✅ 最新 |
| [CONTRIBUTING.md](../CONTRIBUTING.md) | 贡献指南 | ✅ 有效 |

---

## 🎯 设计文档 / Design Documents

### Sprint 规划和设计 / Sprint Planning and Design

| 目录 | 说明 | 状态 |
|------|------|------|
| [sprints/planning/](sprints/planning/) | Sprint M1-M9 详细设计文档（**规划文档，非完成报告**） | ✅ 设计完成 |
| [sprints/](sprints/) | Sprint历史和组织 | ✅ 有效 |
| [designs/](designs/) | 各子系统详细设计规范 | ✅ 有效 |

**重要说明**: `sprints/planning/` 中的文档是**设计和规划文档**，描述了预期的功能和架构。实际实现进度请参考 [TODO.md](../TODO.md)。

### 子系统设计 / Subsystem Designs

- [designs/entity_modeling_system.md](designs/entity_modeling_system.md) - 实体建模系统设计
- [designs/connection_system.md](designs/connection_system.md) - 连接系统设计（8种连接类型）
- [designs/read_model_designer.md](designs/read_model_designer.md) - 读模型设计器
- [designs/global_library.md](designs/global_library.md) - 全局库系统设计

---

## 📖 用户和开发者指南 / User and Developer Guides

| 指南 | 说明 | 状态 |
|------|------|------|
| [guides/getting-started.md](guides/getting-started.md) | 快速入门指南 | 📋 规划中 |
| [guides/user-guide.md](guides/user-guide.md) | 用户操作指南 | 📋 规划中 |
| [guides/admin-guide.md](guides/admin-guide.md) | 管理员指南 | 📋 规划中 |
| [guides/generator-quickstart.md](guides/generator-quickstart.md) | 生成器快速入门 | 📋 规划中 |
| [guides/api-reference.md](guides/api-reference.md) | API参考文档 | 📋 规划中 |
| [guides/testing-guide.md](guides/testing-guide.md) | 测试指南 | 📋 规划中 |

**注意**: 这些指南目前处于规划阶段，部分内容可能尚未编写。

---

## 🔧 组件专属文档 / Component-Specific Documentation

### Modeler (前端建模器)

- [stormforge_modeler/README.md](../stormforge_modeler/README.md) - 建模器项目说明
- [stormforge_modeler/TROUBLESHOOTING.md](../stormforge_modeler/TROUBLESHOOTING.md) - 故障排除指南

### Backend (后端服务)

- [stormforge_backend/README.md](../stormforge_backend/README.md) - 后端项目说明
- [stormforge_backend/QUICKSTART.md](../stormforge_backend/QUICKSTART.md) - 后端快速启动指南

### Backend Toolchain (后端工具链)

- [stormforge_backend_toolchain/README.md](../stormforge_backend_toolchain/README.md) - TUI工具说明
- [stormforge_backend_toolchain/README_CN.md](../stormforge_backend_toolchain/README_CN.md) - TUI工具说明（中文）

### Generator (Rust代码生成器)

- stormforge_generator/ - 参考源代码

### Dart Generator (Flutter API包生成器)

- [stormforge_dart_generator/README.md](../stormforge_dart_generator/README.md) - Dart生成器规划（尚未实现）

### IR Schema (中间表示)

- [ir_schema/README.md](../ir_schema/README.md) - IR模式说明
- [ir_schema/docs/ir_specification.md](../ir_schema/docs/ir_specification.md) - IR v1.0规范
- [ir_schema/docs/ir_v2_specification.md](../ir_schema/docs/ir_v2_specification.md) - IR v2.0规范（规划中）
- [ir_schema/docs/MIGRATION_V1_TO_V2.md](../ir_schema/docs/MIGRATION_V1_TO_V2.md) - v1到v2迁移指南（规划中）

---

## 📦 示例项目 / Example Projects

- [examples/README.md](../examples/README.md) - 示例项目说明

---

## 🗂️ 归档文档 / Archived Documentation

- [archive/](archive/) - 已过时的文档归档

包含以下类型的归档文档：
- 早期设计规划总结（已被详细设计文档取代）
- 临时实现总结（已整合到TODO.md）
- 重复或过时的说明文档

**查看原因和详情**: [archive/README.md](archive/README.md)

---

## 🎯 文档使用建议 / Documentation Usage Guide

### 新用户 / New Users

1. 先阅读 [README.md](../README.md) 了解项目概况
2. 参考组件专属文档快速启动系统
3. 查看 [TODO.md](../TODO.md) 了解当前实现状态

### 贡献者 / Contributors

1. 阅读 [CONTRIBUTING.md](../CONTRIBUTING.md) 了解贡献流程
2. 查看 [TODO.md](../TODO.md) 了解待实现功能
3. 参考 [designs/](designs/) 中的详细设计文档
4. 阅读 [ARCHITECTURE.md](ARCHITECTURE.md) 了解系统架构

### 架构师和设计者 / Architects and Designers

1. 深入阅读 [ARCHITECTURE.md](ARCHITECTURE.md)
2. 研究 [sprints/planning/](sprints/planning/) 中的详细设计
3. 参考 [designs/](designs/) 中的子系统设计
4. 查看 [ROADMAP.md](ROADMAP.md) 了解长期规划

---

## ⚠️ 重要提示 / Important Notes

### 关于设计文档 vs 实现状态

- **设计文档** (`sprints/planning/`, `designs/`) 描述的是**预期功能和架构**
- **实现状态** 请以 **[TODO.md](../TODO.md)** 和**源代码**为准
- 设计文档中使用的未来日期（2026年）表示规划时间，**不代表实际完成时间**

### 文档更新频率

- **TODO.md**: 频繁更新，反映最新进度
- **README.md**: 随重大变更更新
- **设计文档**: 设计完成后相对稳定
- **ROADMAP.md**: 季度更新或重大调整时更新

---

## 📝 文档维护 / Documentation Maintenance

如发现文档问题，请：

If you find issues with documentation, please:

1. 创建Issue说明问题
2. 提交PR修复（对于简单的拼写错误等）
3. 联系项目维护者

---

*最后更新 / Last Updated: 2025-12-12*
