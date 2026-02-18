# Purge - 项目清理功能

## 功能概述

扫描开发项目目录，查找并清理构建产物和依赖缓存，如 `node_modules`、`target`、`build`、`dist` 等，快速回收大量磁盘空间。

## 核心价值

- **空间回收**：单个项目可回收 500MB-5GB
- **智能识别**：自动识别各种项目类型
- **安全保护**：保护最近使用的项目
- **自定义路径**：支持配置扫描目录

## 支持的项目类型

### 1. Node.js / JavaScript
**清理目标**：
- `node_modules/` - npm/yarn/pnpm依赖
- `.next/` - Next.js构建产物
- `.nuxt/` - Nuxt.js构建产物
- `dist/` - 构建输出
- `build/` - 构建输出
- `.cache/` - 缓存目录

**典型大小**：500MB - 2GB

### 2. Rust
**清理目标**：
- `target/` - Cargo构建产物

**典型大小**：1GB - 5GB

### 3. Python
**清理目标**：
- `venv/` - 虚拟环境
- `.venv/` - 虚拟环境
- `__pycache__/` - Python缓存
- `.pytest_cache/` - pytest缓存
- `.mypy_cache/` - mypy缓存

**典型大小**：100MB - 1GB

### 4. Java / Kotlin
**清理目标**：
- `build/` - Gradle构建产物
- `target/` - Maven构建产物
- `.gradle/` - Gradle缓存

**典型大小**：500MB - 2GB

### 5. Go
**清理目标**：
- `vendor/` - Go依赖

**典型大小**：100MB - 500MB

### 6. Ruby
**清理目标**：
- `vendor/bundle/` - Bundler依赖

**典型大小**：100MB - 500MB

### 7. Flutter / Dart
**清理目标**：
- `build/` - Flutter构建产物
- `.dart_tool/` - Dart工具缓存

**典型大小**：500MB - 2GB

### 8. Xcode / iOS
**清理目标**：
- `DerivedData/` - Xcode构建产物
- `build/` - 构建输出
- `Pods/` - CocoaPods依赖

**典型大小**：1GB - 10GB

### 9. Android
**清理目标**：
- `build/` - Gradle构建产物
- `.gradle/` - Gradle缓存

**典型大小**：500MB - 2GB

## 使用方式

### 基础用法
```bash
mo purge                    # 扫描并清理项目
mo purge --paths            # 配置扫描路径
```

### 交互界面
```
Select Categories to Clean - 18.5GB (8 selected)

➤ ● my-react-app       3.2GB | node_modules
  ● old-project        2.8GB | node_modules
  ● rust-app           4.1GB | target
  ● next-blog          1.9GB | node_modules
  ○ current-work       856MB | node_modules  | Recent
  ● django-api         2.3GB | venv
  ● vue-dashboard      1.7GB | node_modules
  ● backend-service    2.5GB | node_modules
```

**显示信息**：
- 项目名称
- 可回收空间
- 清理目标类型
- Recent标记（7天内修改）

### 自定义扫描路径

**配置文件**：`~/.config/mole/purge_paths`

**格式**：
```
~/Documents/MyProjects
~/Work/ClientA
~/Work/ClientB
/Volumes/External/Projects
```

**特性**：
- 一行一个路径
- 支持 `~` 和 `$HOME` 展开
- 支持绝对路径和相对路径
- 空行和 `#` 开头的行会被忽略

**默认扫描路径**（无配置时）：
```
~/Projects
~/GitHub
~/dev
~/Development
~/Code
~/Workspace
~/Documents/Projects
~/Documents/GitHub
~/Documents/dev
~/Library/Developer/Xcode/DerivedData
~/Library/Developer/Xcode/Archives
~/.gradle/caches
~/.m2/repository
```

## 安全机制

### 最近项目保护
- **保护期**：7天
- **判断依据**：最后修改时间
- **标记**：显示"Recent"标签
- **默认状态**：取消选中

### 确认机制
- 显示将要删除的项目数量
- 显示将要回收的空间
- 需要用户明确确认

### 路径验证
- 验证路径存在
- 验证路径可读
- 验证路径不是系统目录

## 扫描流程

1. **读取配置**
   - 读取自定义路径
   - 使用默认路径（如果无配置）

2. **扫描项目**
   - 递归扫描目录
   - 识别项目类型
   - 计算可回收空间
   - 检查最后修改时间

3. **显示结果**
   - 按大小排序
   - 标记最近项目
   - 显示总可回收空间

4. **用户选择**
   - 支持多选
   - 支持全选/反选
   - 默认选中非最近项目

5. **执行清理**
   - 按顺序删除
   - 显示进度
   - 记录日志

6. **显示结果**
   - 显示清理结果
   - 显示回收空间

## 性能优化

### 并发扫描
- 最多15个并行任务
- 按目录并行扫描
- 智能任务调度

### 快速计算
- 使用 `du -sk` 快速计算大小
- 缓存计算结果
- 跳过符号链接

### 智能跳过
- 跳过隐藏目录（`.git`等）
- 跳过网络卷
- 跳过慢速设备

## 日志记录

位置：`~/.config/mole/operations.log`

格式：
```
[timestamp] [purge] [delete] [path] [size]
```

## 常见问题

### Q: 删除后项目还能运行吗？
A: 需要重新安装依赖：
- Node.js: `npm install` / `yarn install`
- Rust: `cargo build`
- Python: `pip install -r requirements.txt`

### Q: 会删除源代码吗？
A: 不会。只删除构建产物和依赖，不删除源代码。

### Q: 为什么有些项目找不到？
A: 可能是：
1. 项目不在扫描路径中
2. 项目类型不支持
3. 项目没有构建产物

解决方法：
- 使用 `mo purge --paths` 添加扫描路径

### Q: 可以恢复吗？
A: 不能。删除是永久的，但可以重新安装依赖。

## Mac应用开发建议

### UI设计

1. **扫描界面**
   - 显示扫描进度
   - 显示当前扫描的路径
   - 显示已找到的项目数
   - 支持取消扫描

2. **项目列表界面**
   - 使用NSTableView显示项目列表
   - 显示项目图标（根据类型）
   - 显示项目大小和类型
   - 支持排序（按大小、名称、时间）
   - 支持搜索过滤

3. **清理进度界面**
   - 显示清理进度
   - 显示当前操作
   - 显示已回收空间

4. **结果界面**
   - 显示清理结果
   - 显示回收空间
   - 支持查看日志

### 功能增强

1. **智能推荐**
   - 推荐长期未使用的项目
   - 推荐大型项目
   - 推荐重复项目

2. **定时清理**
   - 支持定期自动清理
   - 支持设置清理规则
   - 支持通知提醒

3. **项目分组**
   - 按类型分组
   - 按大小分组
   - 按时间分组

4. **统计分析**
   - 显示项目类型分布
   - 显示空间占用趋势
   - 显示清理历史

5. **自定义规则**
   - 支持自定义清理目标
   - 支持自定义保护规则
   - 支持自定义扫描路径

### 技术实现

1. **项目识别**
   - 使用FileManager枚举文件
   - 检查特征文件（package.json, Cargo.toml等）
   - 识别项目类型

2. **大小计算**
   - 使用FileManager计算目录大小
   - 使用DispatchQueue并发计算
   - 使用NSCache缓存结果

3. **文件删除**
   - 使用FileManager删除文件
   - 使用NSFileManager移至垃圾箱（可选）
   - 使用DispatchQueue后台删除

4. **配置管理**
   - 使用UserDefaults存储配置
   - 使用PropertyListSerialization读写配置文件

### 用户体验优化

1. **快速扫描**
   - 使用缓存加速扫描
   - 使用并发加速计算
   - 显示实时进度

2. **智能选择**
   - 默认选中旧项目
   - 默认不选中最近项目
   - 支持一键全选

3. **安全提示**
   - 提示将要删除的内容
   - 提示如何恢复
   - 提示风险级别

4. **通知反馈**
   - 清理完成后发送通知
   - 显示回收空间
   - 提供撤销选项（如果使用垃圾箱）

### 参考实现

类似功能：
- DevCleaner：专门清理Xcode
- Disk Cleaner：通用清理工具
- 手动清理：`rm -rf node_modules`

### 开发建议

1. **先实现核心功能**：扫描、识别、删除
2. **再优化性能**：并发、缓存
3. **最后增强体验**：智能推荐、统计分析

4. **注意事项**：
   - 权限管理：某些目录可能需要特殊权限
   - 错误处理：处理删除失败的情况
   - 用户确认：删除前必须确认
   - 日志记录：记录所有操作
