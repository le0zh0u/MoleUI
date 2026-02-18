# Uninstall - 智能卸载功能

## 功能概述

彻底卸载应用程序及其所有关联文件，包括偏好设置、缓存、日志、Launch Agent/Daemon等隐藏残留。

## 核心价值

- **彻底清理**：删除应用的所有痕迹
- **空间回收**：平均每个应用回收 2-5GB
- **智能识别**：自动查找所有关联文件
- **安全保护**：防止误删系统关键应用

## 应用发现

### 扫描位置
1. `/Applications` - 系统应用目录
2. `~/Applications` - 用户应用目录
3. `/Library/Input Methods` - 输入法
4. `/Library/PreferencePanes` - 偏好设置面板
5. `/Library/Screen Savers` - 屏幕保护程序
6. `/System/Library/CoreServices` - 核心服务
7. 外部卷上的应用（可选）

### 应用元数据

每个应用显示：
- **应用名称**：从 Info.plist 读取
- **应用大小**：包含所有文件
- **最后使用时间**：通过 mdls 查询
- **Bundle ID**：唯一标识符
- **安装位置**：完整路径

### 元数据缓存

**位置**：`~/.cache/mole/uninstall_app_metadata_v1`

**格式**：
```
path|mtime|size_kb|last_used_epoch|updated_epoch|bundle_id|display_name
```

**特性**：
- TTL：7天
- 增量更新：后台进程
- 并行刷新：最多4个工作进程
- 原子锁：防止并发冲突

## 关联文件清理

### 1. Application Support
**位置**：
- `~/Library/Application Support/[AppName]`
- `/Library/Application Support/[AppName]`

**内容**：
- 应用数据
- 插件
- 模板
- 用户配置

### 2. Preferences（偏好设置）
**位置**：
- `~/Library/Preferences/[BundleID].plist`
- `~/Library/Preferences/ByHost/[BundleID].[UUID].plist`
- `/Library/Preferences/[BundleID].plist`

**内容**：
- 应用设置
- 用户偏好
- 窗口位置

### 3. Caches（缓存）
**位置**：
- `~/Library/Caches/[BundleID]`
- `/Library/Caches/[BundleID]`

**内容**：
- 临时缓存
- 下载缓存
- 图片缓存

### 4. Logs（日志）
**位置**：
- `~/Library/Logs/[AppName]`
- `/Library/Logs/[AppName]`
- `/Library/Logs/DiagnosticReports/[AppName]*`

**内容**：
- 应用日志
- 崩溃报告
- 诊断信息

### 5. WebKit Storage
**位置**：
- `~/Library/WebKit/[BundleID]`
- `~/Library/Safari/LocalStorage/[BundleID]*`

**内容**：
- Web存储
- LocalStorage
- IndexedDB

### 6. Cookies
**位置**：
- `~/Library/Cookies/[BundleID].binarycookies`

**内容**：
- Cookie数据

### 7. Saved Application State
**位置**：
- `~/Library/Saved Application State/[BundleID].savedState`

**内容**：
- 窗口状态
- 未保存的文档

### 8. Launch Agents/Daemons
**位置**：
- `~/Library/LaunchAgents/[BundleID].plist`
- `/Library/LaunchAgents/[BundleID].plist`
- `/Library/LaunchDaemons/[BundleID].plist`

**内容**：
- 自动启动配置
- 后台服务

### 9. Extensions（扩展）
**位置**：
- `~/Library/Application Scripts/[BundleID]*`
- `~/Library/Containers/[BundleID]*`

**内容**：
- Safari扩展
- 分享扩展
- 今日小组件

### 10. Plugins（插件）
**位置**：
- `~/Library/Internet Plug-Ins/[AppName]*`
- `/Library/Internet Plug-Ins/[AppName]*`

**内容**：
- 浏览器插件
- 系统插件

### 11. Frameworks（框架）
**位置**：
- `~/Library/Frameworks/[AppName]*`
- `/Library/Frameworks/[AppName]*`

**内容**：
- 共享框架
- 动态库

### 12. Receipts（安装收据）
**位置**：
- `/Library/Receipts/[AppName]*`
- `/var/db/receipts/[BundleID]*`

**内容**：
- 安装记录
- 包管理信息

## 应用保护机制

### 系统应用保护
永不卸载：
- Control Center
- System Settings
- Finder
- Safari（系统版本）
- Mail（系统版本）

### 关键工具保护
默认保护：
- **AI工具**：Cursor, Claude, ChatGPT, Ollama
- **VPN工具**：Shadowsocks, V2Ray, Tailscale, Clash
- **开发工具**：Xcode（可选）
- **系统工具**：Terminal, Activity Monitor

### 时间机器保护
- 正在运行的Time Machine备份
- 活跃的备份进程

## 使用方式

### 基础用法
```bash
mo uninstall                # 交互式卸载
```

### 交互界面
```
Select Apps to Remove
═══════════════════════════
▶ ☑ Photoshop 2024            (4.2G) | Old
  ☐ IntelliJ IDEA             (2.8G) | Recent
  ☐ Premiere Pro              (3.4G) | Recent
```

### 卸载流程
1. 选择要卸载的应用
2. 确认卸载
3. 扫描关联文件
4. 显示清理计划
5. 执行删除
6. 显示结果

## 安全机制

### 应用名称验证
- 最少3个字符（防止"Go"匹配"Google"）
- 模糊匹配关闭
- 精确Bundle ID匹配

### 路径验证
- 只在标准位置查找
- 验证符号链接
- 检查路径合法性

### 权限管理
- 用户应用：无需sudo
- 系统应用：请求sudo
- Launch Daemon：需要sudo

### 确认机制
- 显示将要删除的文件数量
- 显示将要回收的空间
- 需要用户明确确认

## 性能优化

### 并行扫描
- 最多32个并发任务
- 按应用并行扫描
- 智能任务调度

### 元数据缓存
- 7天TTL
- 后台增量更新
- 原子锁保护

### 快速查找
- mdfind快速搜索
- 10秒超时保护
- 跳过网络卷

## 卸载结果

### 典型结果
```
Uninstalling: Photoshop 2024

  ✓ Removed application
  ✓ Cleaned 52 related files across 12 locations
    - Application Support, Caches, Preferences
    - Logs, WebKit storage, Cookies
    - Extensions, Plugins, Launch daemons

====================================================================
Space freed: 12.8GB
====================================================================
```

### 日志记录
位置：`~/.config/mole/operations.log`

格式：
```
[timestamp] [uninstall] [delete] [path] [size]
```

## 常见问题

### Q: 会删除我的文档吗？
A: 不会。只删除应用本身和系统缓存，不删除用户文档。

### Q: 可以恢复吗？
A: 应用本身会移至垃圾箱，可以恢复。但关联文件会直接删除。

### Q: 为什么有些应用找不到？
A: 可能是：
1. 应用在非标准位置
2. 应用是系统保护的
3. 应用是命令行工具（不是.app包）

### Q: 卸载后应用还在Launchpad？
A: 运行 `killall Dock` 刷新Launchpad。

## Mac应用开发建议

### UI设计

1. **应用列表界面**
   - 显示所有已安装应用
   - 显示应用图标、名称、大小
   - 显示最后使用时间
   - 支持搜索和过滤
   - 支持排序（按大小、名称、时间）

2. **应用详情界面**
   - 显示应用信息
   - 显示关联文件列表
   - 显示将要删除的文件
   - 显示将要回收的空间

3. **卸载进度界面**
   - 显示当前操作
   - 显示进度条
   - 显示已删除的文件数

4. **结果界面**
   - 显示卸载结果
   - 显示回收的空间
   - 支持查看日志

### 功能增强

1. **批量卸载**：支持一次卸载多个应用
2. **智能推荐**：推荐长期未使用的应用
3. **空间分析**：显示应用占用空间排行
4. **卸载历史**：记录卸载历史
5. **恢复功能**：支持恢复最近卸载的应用

### 技术实现

1. **应用扫描**：使用 NSWorkspace 获取应用列表
2. **图标获取**：使用 NSWorkspace 获取应用图标
3. **元数据读取**：使用 NSBundle 读取 Info.plist
4. **文件删除**：使用 NSFileManager 移至垃圾箱
5. **权限管理**：使用 SMJobBless 请求权限
6. **后台扫描**：使用 DispatchQueue 后台扫描

### 用户体验优化

1. **快速启动**：使用缓存加速应用列表加载
2. **实时搜索**：支持实时搜索过滤
3. **拖拽卸载**：支持拖拽应用到窗口卸载
4. **通知提醒**：卸载完成后发送通知
5. **撤销功能**：支持撤销最近的卸载操作
