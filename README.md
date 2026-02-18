# MoleUI

Native macOS application for system cleaning and optimization.

## 🎯 Project Overview

MoleUI is a **completely independent Swift native application** that provides powerful system cleaning and optimization features for macOS. It does not depend on Mole CLI and implements all functionality using macOS native APIs.

## ✨ Features

- **Clean**: Deep clean your Mac (Coming in Sprint 3)
- **Uninstall**: Remove apps completely (Coming in Sprint 4)
- **Purge**: Clean project artifacts (Coming in Sprint 5) ⭐ Priority
- **Analyze**: Analyze disk usage (Coming in Sprint 6)
- **Status**: Monitor system health (Coming in Sprint 7)
- **Optimize**: Optimize system performance (Coming in Sprint 8)
- **Installer**: Remove installer files (Coming in Sprint 9)

## 📋 Requirements

- macOS 13.0+
- Xcode 15.0+
- Swift 5.9+

## 🚀 Development

### Setup

1. Clone the repository
   ```bash
   cd /Users/zhouchunjie/WorkSpace/sources/Mole
   open MoleUI/MoleUI.xcodeproj
   ```

2. Build and run in Xcode (⌘R)

### Project Structure

```
MoleUI/
├── App/                    # Application entry point
│   ├── MoleUIApp.swift    # Main app structure
│   └── AppDelegate.swift  # App delegate
├── Views/                 # SwiftUI views
│   ├── MainView.swift    # Main navigation view
│   ├── Common/           # Common views (Sidebar, Detail)
│   ├── Clean/            # Clean module views
│   ├── Uninstall/        # Uninstall module views
│   ├── Optimize/         # Optimize module views
│   ├── Analyze/          # Analyze module views
│   ├── Status/           # Status module views
│   ├── Purge/            # Purge module views
│   └── Installer/        # Installer module views
├── ViewModels/           # View models (MVVM)
├── Models/               # Data models
│   └── Tab.swift        # Tab enumeration
├── Services/             # Business logic
├── Core/                 # Utilities and extensions
│   ├── Extensions/
│   └── Utils/
└── Resources/            # Assets and resources
```

## 📅 Development Timeline

### Current Sprint: Sprint 0 - Project Setup (Week 1) ✅

**Status**: Completed

**Achievements**:
- ✅ Created complete project structure
- ✅ Implemented MVVM architecture foundation
- ✅ Created navigation framework with 7 module placeholders
- ✅ Configured development tools (SwiftLint, Git)

### Upcoming Sprints

- **Sprint 1-2**: File scanning and deletion foundation (Weeks 2-5)
- **Sprint 3**: Clean core functionality (Weeks 6-7)
- **Sprint 4**: Uninstall functionality (Weeks 8-9)
- **Sprint 5**: **Purge project cleaning** (Week 10) ⭐
- **Sprint 6-11**: Additional features and polish

**Total Estimated Time**: ~18 weeks (4.5 months)

## 🏗 Architecture

MoleUI follows the **MVVM (Model-View-ViewModel)** architecture:

- **Models**: Data structures and business entities
- **Views**: SwiftUI views for UI presentation
- **ViewModels**: Business logic and state management
- **Services**: Core functionality (file scanning, system operations)

### Key Technologies

- **SwiftUI**: Modern declarative UI framework
- **Async/Await**: Asynchronous operations
- **FileManager**: File system operations
- **NSWorkspace**: Application management
- **IOKit**: Hardware information
- **Process**: System command execution

## 🛠 Development Tools

- **SwiftLint**: Code style and quality (optional but recommended)
  ```bash
  brew install swiftlint
  ```

- **Git**: Version control
- **Xcode**: IDE and build system

## 📖 Documentation

Comprehensive development documentation is available in the `docs/` directory:

- [START_HERE.md](docs/mac-app/START_HERE.md) - Development startup guide
- [00-架构说明.md](docs/mac-app/00-架构说明.md) - Architecture explanation
- [04-迭代开发计划.md](docs/mac-app/04-迭代开发计划.md) - Iteration development plan
- [06-Sprint0快速开始.md](docs/mac-app/06-Sprint0快速开始.md) - Sprint 0 quick start guide

## 🤝 Contributing

This is currently a personal development project. Contributions, issues, and feature requests are welcome!

## 📝 License

MIT License

---

**Built with ❤️ using Swift and SwiftUI**

*Sprint 0 completed on 2026-02-18*
