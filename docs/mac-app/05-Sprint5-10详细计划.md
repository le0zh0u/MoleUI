# Sprint 5-11 详细计划

**优先级调整说明**：根据用户需求，Sprint 5 改为 Purge（项目清理）功能，这是开发者最常用的功能。

## Sprint 5: Purge 项目清理功能（1周）⭐

详细计划已在 [04-迭代开发计划.md](04-迭代开发计划.md) 的 Sprint 5 部分。

**核心价值**：
- 开发者高频使用
- 快速回收大量空间（10-50GB）
- 技术复用 Sprint 1-2 的能力

---

## Sprint 6: Analyze 磁盘分析功能（2周）

### 目标
实现交互式磁盘空间分析和可视化。

### 任务清单

#### Week 1: 扫描和数据结构

**1. DiskEntry 模型**
- [ ] 创建 `DiskEntry` 模型
- [ ] 支持树形结构（parent/children）
- [ ] 计算目录大小（递归）
- [ ] 缓存计算结果

**2. DiskScanner 服务**
- [ ] 实现目录扫描
- [ ] 并发扫描优化
- [ ] 大文件检测（>100MB）
- [ ] 进度报告

**3. 缓存系统**
- [ ] 内存缓存（NSCache）
- [ ] 磁盘缓存（JSON）
- [ ] 缓存失效策略

**技术要点**：
```swift
// DiskEntry.swift
class DiskEntry: Identifiable, ObservableObject {
    let id: UUID
    let name: String
    let path: String
    @Published var size: Int64
    let isDirectory: Bool
    let lastAccess: Date
    weak var parent: DiskEntry?
    @Published var children: [DiskEntry]?

    // 计算目录大小
    func calculateSize() async -> Int64 {
        if !isDirectory {
            return size
        }

        guard let children = children else {
            return 0
        }

        var total: Int64 = 0
        for child in children {
            total += await child.calculateSize()
        }

        await MainActor.run {
            self.size = total
        }

        return total
    }
}

// DiskScanner.swift
class DiskScanner {
    private let cache = NSCache<NSString, DiskEntry>()

    func scanDirectory(at path: String) async throws -> DiskEntry {
        // 检查缓存
        if let cached = cache.object(forKey: path as NSString) {
            return cached
        }

        let url = URL(fileURLWithPath: path)
        let entry = DiskEntry(url: url)

        // 扫描子目录
        if entry.isDirectory {
            let contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)

            await withTaskGroup(of: DiskEntry?.self) { group in
                for childURL in contents {
                    group.addTask {
                        try? await self.scanDirectory(at: childURL.path)
                    }
                }

                var children: [DiskEntry] = []
                for await child in group {
                    if let child = child {
                        child.parent = entry
                        children.append(child)
                    }
                }

                entry.children = children.sorted { $0.size > $1.size }
            }
        }

        // 缓存结果
        cache.setObject(entry, forKey: path as NSString)

        return entry
    }
}
```

#### Week 2: UI 和可视化

**1. AnalyzeViewModel**
- [ ] 当前路径管理
- [ ] 导航历史
- [ ] 选中状态管理
- [ ] 排序和过滤

**2. 树状视图**
- [ ] 目录树显示
- [ ] 展开/折叠
- [ ] 大小条形图
- [ ] 百分比显示

**3. 饼图视图**
- [ ] 使用 Charts 框架
- [ ] 交互式选择
- [ ] 颜色编码

**4. 大文件列表**
- [ ] Top N 大文件
- [ ] 排序功能
- [ ] 快速定位

**5. 交互操作**
- [ ] 双击进入目录
- [ ] 右键菜单（打开、删除、在 Finder 显示）
- [ ] 键盘快捷键

### 验收标准
- ✓ 能够扫描任意目录
- ✓ 正确计算目录大小
- ✓ 树状图和饼图正常显示
- ✓ 能够导航和交互
- ✓ 扫描速度 >500MB/秒

---

## Sprint 6: Status 系统监控功能（2周）

### 目标
实现实时系统性能监控仪表板。

### 任务清单

#### Week 1: 数据采集

**1. SystemMetrics 模型**
- [ ] CPU 指标
- [ ] 内存指标
- [ ] 磁盘指标
- [ ] 网络指标
- [ ] 电池指标

**2. MetricsCollector 服务**
- [ ] CPU 使用率（使用 host_statistics）
- [ ] 内存使用（使用 vm_statistics64）
- [ ] 磁盘 I/O（使用 IOKit）
- [ ] 网络流量（使用 SystemConfiguration）
- [ ] 电池状态（使用 IOKit）

**技术要点**：
```swift
// CPUMetrics.swift
struct CPUMetrics {
    let usage: Double
    let loadAverage: (Double, Double, Double)
    let coreUsages: [Double]
}

class CPUCollector {
    func collect() -> CPUMetrics {
        var size = MemoryLayout<host_cpu_load_info>.size
        var count = mach_msg_type_number_t(size / MemoryLayout<integer_t>.size)
        var hostInfo = host_cpu_load_info()

        let result = withUnsafeMutablePointer(to: &hostInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &count)
            }
        }

        guard result == KERN_SUCCESS else {
            return CPUMetrics(usage: 0, loadAverage: (0, 0, 0), coreUsages: [])
        }

        let user = Double(hostInfo.cpu_ticks.0)
        let system = Double(hostInfo.cpu_ticks.1)
        let idle = Double(hostInfo.cpu_ticks.2)
        let nice = Double(hostInfo.cpu_ticks.3)

        let total = user + system + idle + nice
        let usage = (user + system + nice) / total * 100

        return CPUMetrics(
            usage: usage,
            loadAverage: getLoadAverage(),
            coreUsages: getCoreUsages()
        )
    }

    private func getLoadAverage() -> (Double, Double, Double) {
        var loadavg = [Double](repeating: 0, count: 3)
        getloadavg(&loadavg, 3)
        return (loadavg[0], loadavg[1], loadavg[2])
    }
}

// MemoryCollector.swift
class MemoryCollector {
    func collect() -> MemoryMetrics {
        var vmStats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)

        let result = withUnsafeMutablePointer(to: &vmStats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }

        guard result == KERN_SUCCESS else {
            return MemoryMetrics(used: 0, total: 0, free: 0)
        }

        let pageSize = vm_kernel_page_size
        let free = Int64(vmStats.free_count) * Int64(pageSize)
        let active = Int64(vmStats.active_count) * Int64(pageSize)
        let inactive = Int64(vmStats.inactive_count) * Int64(pageSize)
        let wired = Int64(vmStats.wire_count) * Int64(pageSize)

        let used = active + inactive + wired
        let total = used + free

        return MemoryMetrics(used: used, total: total, free: free)
    }
}
```

**3. 健康评分算法**
- [ ] CPU 负载评分
- [ ] 内存使用评分
- [ ] 磁盘空间评分
- [ ] 综合评分计算

#### Week 2: UI 和图表

**1. StatusViewModel**
- [ ] 定时采集（1秒间隔）
- [ ] 历史数据管理（保留60秒）
- [ ] 数据流管理

**2. 仪表板 UI**
- [ ] CPU 使用率图表
- [ ] 内存使用图表
- [ ] 磁盘 I/O 图表
- [ ] 网络流量图表
- [ ] 健康评分显示

**3. 图表实现**
- [ ] 使用 Charts 框架
- [ ] 实时更新动画
- [ ] 颜色编码（绿/黄/红）

**4. 菜单栏集成（可选）**
- [ ] 菜单栏图标
- [ ] 快速查看
- [ ] 点击打开主窗口

### 验收标准
- ✓ 所有指标正确采集
- ✓ 1秒刷新无卡顿
- ✓ 图表流畅显示
- ✓ 健康评分准确
- ✓ CPU 占用 <5%

---

## Sprint 7: Optimize 系统优化功能（1周）

### 目标
实现系统优化和维护功能。

### 任务清单

**1. OptimizeService**
- [ ] 系统检查（更新、安全、配置）
- [ ] 优化操作（重建索引、清理缓存）
- [ ] 使用 Process 执行命令

**2. 优化项实现**
- [ ] 重建启动服务数据库
- [ ] 重建 Spotlight 索引
- [ ] 清理 DNS 缓存
- [ ] 清理字体缓存
- [ ] 优化数据库（Mail, Safari）

**技术要点**：
```swift
// OptimizeService.swift
class OptimizeService {
    func rebuildLaunchServices() async throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister")
        process.arguments = ["-kill", "-r", "-domain", "local", "-domain", "system", "-domain", "user"]

        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            throw OptimizeError.commandFailed
        }
    }

    func flushDNSCache() async throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/dscacheutil")
        process.arguments = ["-flushcache"]

        try process.run()
        process.waitUntilExit()
    }
}
```

**3. OptimizeViewModel 和 UI**
- [ ] 检查结果显示
- [ ] 优化建议列表
- [ ] 一键优化
- [ ] 进度显示

### 验收标准
- ✓ 所有优化项正常工作
- ✓ 错误处理完善
- ✓ 进度显示准确
- ✓ 操作可撤销（部分）

---

## Sprint 8: Purge & Installer 功能（1周）

### 目标
实现项目清理和安装包清理功能。

### 任务清单

**1. PurgeService**
- [ ] 扫描项目目录
- [ ] 识别项目类型（node_modules, target, build 等）
- [ ] 计算可清理空间
- [ ] 执行清理

**2. InstallerService**
- [ ] 扫描安装包文件（.dmg, .pkg, .zip）
- [ ] 检查 ZIP 内容
- [ ] 标记源位置
- [ ] 执行删除

**3. UI 实现**
- [ ] 项目列表
- [ ] 安装包列表
- [ ] 批量选择
- [ ] 清理进度

### 验收标准
- ✓ 正确识别项目类型
- ✓ 正确识别安装包
- ✓ 清理功能正常
- ✓ 保护最近项目（7天）

---

## Sprint 9: UI 优化和完善（2周）

### 目标
优化用户体验，完善所有功能。

### 任务清单

#### Week 1: UI 优化

**1. 动画效果**
- [ ] 页面切换动画
- [ ] 列表加载动画
- [ ] 进度条动画
- [ ] 删除动画

**2. 交互优化**
- [ ] 键盘快捷键
- [ ] 拖拽支持
- [ ] 右键菜单
- [ ] 工具提示

**3. 主题支持**
- [ ] 深色模式
- [ ] 浅色模式
- [ ] 自动切换

**4. 响应式布局**
- [ ] 窗口大小适配
- [ ] 最小尺寸限制
- [ ] 布局优化

#### Week 2: 功能完善

**1. 设置界面**
- [ ] 通用设置
- [ ] 清理设置
- [ ] 白名单管理
- [ ] 关于页面

**2. 帮助系统**
- [ ] 功能说明
- [ ] 快捷键列表
- [ ] 常见问题

**3. 通知系统**
- [ ] 操作完成通知
- [ ] 错误通知
- [ ] 进度通知

**4. 日志查看器**
- [ ] 操作日志显示
- [ ] 日志过滤
- [ ] 日志导出

### 验收标准
- ✓ 所有动画流畅
- ✓ 交互响应快速
- ✓ 主题切换正常
- ✓ 设置功能完整

---

## Sprint 10: 测试和发布准备（2周）

### 目标
完成测试，准备发布。

### 任务清单

#### Week 1: 测试

**1. 单元测试**
- [ ] Service 层测试
- [ ] ViewModel 测试
- [ ] 工具类测试
- [ ] 覆盖率 >70%

**2. UI 测试**
- [ ] 关键流程测试
- [ ] 边界情况测试
- [ ] 错误处理测试

**3. 性能测试**
- [ ] 扫描性能测试
- [ ] 内存泄漏检测
- [ ] CPU 占用测试
- [ ] 启动时间测试

**4. 兼容性测试**
- [ ] macOS 13 测试
- [ ] macOS 14 测试
- [ ] macOS 15 测试
- [ ] Intel 和 Apple Silicon

#### Week 2: 发布准备

**1. 代码优化**
- [ ] 代码审查
- [ ] 重构优化
- [ ] 注释完善
- [ ] 文档更新

**2. 打包和签名**
- [ ] 配置签名证书
- [ ] 创建 DMG
- [ ] 公证（Notarization）
- [ ] 装订（Stapling）

**3. 发布材料**
- [ ] 应用图标
- [ ] 截图
- [ ] 宣传视频
- [ ] 发布说明

**4. 分发准备**
- [ ] GitHub Release
- [ ] Homebrew Cask
- [ ] 官网更新

### 验收标准
- ✓ 所有测试通过
- ✓ 无严重 Bug
- ✓ 性能达标
- ✓ 可以正常安装和运行

---

## 总结

### 时间线
- Sprint 0-4: 基础功能（7周）
- Sprint 5-8: 高级功能（6周）
- Sprint 9-10: 优化和发布（4周）
- **总计**: 17周（约4个月）

### 里程碑
1. **M1 (Week 3)**: 基础架构完成
2. **M2 (Week 7)**: Clean 功能完成
3. **M3 (Week 11)**: 核心功能完成
4. **M4 (Week 15)**: 所有功能完成
5. **M5 (Week 17)**: 发布就绪

### 资源需求
- **开发人员**: 1-2人
- **设计师**: 0.5人（兼职）
- **测试人员**: 0.5人（兼职）

### 风险缓解
- 每周代码审查
- 持续集成
- 定期演示
- 及时调整计划

准备好开始开发了吗？🚀
