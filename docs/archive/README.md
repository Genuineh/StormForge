# 归档文档 / Archived Documentation

> Archive of outdated planning and summary documents
> 
> 过时的规划和总结文档归档
>
> Last Updated: 2025-12-12

---

## 📋 说明 / Description

本目录包含已过时的文档，这些文档在项目早期创建，但已被更新的文档取代。保留这些文档仅供历史参考。

This directory contains outdated documentation that was created during the early stages of the project but has since been superseded by updated documents. These are kept for historical reference only.

---

## 📚 归档文档列表 / Archived Documents

### 设计和规划总结 / Design and Planning Summaries

以下文档是早期的设计规划总结，已被 `docs/sprints/planning/` 中的详细设计文档取代：

The following documents are early design planning summaries that have been superseded by detailed design documents in `docs/sprints/planning/`:

1. **MODELER_UPGRADE_PLAN.md** - 早期Modeler 2.0升级完整规划
   - 当前版本: `docs/sprints/planning/SPRINT_M1-M9_*.md` (详细分阶段设计)
   
2. **MODELER_UPGRADE_SUMMARY.md** - Modeler 2.0升级快速参考指南
   - 当前版本: `docs/sprints/planning/README.md` + 各Sprint设计文档

3. **SPRINT_M1_UI_GUIDE.md** - Sprint M1 UI实现设计指南
   - 实际状态: 已完成不同于指南的UI实现，见 `FRONTEND_UI_IMPLEMENTATION_SUMMARY.md`
   
4. **SPRINT_M1_UI_SUMMARY.md** - Sprint M1 UI实现设计规范
   - 实际状态: UI已按不同方案实现，见实际代码
   
5. **sprint_m1_completion.md** - Sprint M1后端框架实现报告
   - 实际状态: 后端已大幅扩展，见 `BACKEND_API_IMPLEMENTATION.md`
   
6. **sprint_m1_backend_completion.md** - Sprint M1后端完成报告（副本）
   - 实际状态: 与上述文档重复
   
7. **sprint_s03_completion.md** - Sprint S03 Rust生成器完成报告
   - 实际状态: 生成器已在使用中，见 `stormforge_generator/` 代码

### 临时实现总结 / Temporary Implementation Summaries

以下是临时性的实现总结文档，其内容已整合到最新的TODO和主文档中：

The following are temporary implementation summary documents whose content has been integrated into the latest TODO and main documents:

1. **BACKEND_API_IMPLEMENTATION.md** - 后端API实现总结
   - 整合到: `TODO.md` 的实际实施状态部分
   
2. **FRONTEND_UI_IMPLEMENTATION_SUMMARY.md** - 前端UI实现总结  
   - 整合到: `TODO.md` 的实际实施状态部分
   
3. **DATABASE_SCHEMA.md** - 数据库模式设计
   - 参考: 后端代码中的models定义是最新的
   
4. **DOCUMENTATION_REORGANIZATION.md** - 文档重组说明(2025-12-11)
   - 已完成，可参考但已被本次重组(2025-12-12)取代

---

## ✅ 当前有效文档 / Current Valid Documentation

请使用以下文档获取最新信息：

Please refer to the following documents for up-to-date information:

### 核心文档 / Core Documents

- **[TODO.md](../../TODO.md)** - 当前项目状态和实际进度跟踪
- **[README.md](../../README.md)** - 项目概述和快速入门
- **[ROADMAP.md](../ROADMAP.md)** - 详细的开发路线图
- **[ARCHITECTURE.md](../ARCHITECTURE.md)** - 系统架构文档

### 设计文档 / Design Documents

- **[docs/sprints/planning/](../sprints/planning/)** - Sprint M1-M9详细设计文档
- **[docs/designs/](../designs/)** - 各子系统详细设计
- **[docs/guides/](../guides/)** - 用户和开发者指南

### 实现参考 / Implementation Reference

- **源代码** - 最准确的实现状态始终是源代码本身
  - `stormforge_modeler/lib/` - 前端实现
  - `stormforge_backend/src/` - 后端实现
  - `stormforge_generator/src/` - 生成器实现

---

## 🗂️ 归档原因 / Reason for Archival

这些文档被归档的主要原因：

These documents were archived for the following reasons:

1. **内容重复** - 多个文档描述相同内容
2. **信息过时** - 实际实现与文档描述不同
3. **已被取代** - 更详细或更准确的文档已创建
4. **临时性质** - 作为临时总结创建，已整合到主文档
5. **减少混淆** - 避免用户混淆设计文档和实际完成状态

Reasons include:
1. **Content duplication** - Multiple documents describing the same content
2. **Outdated information** - Actual implementation differs from documentation
3. **Superseded** - More detailed or accurate documents have been created
4. **Temporary nature** - Created as temporary summaries, now integrated into main docs
5. **Reduce confusion** - Avoid user confusion between design docs and actual completion status

---

*归档日期 / Archived: 2025-12-12*
