# Analyze - 磁盘分析功能

## 功能概述

交互式可视化磁盘空间使用情况，帮助用户快速定位大文件和目录，支持直接删除、打开和在Finder中显示。

## 核心价值

- **可视化**：直观的条形图显示空间占用
- **交互式**：支持导航、删除、打开等操作
- **高性能**：Go语言实现，并发扫描
- **智能缓存**：减少重复扫描时间

## 技术实现

### 编程语言
Go语言 + Bubble Tea TUI框架

### 核心数据结构
```go
type dirEntry struct {
    Name       string        // 文件/目录名
    Path       string        // 完整路径
    Size       int64         // 大小（字节）
    IsDir      bool          // 是否为目录
    LastAccess time.Time     // 最后访问时间
}

type model struct {
    path                 string                    // 当前路径
    history              []historyEntry            // 导航历史
    entries              []dirEntry                // 当前目录条目
    largeFiles           []fileEntry               // 大文件列表
    selected             int                       // 选中索引
    offset               int                       // 滚动偏移
    status               string                    // 状态信息
    totalSize            int64                     // 总大小
    scanning             bool                      // 是否正在扫描
    multiSelected        map[string]bool           // 多选状态
    cache                map[string]historyEntry   // 内存缓存
    overviewSizeCache    map[string]int64          // 概览缓存
}
```

## 功能特性

### 1. 概览模式

默认显示主要目录的空间占用：

```
Analyze Disk  Overview  |  Total: 460GB

 ▶  1. ███████████████████  48.2%  |  📁 Home                       221.8GB
    2. ██████████░░░░░░░░░  22.1%  |  📁 App Library                101.7GB
    3. ████░░░░░░░░░░░░░░░  14.3%  |  📁 Applications                65.8GB
    4. ███░░░░░░░░░░░░░░░░  10.8%  |  📁 System Library              49.7GB
    5. ██░░░░░░░░░░░░░░░░░   4.6%  |  📁 Other                       21.0GB
```

**扫描目录**：
- `$HOME` - 用户主目录
- `~/Library` - 应用库
- `/Applications` - 应用程序
- `/Library` - 系统库
- 其他根目录

**特性**：
- 跳过外部卷（`/Volumes`）
- 使用缓存加速
- 并行扫描

### 2. 详细扫描

进入任意目录查看详细内容：

```
Analyze Disk  ~/Documents  |  Total: 156.8GB

 ▶  1. ███████████████████  48.2%  |  📁 Library                     75.4GB  >6mo
    2. ██████████░░░░░░░░░  22.1%  |  📁 Downloads                   34.6GB
    3. ████░░░░░░░░░░░░░░░  14.3%  |  📁 Movies                      22.4GB
    4. ███░░░░░░░░░░░░░░░░  10.8%  |  📁 Documents                   16.9GB
    5. ██░░░░░░░░░░░░░░░░░   5.2%  |  📄 backup_2023.zip              8.2GB

  ↑↓←→ Navigate  |  O Open  |  F Show  |  ⌫ Delete  |  L Large files  |  Q Quit
```

**显示信息**：
- 条形图：空间占用比例
- 百分比：占当前目录的比例
- 图标：📁目录 / 📄文件
- 大小：人类可读格式
- 时间标记：>6mo（超过6个月未访问）

### 3. 大文件检测

自动检测大于100MB的文件：

```
Large Files  ~/  |  Total: 45.2GB

 ▶  1. 📄 VirtualBox.dmg                    4.2GB  ~/Downloads
    2. 📄 Xcode_14.3.dmg                    8.1GB  ~/Downloads
    3. 📄 movie.mp4                         2.8GB  ~/Movies
    4. 📄 backup.tar.gz                     6.5GB  ~/Documents
    5. 📄 dataset.csv                       3.2GB  ~/Projects/ML
```

**特性**：
- 使用最小堆维护Top N
- 并发扫描
- 显示完整路径

### 4. 并发扫描

**Worker Pool模式**：
```go
numWorkers := max(runtime.NumCPU()*2, 4)
```

**特性**：
- 根据CPU核心数动态调整
- 最少4个worker
- 最多CPU核心数×2

**性能**：
- 扫描速度：~1GB/秒
- 内存占用：~50MB
- CPU占用：~50%

### 5. 缓存系统

**内存缓存**：
- 存储最近访问的目录
- LRU淘汰策略
- 最多缓存100个目录

**磁盘缓存**：
- 位置：`~/.cache/mole/analyze_[hash]`
- 格式：JSON
- TTL：24小时

**Stale Cache**：
- 如果扫描超时，使用旧缓存
- 显示"(cached)"标记
- 后台更新缓存

**概览缓存**：
- 位置：`~/.cache/mole/overview_[hash]`
- 存储概览模式的大小
- 加速启动

## 交互操作

### 导航
- `↑/k`：上移
- `↓/j`：下移
- `→/l/Enter`：进入目录
- `←/h/Backspace`：返回上级
- `Home`：跳到顶部
- `End`：跳到底部
- `PgUp`：上翻页
- `PgDn`：下翻页

### 操作
- `Space`：多选/取消选择
- `Delete/⌫`：删除（需二次确认）
- `O`：用默认应用打开
- `F`：在Finder中显示
- `L`：切换大文件视图
- `R`：刷新当前目录
- `Q/Esc`：退出

### 删除机制

**两步确认**：
1. 第一次按Delete：标记为待删除
2. 第二次按Enter：确认删除

**删除方式**：
- 移至垃圾箱（使用Finder API）
- 支持多文件删除
- 显示删除进度

**安全保护**：
- 不删除系统目录
- 不删除根目录
- 验证路径合法性

## 使用方式

### 基础用法
```bash
mo analyze                  # 分析主目录（概览模式）
mo analyze /path/to/dir     # 分析指定目录
mo analyze /Volumes         # 分析外部驱动器
```

### 环境变量
```bash
MO_ANALYZE_PATH=/path       # 指定分析路径
```

## 性能优化

### 扫描优化
- 并发扫描：充分利用多核CPU
- 智能跳过：跳过网络卷和慢速设备
- 超时保护：防止卡在慢速设备
- 增量扫描：只扫描变化的目录

### 内存优化
- 流式处理：不加载所有文件到内存
- 最小堆：只保留Top N大文件
- 缓存淘汰：LRU策略

### UI优化
- 虚拟滚动：只渲染可见区域
- 增量渲染：只更新变化的部分
- 防抖动：限制刷新频率

## 常见问题

### Q: 为什么扫描很慢？
A: 可能是：
1. 目录包含大量文件
2. 网络卷或慢速设备
3. 磁盘I/O繁忙

解决方法：
- 使用缓存
- 跳过慢速设备
- 等待后台扫描完成

### Q: 为什么大小不准确？
A: 可能是：
1. 使用了缓存
2. 文件正在变化
3. 权限不足

解决方法：
- 按R刷新
- 使用sudo运行
- 等待扫描完成

### Q: 删除后空间没有释放？
A: 文件在垃圾箱中，需要清空垃圾箱。

### Q: 为什么有些目录进不去？
A: 权限不足，需要sudo运行。

## Mac应用开发建议

### UI设计

1. **主界面**
   - 使用原生NSOutlineView显示目录树
   - 使用NSProgressIndicator显示条形图
   - 使用NSTableView显示文件列表
   - 支持拖拽排序

2. **概览界面**
   - 使用饼图显示空间分布
   - 使用树状图（Treemap）显示层级
   - 支持点击进入详细视图

3. **大文件界面**
   - 使用NSTableView显示列表
   - 支持排序（按大小、名称、时间）
   - 支持搜索过滤

4. **扫描进度界面**
   - 显示扫描进度条
   - 显示当前扫描的路径
   - 显示已扫描的文件数
   - 支持取消扫描

### 功能增强

1. **可视化增强**
   - 饼图：显示空间分布
   - 树状图：显示目录层级
   - 时间线：显示文件创建时间分布
   - 类型分布：显示文件类型占比

2. **智能分析**
   - 重复文件检测
   - 大文件推荐删除
   - 旧文件推荐归档
   - 空目录检测

3. **批量操作**
   - 批量删除
   - 批量移动
   - 批量压缩
   - 批量导出

4. **搜索功能**
   - 按名称搜索
   - 按大小搜索
   - 按时间搜索
   - 按类型搜索

5. **导出功能**
   - 导出报告（PDF/HTML）
   - 导出文件列表（CSV）
   - 导出空间分布图

### 技术实现

1. **扫描引擎**
   - 使用DispatchQueue并发扫描
   - 使用FileManager枚举文件
   - 使用URLResourceKey获取属性
   - 使用NSCache缓存结果

2. **可视化**
   - 使用Core Graphics绘制图表
   - 使用Core Animation实现动画
   - 使用Metal加速渲染（可选）

3. **性能优化**
   - 使用虚拟滚动
   - 使用增量更新
   - 使用后台线程扫描
   - 使用缓存减少重复扫描

4. **用户体验**
   - 使用NSProgressIndicator显示进度
   - 使用NSAlert确认删除
   - 使用NSWorkspace打开文件
   - 使用NSWorkspace在Finder中显示

### 参考实现

类似应用：
- DaisyDisk：优秀的可视化设计
- GrandPerspective：开源实现
- Disk Inventory X：经典设计
- OmniDiskSweeper：简洁实用

### 开发建议

1. **先实现核心功能**：扫描、显示、删除
2. **再优化性能**：并发、缓存、增量更新
3. **最后增强体验**：可视化、动画、交互

4. **注意事项**：
   - 权限管理：使用沙箱或请求完全磁盘访问权限
   - 性能优化：大目录扫描可能很慢
   - 内存管理：避免加载所有文件到内存
   - 错误处理：处理权限不足、磁盘错误等
