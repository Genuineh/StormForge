# StormForge Backend Toolchain (后端工具链)

StormForge 后端生命周期管理的可视化 TUI（终端用户界面）工具。使用 Rust 和 ratatui 构建，提供交互式的方式来设置、启动、监控和清理后端服务。

## 功能特性

- 🚀 **一键启动**：初始化环境并启动所有服务
- 📊 **可视化仪表板**：实时监控服务状态
- 📝 **日志查看器**：查看和浏览服务日志
- ⚙️ **配置查看器**：快速访问 .env 配置
- 🧹 **完整清理**：一键停止和删除所有服务
- 🎨 **友好的 TUI**：直观的键盘导航

## 截图

```
┌────────────────────────────────────────────────────────────────────┐
│              StormForge Backend Toolchain                          │
├──────────────────────┬─────────────────────────────────────────────┤
│ 菜单                 │ 最近活动                                     │
│                      │                                             │
│ 1. 设置环境          │ [10:23:45] MongoDB 启动成功                 │
│ 2. 启动 MongoDB      │ [10:23:40] ✓ 从 .env.example 创建 .env    │
│ 3. 构建后端          │ [10:23:35] 正在构建后端...                  │
│ 4. 启动后端          │                                             │
│ 5. 查看状态          │                                             │
│ 6. 查看日志          │                                             │
│ 7. 停止后端          │                                             │
│ 8. 停止 MongoDB      │                                             │
│ 9. 清理所有          │                                             │
│ 10. 配置             │                                             │
│ Q. 退出              │                                             │
│                      │                                             │
├──────────────────────┴─────────────────────────────────────────────┤
│ ↑/↓: 导航 | Enter: 选择 | Q/Esc: 退出                            │
└────────────────────────────────────────────────────────────────────┘
```

## 前置要求

- Rust 1.70 或更高版本
- Docker（用于 MongoDB）
- cargo（Rust 包管理器）

## 安装

### 从源码构建

```bash
cd stormforge_backend_toolchain
cargo build --release
```

编译后的二进制文件位于 `target/release/stormforge_backend_toolchain`。

## 使用方法

### 启动工具

```bash
# 从 stormforge_backend_toolchain 目录

# 方式 1: 使用便捷脚本（如需要会自动构建）
./run.sh

# 方式 2: 使用 cargo run
cargo run

# 方式 3: 直接使用编译好的二进制文件
./target/release/stormforge_backend_toolchain
```

### 导航

工具使用直观的菜单界面：

**主菜单：**
- `↑`/`↓` 或 `k`/`j`：导航菜单项
- `Enter`：选择菜单项
- `Q` 或 `Esc`：退出

**状态视图：**
- `r`：刷新状态
- `Q` 或 `Esc`：返回菜单

**日志查看器：**
- `↑`/`↓` 或 `k`/`j`：滚动日志
- `c`：清除日志
- `Q` 或 `Esc`：返回菜单

## 菜单选项说明

### 1. 设置环境
如果 `.env` 文件不存在，则从 `.env.example` 创建。这是启动服务前的第一步。

### 2. 启动 MongoDB
使用 Docker 启动 MongoDB：
```bash
docker run -d -p 27017:27017 --name stormforge_mongodb --rm mongo:latest
```

### 3. 构建后端
以 release 模式构建后端：
```bash
cargo build --release
```

### 4. 启动后端
启动后端服务器。服务将在 `http://localhost:3000` 可用。

### 5. 查看状态
显示所有服务的当前状态：
- MongoDB 状态
- 后端状态
- 健康检查状态
- 后端路径

### 6. 查看日志
查看所有活动日志，支持滚动浏览。

### 7. 停止后端
优雅地停止后端服务器。

### 8. 停止 MongoDB
停止 MongoDB Docker 容器。

### 9. 清理所有
停止所有服务并删除 MongoDB 容器。需要确认。

### 10. 配置
查看当前的 `.env` 配置文件。

## 快速开始流程

1. 启动工具：`cargo run` 或 `./run.sh`
2. 选择 "1. 设置环境" - 创建 .env 文件
3. 选择 "2. 启动 MongoDB" - 启动数据库
4. 选择 "3. 构建后端" - 构建服务器（首次需要）
5. 选择 "4. 启动后端" - 启动服务器
6. 选择 "5. 查看状态" - 验证一切正常运行
7. 访问 API：`http://localhost:3000`

完成后：
1. 选择 "9. 清理所有" - 停止所有服务
2. 按 'Y' 确认
3. 按 'Q' 退出

## API 端点

后端运行后，可以访问：

- **API 基础地址**：http://localhost:3000/api
- **Swagger UI**：http://localhost:3000/swagger-ui
- **健康检查**：http://localhost:3000/health

## 故障排除

### MongoDB 启动失败
- 确保 Docker 已安装并运行
- 检查端口 27017 是否可用
- 尝试手动启动：`docker run -d -p 27017:27017 --name stormforge_mongodb mongo`

### 后端构建失败
- 确保在正确的目录中
- 尝试清理构建：`cargo clean && cargo build`
- 查看日志中的具体错误信息

### 端口 3000 已被占用
- 编辑 `.env` 文件并更改 PORT 值
- 或停止占用端口 3000 的进程

## 开发

### 项目结构

```
stormforge_backend_toolchain/
├── src/
│   ├── main.rs       # 入口点和事件处理
│   ├── backend.rs    # 后端管理逻辑
│   └── ui.rs         # TUI 渲染和状态管理
├── Cargo.toml
├── README.md
└── README_CN.md      # 中文说明文档
```

### 构建

```bash
# Debug 构建
cargo build

# Release 构建（优化）
cargo build --release

# 使用 cargo 运行
cargo run

# 运行测试（如有）
cargo test
```

### 代码质量

```bash
# 格式化代码
cargo fmt

# 运行 linter
cargo clippy

# 检查错误
cargo check
```

## 架构

工具由三个主要组件组成：

1. **Main (`main.rs`)**：
   - 终端设置和事件循环
   - 键盘事件处理
   - 状态转换

2. **Backend Manager (`backend.rs`)**：
   - 服务生命周期管理
   - 进程生成和监控
   - Docker 容器管理
   - 状态检查

3. **UI (`ui.rs`)**：
   - 使用 ratatui 的 TUI 渲染
   - 多视图（菜单、状态、日志、配置）
   - 视觉反馈和样式

## 依赖

- **ratatui**：TUI 框架
- **crossterm**：终端操作
- **anyhow**：错误处理
- **chrono**：时间戳生成

## 许可证

本项目是 StormForge 的一部分，遵循相同的 MIT 许可证。

## 贡献

欢迎贡献！请确保：
- 代码遵循 Rust 规范
- 提交前运行 `cargo fmt` 和 `cargo clippy`
- 在各种场景下彻底测试工具

## 支持

如有问题或疑问：
- 查看主 StormForge 文档
- 查看后端 QUICKSTART 指南
- 在 GitHub 上提出问题

---

**祝编码愉快！** 🚀
