# Mole 项目文档

**重要说明**：MoleUI 是一个完全独立的 Swift 原生应用，不依赖 Mole CLI 的任何代码。所有功能都将使用 Swift 重新实现。

本目录包含 Mole CLI 的完整功能分析和 MoleUI（Mac 原生应用）的开发准备文档。Mole CLI 作为参考实现，帮助我们理解业务逻辑和最佳实践，但 MoleUI 将用 Swift 完全重新实现。

## 文档结构

### 📁 product/ - 产品功能文档
详细描述每个功能模块的产品定义、使用方式和 Mac 应用开发建议。

1. **[01-项目概述.md](product/01-项目概述.md)**
   - 项目简介和核心价值
   - 目标用户和产品定位
   - 核心功能模块概览

2. **[02-Clean深度清理.md](product/02-Clean深度清理.md)**
   - 14个清理类别详解
   - 安全机制和白名单
   - 使用方式和操作流程
   - Mac 应用 UI 设计建议

3. **[03-Uninstall智能卸载.md](product/03-Uninstall智能卸载.md)**
   - 应用发现和元数据缓存
   - 12个关联文件清理位置
   - 应用保护机制
   - Mac 应用开发建议

4. **[04-Optimize系统优化.md](product/04-Optimize系统优化.md)**
   - 系统检查和安全修复
   - 性能优化和数据库优化
   - 优化流程和安全机制
   - Mac 应用功能增强建议

5. **[05-Analyze磁盘分析.md](product/05-Analyze磁盘分析.md)**
   - 概览模式和详细扫描
   - 并发扫描和缓存系统
   - 交互操作和删除机制
   - Mac 应用可视化设计

6. **[06-Status系统监控.md](product/06-Status系统监控.md)**
   - 8类监控指标详解
   - 健康评分算法
   - 实时更新和交互操作
   - Mac 应用图表设计

7. **[07-Purge项目清理.md](product/07-Purge项目清理.md)**
   - 9种项目类型支持
   - 自定义扫描路径
   - 最近项目保护机制
   - Mac 应用智能推荐

8. **[08-Installer安装包清理.md](product/08-Installer安装包清理.md)**
   - 6个扫描位置
   - ZIP 内容检查
   - 源位置标记
   - Mac 应用批量操作

### 📁 technical/ - 技术文档
深入分析技术架构、实现细节和性能优化。

1. **[01-技术架构.md](technical/01-技术架构.md)**
   - 架构概览和技术栈
   - 项目结构和模块划分
   - 核心设计模式
   - 性能优化策略
   - 安全机制实现
   - 配置管理和日志系统
   - 测试策略和部署流程

### 📁 mac-app/ - Mac 应用开发准备
Mac 原生应用开发计划和实现指南。

1. **[00-架构说明.md](mac-app/00-架构说明.md)** ⭐ 必读
   - MoleUI 独立架构说明
   - 为什么独立实现
   - 核心服务实现示例
   - 系统 API 使用指南
   - 权限管理方案

2. **[01-开发计划.md](mac-app/01-开发计划.md)**
   - 项目概述和开发目标
   - 技术选型（Swift + SwiftUI）
   - 应用架构（MVVM）
   - 核心功能实现代码示例
   - UI 设计和权限管理

3. **[02-功能分析总结.md](mac-app/02-功能分析总结.md)**
   - 7个核心功能模块总结
   - Mole CLI vs MoleUI 实现对比
   - 技术架构特点
   - 开发路线图
   - 竞品对比分析

4. **[03-实现策略快速参考.md](mac-app/03-实现策略快速参考.md)** ⭐ 必读
   - Mole CLI vs MoleUI 实现对比
   - 关键 API 映射
   - 并发处理、缓存策略
   - 代码示例和性能对比

5. **[04-迭代开发计划.md](mac-app/04-迭代开发计划.md)** 🚀 开始开发
   - 10个 Sprint 总览
   - Sprint 0-4 详细计划
   - 每个迭代的任务清单
   - 验收标准和技术要点

6. **[05-Sprint5-10详细计划.md](mac-app/05-Sprint5-10详细计划.md)**
   - Sprint 5-10 详细计划
   - Analyze、Status、Optimize 等功能
   - UI 优化和测试发布

7. **[06-Sprint0快速开始.md](mac-app/06-Sprint0快速开始.md)** 🎯 立即开始
   - Day 1-5 详细步骤
   - 项目创建和配置
   - 基础 UI 框架搭建
   - 开发工具配置
   - 验收检查清单

## 文档使用指南

### 对于产品经理
- 阅读 `product/` 目录下的所有文档
- 了解每个功能的价值主张和使用场景
- 参考 Mac 应用开发建议进行产品设计

### 对于开发者
- 先阅读 `technical/01-技术架构.md` 了解整体架构
- 阅读 `mac-app/01-开发计划.md` 了解开发计划
- 参考 `product/` 目录下的功能文档了解业务逻辑
- 使用提供的代码示例作为开发参考

### 对于设计师
- 阅读 `product/` 目录下的 Mac 应用 UI 设计建议
- 参考 `mac-app/01-开发计划.md` 中的 UI 设计部分
- 遵循 macOS Human Interface Guidelines

### 对于测试人员
- 阅读 `product/` 目录了解功能需求
- 参考 `technical/01-技术架构.md` 中的测试策略
- 使用 `mac-app/01-开发计划.md` 中的测试用例

## 快速开始

### 1. 了解项目
```bash
# 阅读项目概述
cat product/01-项目概述.md

# 阅读技术架构
cat technical/01-技术架构.md
```

### 2. 选择功能模块
```bash
# 例如：了解 Clean 功能
cat product/02-Clean深度清理.md
```

### 3. 开始开发
```bash
# 阅读开发计划
cat mac-app/01-开发计划.md

# 查看功能分析总结
cat mac-app/02-功能分析总结.md
```

## 文档维护

### 更新频率
- 产品文档：功能变更时更新
- 技术文档：架构调整时更新
- 开发计划：每个 Sprint 更新

### 贡献指南
1. 发现文档问题或需要补充时，创建 Issue
2. 提交 Pull Request 更新文档
3. 确保文档格式统一，使用 Markdown
4. 添加必要的代码示例和图表

## 相关资源

### 官方文档
- [Mole GitHub](https://github.com/tw93/mole)
- [Mole README](../../README.md)
- [安全审计](../../SECURITY_AUDIT.md)
- [贡献指南](../../CONTRIBUTING.md)

### 技术参考
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [macOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/macos)
- [Bubble Tea](https://github.com/charmbracelet/bubbletea)
- [gopsutil](https://github.com/shirou/gopsutil)

### 类似项目
- [CleanMyMac](https://macpaw.com/cleanmymac)
- [AppCleaner](https://freemacsoft.net/appcleaner/)
- [DaisyDisk](https://daisydiskapp.com/)
- [iStat Menus](https://bjango.com/mac/istatmenus/)
- [Stats](https://github.com/exelban/stats)

## 联系方式

- **项目作者**：[@tw93](https://github.com/tw93)
- **问题反馈**：[GitHub Issues](https://github.com/tw93/mole/issues)
- **讨论交流**：[Telegram](https://t.me/+GclQS9ZnxyI2ODQ1)

---

**最后更新**：2024-02-18
**文档版本**：1.0
**适用于**：Mole CLI 版本 + MoleUI 开发
