# MoleUI - Claude Code 项目指南

## 项目概述

MoleUI 是 Mole（macOS 系统清理 CLI 工具）的原生 Mac GUI 版本，使用 Swift + SwiftUI 构建。
MVP 阶段包含三个核心功能：Clean（系统清理）、Uninstall（应用卸载）、Purge（项目构建产物清理）。

## 技术栈

- 语言：Swift 5+
- UI 框架：SwiftUI
- 数据持久化：SwiftData
- 最低部署目标：macOS 14.0 (Sonoma)
- 构建工具：Xcode 16+
- 架构模式：MVVM + Service Layer

## 项目结构

```
MoleUI/
├── MoleUI/
│   ├── App/                    # App 入口和全局配置
│   │   └── MoleUIApp.swift
│   ├── Models/                 # 数据模型
│   ├── ViewModels/             # 视图模型（业务逻辑）
│   ├── Views/                  # SwiftUI 视图
│   │   ├── Sidebar/            # 侧边栏导航
│   │   ├── Clean/              # 清理功能视图
│   │   ├── Uninstall/          # 卸载功能视图
│   │   └── Purge/              # 项目清理视图
│   ├── Services/               # 核心服务层
│   │   ├── FileService.swift   # 文件操作（安全删除、路径验证）
│   │   ├── CleanService.swift  # 清理扫描逻辑
│   │   ├── UninstallService.swift  # 应用卸载逻辑
│   │   ├── PurgeService.swift  # 项目产物扫描逻辑
│   │   └── PrivilegedHelper.swift  # 提权操作
│   ├── Utils/                  # 工具类
│   └── Assets.xcassets         # 资源文件
├── MoleUI.xcodeproj
└── CLAUDE.md
```

## 编码规范

- 使用 Swift 标准命名规范（camelCase 变量/函数，PascalCase 类型）
- 视图文件以 `View` 后缀命名，视图模型以 `ViewModel` 后缀命名
- 服务层以 `Service` 后缀命名
- 使用 `@Observable` (Observation framework) 替代 `ObservableObject`
- 优先使用 Swift Concurrency（async/await、Actor）处理并发
- 文件操作必须经过 `FileService` 的路径验证
- 所有删除操作需要用户确认，支持 dry-run 预览
- 中文注释，英文代码

## 安全规则（关键）

- 永远不删除系统关键路径（/, /System, /bin, /usr 等）
- 路径验证必须检查：空路径、路径遍历（..）、控制字符、符号链接目标
- 系统应用（com.apple.* 核心组件）不可卸载
- 敏感数据（密码管理器、SSH、密钥链）永远不清理
- 所有文件操作记录到操作日志
- 提权操作使用 SMJobBless 或 AuthorizationServices

## 构建和运行

```bash
# 使用 Xcode 打开
open MoleUI.xcodeproj

# 命令行构建
xcodebuild -project MoleUI.xcodeproj -scheme MoleUI -configuration Debug build
```

## 关键依赖

- 无第三方依赖，纯 Apple 框架实现
- Foundation: 文件系统操作
- AppKit: 应用信息读取（NSWorkspace）
- ServiceManagement: LaunchAgent 管理
- Security: AuthorizationServices 提权

## 注意事项

- App Sandbox 需要关闭或配置 entitlements 以访问 ~/Library 等目录
- Hardened Runtime 需要配置 com.apple.security.temporary-exception 访问文件系统
- 大文件扫描使用异步流，避免阻塞主线程
- 文件大小计算使用 URLResourceValues 而非 shell 命令
