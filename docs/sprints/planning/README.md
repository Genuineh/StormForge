# Sprint Planning Documents

> **重要说明 (Important Note)**: 本目录包含的是**设计和规划文档**，而非实际完成报告。
> This directory contains **design and planning documents**, not actual completion reports.

这些文档使用未来日期（2026年）是因为它们是作为详细规划文档创建的，描述了预期的功能和架构设计。**实际实施时间表将根据团队资源和优先级动态调整。**

These documents use future dates (2026) because they were created as detailed planning documents describing expected features and architectural designs. **The actual implementation timeline will be dynamically adjusted based on team resources and priorities.**

---

## Sprint M1-M9: Modeler 2.0 Upgrade Plan (设计文档)

这些Sprint文档详细描述了Modeler 2.0的完整架构和功能设计：

### Sprint M1: 项目管理基础 (Project Management Foundation)
**Status**: 🚧 部分实现 (Partially Implemented)
- [SPRINT_M1_SUMMARY.md](SPRINT_M1_SUMMARY.md) - 设计文档

**已实现**: 
- ✅ 后台数据模型 (Backend data models)
- ✅ 基础API框架 (Basic API framework)
- ✅ JWT认证系统 (JWT authentication)

**待实现**:
- ⏳ 前端UI集成
- ⏳ 完整的项目管理功能

---

### Sprint M2: 组件连接系统 (Component Connection System)
**Status**: 📋 设计完成 (Design Complete)
- [SPRINT_M2_SUMMARY.md](SPRINT_M2_SUMMARY.md) - 设计文档

**设计特性**:
- 8种连接类型 (Event, Command, Query, ReadModel, Policy, Saga, Integration, DataFlow)
- 连接验证规则
- 可视化系统

**实施状态**: 数据模型已定义，UI待实现

---

### Sprint M3: 实体建模系统 (Entity Modeling System)
**Status**: 📋 设计完成 (Design Complete)
- [SPRINT_M3_COMPLETION_REPORT.md](SPRINT_M3_COMPLETION_REPORT.md) - 设计文档
- [SPRINT_M3_SUMMARY.md](SPRINT_M3_SUMMARY.md) - 摘要

**设计特性**:
- 实体属性和方法定义
- 业务不变量系统
- 验证规则

**实施状态**: 数据模型已定义，编辑器UI待实现

---

### Sprint M4: 读模型设计器 (Read Model Designer)
**Status**: 📋 设计完成 (Design Complete)
- [SPRINT_M4_COMPLETION_REPORT.md](SPRINT_M4_COMPLETION_REPORT.md) - 设计文档
- [SPRINT_M4_SUMMARY.md](SPRINT_M4_SUMMARY.md) - 摘要

**设计特性**:
- 多实体联接
- 字段源追踪
- 投影配置

**实施状态**: 数据模型已定义，设计器UI待实现

---

### Sprint M5: 命令数据模型设计器 (Command Data Model Designer)
**Status**: 📋 设计完成 (Design Complete)
- [SPRINT_M5_COMPLETION_REPORT.md](SPRINT_M5_COMPLETION_REPORT.md) - 设计文档
- [SPRINT_M5_SUMMARY.md](SPRINT_M5_SUMMARY.md) - 摘要

**设计特性**:
- 命令字段定义
- 字段源追踪
- 验证规则

**实施状态**: 数据模型已定义，设计器UI待实现

---

### Sprint M6: 企业全局库 (Enterprise Global Library)
**Status**: 📋 设计完成 (Design Complete)
- [SPRINT_M6_COMPLETION_REPORT.md](SPRINT_M6_COMPLETION_REPORT.md) - 设计文档
- [SPRINT_M6_SECURITY_SUMMARY.md](SPRINT_M6_SECURITY_SUMMARY.md) - 安全总结

**设计特性**:
- 三层架构 (Personal, Team, Public)
- 组件版本管理
- 依赖追踪

**实施状态**: 数据模型已定义，UI待实现

---

### Sprint M7: 增强画布集成 (Enhanced Canvas Integration)
**Status**: 📋 设计完成 (Design Complete)
- [SPRINT_M7_COMPLETION_REPORT.md](SPRINT_M7_COMPLETION_REPORT.md) - 设计文档 (English)
- [SPRINT_M7_COMPLETION_REPORT_CN.md](SPRINT_M7_COMPLETION_REPORT_CN.md) - 设计文档 (中文)
- [SPRINT_M7_FINAL_SUMMARY.md](SPRINT_M7_FINAL_SUMMARY.md) - 最终摘要
- [SPRINT_M7_IMPLEMENTATION_COMPLETE.md](SPRINT_M7_IMPLEMENTATION_COMPLETE.md) - 实现计划
- [SPRINT_M7_IMPLEMENTATION_SUMMARY_CN.md](SPRINT_M7_IMPLEMENTATION_SUMMARY_CN.md) - 实现摘要 (中文)
- [SPRINT_M7_KNOWN_ISSUES.md](SPRINT_M7_KNOWN_ISSUES.md) - 已知问题
- [SPRINT_M7_PROGRESS_REPORT.md](SPRINT_M7_PROGRESS_REPORT.md) - 进度报告
- [SPRINT_M7_SECURITY_SUMMARY.md](SPRINT_M7_SECURITY_SUMMARY.md) - 安全总结

**设计特性**:
- 画布与编辑器集成
- 双向同步
- 实时预览

**实施状态**: 设计完成，实现待开始

---

### Sprint M8: IR Schema v2.0
**Status**: 📋 设计完成 (Design Complete)
- [SPRINT_M8_COMPLETION_REPORT.md](SPRINT_M8_COMPLETION_REPORT.md) - 设计文档 (English)
- [SPRINT_M8_COMPLETION_REPORT_CN.md](SPRINT_M8_COMPLETION_REPORT_CN.md) - 设计文档 (中文)
- [SPRINT_M8_SECURITY_SUMMARY.md](SPRINT_M8_SECURITY_SUMMARY.md) - 安全总结

**设计特性**:
- IR v2.0 JSON Schema
- 迁移工具规范
- 向后兼容性

**实施状态**: Schema已定义，迁移工具待实现

---

### Sprint M9: 测试、完善与文档 (Testing, Refinement & Documentation)
**Status**: 📋 规划中 (Planned)
- [SPRINT_M9_DOCUMENTATION_COMPLETE.md](SPRINT_M9_DOCUMENTATION_COMPLETE.md) - 文档计划
- [SPRINT_M9_DOCUMENTATION_SUMMARY_CN.md](SPRINT_M9_DOCUMENTATION_SUMMARY_CN.md) - 文档摘要 (中文)
- [SPRINT_M9_FINAL_COMPLETION_REPORT.md](SPRINT_M9_FINAL_COMPLETION_REPORT.md) - 最终计划
- [SPRINT_M9_SECURITY_SUMMARY.md](SPRINT_M9_SECURITY_SUMMARY.md) - 安全计划
- [SPRINT_M9_完成总结_中文.md](SPRINT_M9_完成总结_中文.md) - 完成计划 (中文)

**规划内容**:
- 综合测试套件
- 用户文档
- API文档
- 性能优化

**实施状态**: 规划阶段

---

## 使用这些文档 (How to Use These Documents)

1. **作为参考**: 了解Modeler 2.0的完整设计愿景
2. **指导实施**: 根据设计文档逐步实现功能
3. **调整优先级**: 根据实际需求调整实施顺序
4. **跟踪进度**: 对比设计与实际实现，更新TODO.md

---

## 实际实施状态 (Actual Implementation Status)

请参考 [TODO.md](../../../TODO.md) 获取当前的实际实施进度。

For the current actual implementation progress, please refer to [TODO.md](../../../TODO.md).

---

## 导航 (Navigation)

- [Back to Sprints](../)
- [Project TODO](../../../TODO.md)
- [Project Roadmap](../../ROADMAP.md)
- [Architecture Documentation](../../ARCHITECTURE.md)
