# Sprint 0 快速开始指南

## 🎯 本周目标

搭建 MoleUI 项目基础架构，为后续开发做好准备。

**预计时间**: 1周
**交付物**: 可运行的空壳应用

---

## 📋 Day 1: 项目创建

### 1. 创建 Xcode 项目

**步骤**：
1. 打开 Xcode
2. File → New → Project
3. 选择 macOS → App
4. 配置项目：
   - Product Name: `MoleUI`
   - Team: 选择你的开发团队
   - Organization Identifier: `com.mole`
   - Bundle Identifier: `com.mole.MoleUI`
   - Interface: SwiftUI
   - Language: Swift
   - Storage: None
   - 取消勾选 "Include Tests"（稍后手动添加）

5. 选择保存位置：`/Users/zhouchunjie/WorkSpace/sources/Mole/MoleUI/`

### 2. 配置项目设置

**General 标签**：
- Deployment Target: macOS 13.0
- Supports: Mac (Designed for iPad 取消勾选)

**Signing & Capabilities**：
- Automatically manage signing: 勾选
- Team: 选择你的团队

**Build Settings**：
- Swift Language Version: Swift 5
- Optimization Level (Debug): No Optimization
- Optimization Level (Release): Optimize for Speed

### 3. 配置 App Icon

1. 在 `Assets.xcassets` 中添加 AppIcon
2. 准备不同尺寸的图标（16x16 到 1024x1024）
3. 拖拽到对应位置

**临时方案**：使用 SF Symbols 的 "sparkles" 图标作为占位符

---

## 📋 Day 2: 项目结构搭建

### 1. 创建目录结构

在 Xcode 中创建以下 Groups（右键 → New Group）：

```
MoleUI/
├── App/
├── Views/
│   ├── Clean/
│   ├── Uninstall/
│   ├── Optimize/
│   ├── Analyze/
│   ├── Status/
│   ├── Purge/
│   ├── Installer/
│   └── Common/
├── ViewModels/
├── Models/
├── Services/
├── Core/
│   ├── Extensions/
│   └── Utils/
└── Resources/
```

### 2. 移动现有文件

- 将 `MoleUIApp.swift` 移到 `App/` 目录
- 将 `ContentView.swift` 重命名为 `MainView.swift` 并移到 `Views/`
- 删除 `Item.swift`（不需要）

### 3. 创建基础文件

**App/AppDelegate.swift**:
```swift
import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 应用启动完成
        print("MoleUI started")
    }

    func applicationWillTerminate(_ notification: Notification) {
        // 应用即将退出
        print("MoleUI will terminate")
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // 关闭最后一个窗口时退出应用
        return true
    }
}
```

**更新 MoleUIApp.swift**:
```swift
import SwiftUI

@main
struct MoleUIApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            MainView()
                .frame(minWidth: 900, minHeight: 600)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            // 自定义菜单
            CommandGroup(replacing: .appInfo) {
                Button("About MoleUI") {
                    // TODO: 显示关于窗口
                }
            }
        }
    }
}
```

---

## 📋 Day 3: 基础 UI 框架

### 1. 创建 Tab 枚举

**Models/Tab.swift**:
```swift
import Foundation

enum Tab: String, CaseIterable, Identifiable {
    case clean = "Clean"
    case uninstall = "Uninstall"
    case optimize = "Optimize"
    case analyze = "Analyze"
    case status = "Status"
    case purge = "Purge"
    case installer = "Installer"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .clean: return "sparkles"
        case .uninstall: return "trash"
        case .optimize: return "gearshape.2"
        case .analyze: return "chart.pie"
        case .status: return "chart.bar"
        case .purge: return "folder.badge.minus"
        case .installer: return "shippingbox"
        }
    }

    var description: String {
        switch self {
        case .clean: return "Deep clean your Mac"
        case .uninstall: return "Remove apps completely"
        case .optimize: return "Optimize system performance"
        case .analyze: return "Analyze disk usage"
        case .status: return "Monitor system health"
        case .purge: return "Clean project artifacts"
        case .installer: return "Remove installer files"
        }
    }
}
```

### 2. 创建侧边栏

**Views/Common/SidebarView.swift**:
```swift
import SwiftUI

struct SidebarView: View {
    @Binding var selection: Tab

    var body: some View {
        List(Tab.allCases, selection: $selection) { tab in
            NavigationLink(value: tab) {
                Label {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(tab.rawValue)
                            .font(.headline)
                        Text(tab.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } icon: {
                    Image(systemName: tab.icon)
                        .font(.title2)
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("MoleUI")
    }
}
```

### 3. 创建详情视图

**Views/Common/DetailView.swift**:
```swift
import SwiftUI

struct DetailView: View {
    let tab: Tab

    var body: some View {
        Group {
            switch tab {
            case .clean:
                CleanPlaceholderView()
            case .uninstall:
                UninstallPlaceholderView()
            case .optimize:
                OptimizePlaceholderView()
            case .analyze:
                AnalyzePlaceholderView()
            case .status:
                StatusPlaceholderView()
            case .purge:
                PurgePlaceholderView()
            case .installer:
                InstallerPlaceholderView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// 占位视图
struct CleanPlaceholderView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            Text("Clean")
                .font(.largeTitle)
            Text("Deep clean your Mac")
                .foregroundColor(.secondary)
            Text("Coming soon in Sprint 3")
                .font(.caption)
                .foregroundColor(.orange)
        }
    }
}

// 其他占位视图类似...
```

### 4. 更新主视图

**Views/MainView.swift**:
```swift
import SwiftUI

struct MainView: View {
    @State private var selectedTab: Tab = .clean

    var body: some View {
        NavigationSplitView {
            SidebarView(selection: $selectedTab)
                .frame(minWidth: 200)
        } detail: {
            DetailView(tab: selectedTab)
        }
    }
}

#Preview {
    MainView()
        .frame(width: 900, height: 600)
}
```

---

## 📋 Day 4: 开发工具配置

### 1. 配置 SwiftLint

**安装 SwiftLint**:
```bash
brew install swiftlint
```

**创建 .swiftlint.yml**:
```yaml
# 在项目根目录创建
disabled_rules:
  - trailing_whitespace
  - line_length

opt_in_rules:
  - empty_count
  - empty_string

excluded:
  - Pods
  - .build

line_length:
  warning: 120
  error: 200

identifier_name:
  min_length:
    warning: 2
  max_length:
    warning: 40
    error: 50
```

**添加 Build Phase**:
1. 选择 Target → Build Phases
2. 点击 + → New Run Script Phase
3. 添加脚本：
```bash
if which swiftlint >/dev/null; then
  swiftlint
else
  echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi
```

### 2. 配置 Git

**创建 .gitignore**:
```
# Xcode
*.xcodeproj/*
!*.xcodeproj/project.pbxproj
!*.xcodeproj/xcshareddata/
!*.xcworkspace/contents.xcworkspacedata
/*.gcno
**/xcshareddata/WorkspaceSettings.xcsettings

# Swift Package Manager
.build/
.swiftpm/

# CocoaPods
Pods/

# Carthage
Carthage/Build/

# macOS
.DS_Store

# User-specific
*.xcuserstate
*.xcuserdatad/
```

**初始化 Git**:
```bash
cd /Users/zhouchunjie/WorkSpace/sources/Mole/MoleUI
git init
git add .
git commit -m "Initial commit: Sprint 0 - Project setup"
```

### 3. 创建 README

**MoleUI/README.md**:
```markdown
# MoleUI

Native macOS application for system cleaning and optimization.

## Requirements

- macOS 13.0+
- Xcode 15.0+
- Swift 5.9+

## Development

### Setup

1. Clone the repository
2. Open `MoleUI.xcodeproj` in Xcode
3. Build and run (⌘R)

### Project Structure

- `App/` - Application entry point
- `Views/` - SwiftUI views
- `ViewModels/` - View models (MVVM)
- `Models/` - Data models
- `Services/` - Business logic
- `Core/` - Utilities and extensions

### Current Sprint

Sprint 0: Project Setup (Week 1)

## License

MIT License
```

---

## 📋 Day 5: 测试和完善

### 1. 添加单元测试

**创建测试 Target**:
1. File → New → Target
2. 选择 macOS → Unit Testing Bundle
3. Product Name: `MoleUITests`

**创建第一个测试**:
```swift
// MoleUITests/TabTests.swift
import XCTest
@testable import MoleUI

final class TabTests: XCTestCase {
    func testTabCount() {
        XCTAssertEqual(Tab.allCases.count, 7)
    }

    func testTabIcons() {
        for tab in Tab.allCases {
            XCTAssertFalse(tab.icon.isEmpty)
        }
    }

    func testTabDescriptions() {
        for tab in Tab.allCases {
            XCTAssertFalse(tab.description.isEmpty)
        }
    }
}
```

**运行测试**:
- ⌘U 运行所有测试
- 确保所有测试通过

### 2. 添加 UI 测试（可选）

**创建 UI 测试 Target**:
1. File → New → Target
2. 选择 macOS → UI Testing Bundle
3. Product Name: `MoleUIUITests`

**创建第一个 UI 测试**:
```swift
// MoleUIUITests/MoleUIUITests.swift
import XCTest

final class MoleUIUITests: XCTestCase {
    func testAppLaunches() throws {
        let app = XCUIApplication()
        app.launch()

        // 验证窗口存在
        XCTAssertTrue(app.windows.firstMatch.exists)

        // 验证侧边栏存在
        let sidebar = app.outlines.firstMatch
        XCTAssertTrue(sidebar.exists)
    }

    func testTabNavigation() throws {
        let app = XCUIApplication()
        app.launch()

        // 点击不同的 tab
        let sidebar = app.outlines.firstMatch

        sidebar.staticTexts["Clean"].click()
        XCTAssertTrue(app.staticTexts["Clean"].exists)

        sidebar.staticTexts["Uninstall"].click()
        XCTAssertTrue(app.staticTexts["Uninstall"].exists)
    }
}
```

### 3. 性能测试

**添加性能基准**:
```swift
// MoleUITests/PerformanceTests.swift
import XCTest
@testable import MoleUI

final class PerformanceTests: XCTestCase {
    func testAppLaunchPerformance() {
        measure {
            // 测试应用启动时间
            let app = XCUIApplication()
            app.launch()
        }
    }
}
```

---

## 📋 验收检查清单

### 功能验收
- [ ] 应用能够启动
- [ ] 主窗口正常显示
- [ ] 侧边栏显示所有 7 个功能模块
- [ ] 能够在不同模块间切换
- [ ] 每个模块显示占位视图

### 代码质量
- [ ] 代码结构清晰，符合 MVVM 架构
- [ ] 所有文件都在正确的目录中
- [ ] SwiftLint 无警告
- [ ] 所有测试通过

### 文档
- [ ] README.md 完整
- [ ] .gitignore 配置正确
- [ ] 代码有必要的注释

### Git
- [ ] 初始提交完成
- [ ] 提交信息清晰

---

## 🎉 Sprint 0 完成！

### 下一步

1. **Sprint Review**
   - 演示可运行的应用
   - 展示项目结构
   - 讨论遇到的问题

2. **Sprint Retrospective**
   - 什么做得好？
   - 什么需要改进？
   - 下个 Sprint 的改进点

3. **准备 Sprint 1**
   - 阅读 Sprint 1 计划
   - 准备开发环境
   - 了解文件扫描 API

### 参考资源

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [FileManager Documentation](https://developer.apple.com/documentation/foundation/filemanager)
- [MVVM Pattern](https://www.hackingwithswift.com/books/ios-swiftui/introducing-mvvm-into-your-swiftui-project)

---

**预计完成时间**: 5 个工作日
**实际完成时间**: _____ 天

**遇到的问题**:
-

**解决方案**:
-

**经验教训**:
-

准备好开始 Sprint 1 了吗？🚀
