//
//  CleanConfig.swift
//  MoleUI
//
//  Paths and thresholds extracted from Mole CLI scripts:
//   - lib/core/base.sh          (global constants & whitelist patterns)
//   - lib/clean/user.sh         (user caches, logs, trash)
//   - lib/clean/caches.sh       (browser caches)
//   - lib/clean/dev.sh          (developer tool caches)
//
//  Note: System-level paths that require sudo (e.g. /private/tmp,
//        /Library/Logs/DiagnosticReports) are intentionally excluded.
//        They correspond to Mole's "Deep system" group which requires
//        admin access. MoleUI covers user-owned paths only.
//
//  Created by 周椿杰 on 2026/2/18.
//

import Foundation

// MARK: - Global Constants

/// 清理配置常量
/// 与 Mole CLI `lib/core/base.sh` 中的全局常量对应
enum MoleConstants {
    /// 临时文件保留天数（base.sh: MOLE_TEMP_FILE_AGE_DAYS）
    nonisolated(unsafe) static let tempFileAgeDays: Int = 7

    /// 孤立应用数据保留天数（base.sh: MOLE_ORPHAN_AGE_DAYS）
    nonisolated(unsafe) static let orphanAgeDays: Int = 60

    /// 日志文件保留天数（base.sh: MOLE_LOG_AGE_DAYS）
    nonisolated(unsafe) static let logAgeDays: Int = 7

    /// 崩溃报告保留天数（base.sh: MOLE_CRASH_REPORT_AGE_DAYS）
    nonisolated(unsafe) static let crashReportAgeDays: Int = 7

    /// 邮件附件最小大小（KB）（base.sh: MOLE_MAIL_DOWNLOADS_MIN_KB）
    nonisolated(unsafe) static let mailDownloadsMinKB: Int = 5120

    /// 并行任务上限（base.sh: MOLE_MAX_PARALLEL_JOBS）
    nonisolated(unsafe) static let maxParallelJobs: Int = 15

    /// 单次扫描最大 .DS_Store 文件数（base.sh: MOLE_MAX_DS_STORE_FILES）
    nonisolated(unsafe) static let maxDSStoreFiles: Int = 500
}

// MARK: - Path Configuration

/// 各清理类别的扫描路径配置
/// 路径提取自 Mole CLI lib/clean/ 目录下各模块脚本
/// 所有静态成员标记为 nonisolated，支持从任意 actor 上下文调用
struct CleanConfig {

    // MARK: - Base

    nonisolated static var home: String {
        FileManager.default.homeDirectoryForCurrentUser.path
    }

    // MARK: - User Caches (lib/clean/user.sh: "User app cache")

    /// 用户应用缓存路径
    /// 对应 Mole "User essentials > User app cache"
    nonisolated static var userCachePaths: [String] {
        ["\(home)/Library/Caches"]
    }

    // MARK: - User Logs (lib/clean/user.sh: "User app logs")

    /// 用户日志路径
    /// 对应 Mole "User essentials > User app logs"
    nonisolated static var userLogPaths: [String] {
        ["\(home)/Library/Logs"]
    }

    // MARK: - Trash (lib/clean/user.sh: "Trash")

    /// 废纸篓路径
    /// 对应 Mole "User essentials > Trash"
    nonisolated static var trashPaths: [String] {
        ["\(home)/.Trash"]
    }

    // MARK: - Browser Caches (lib/clean/caches.sh)
    //
    // Bundle ID 来源：Mole lib/clean/caches.sh 中各浏览器缓存路径定义
    // 注意：Edge 的 bundle ID 是 com.microsoft.edgemac，不是 "Microsoft Edge"

    /// 浏览器缓存路径
    /// 对应 Mole "Browsers" 组（user.sh 浏览器旧版本 + caches.sh 缓存清理）
    nonisolated static var browserCachePaths: [String] {
        [
            // Safari（bundle: com.apple.Safari）
            "\(home)/Library/Caches/com.apple.Safari",

            // Google Chrome
            "\(home)/Library/Caches/Google/Chrome",
            "\(home)/Library/Application Support/Google/Chrome/Default/GPUCache",
            "\(home)/Library/Application Support/Google/Chrome/Default/Application Cache",

            // Microsoft Edge（bundle: com.microsoft.edgemac）
            "\(home)/Library/Caches/com.microsoft.edgemac",

            // Firefox（bundle: org.mozilla.firefox）
            "\(home)/Library/Caches/Firefox",
            "\(home)/Library/Application Support/Firefox/Profiles",

            // Arc（bundle: company.thebrowser.Browser）
            "\(home)/Library/Caches/company.thebrowser.Browser",

            // Brave（bundle: com.brave.Browser）
            "\(home)/Library/Caches/BraveSoftware/Brave-Browser",

            // Opera（bundle: com.operasoftware.Opera）
            "\(home)/Library/Caches/com.operasoftware.Opera",
        ]
    }

    /// 浏览器缓存保护域名（对应 Mole PROTECTED_SW_DOMAINS，不清理这些域名的 SW 缓存）
    nonisolated(unsafe) static let browserProtectedDomains: [String] = [
        "capcut.com",
        "photopea.com",
        "pixlr.com"
    ]

    // MARK: - Developer Tool Caches (lib/clean/dev.sh)
    //
    // 路径来源：Mole lib/clean/dev.sh 各工具缓存定义
    // 注意：Python 工具（pip/poetry/uv/ruff）的缓存在 ~/.cache/，不在 ~/Library/Caches/
    // 注意：Go 缓存在 ~/.cache/go-build，不在 ~/Library/Caches/go/

    /// 开发者工具缓存路径
    /// 对应 Mole "Developer tools" + "Development applications" 两组
    nonisolated static var devToolCachePaths: [String] {
        [
            // ── Xcode（最大占用）──────────────────────────────────
            // dev.sh: "Xcode derived data" / "Xcode archives"
            "\(home)/Library/Developer/Xcode/DerivedData",
            "\(home)/Library/Developer/Xcode/Archives",
            "\(home)/Library/Developer/Xcode/Products",
            // dev.sh: "Xcode cache" (Library/Caches，非 DerivedData)
            "\(home)/Library/Caches/com.apple.dt.Xcode",
            // dev.sh: iOS/watchOS/tvOS device support symbol cache
            "\(home)/Library/Developer/Xcode/iOS DeviceSupport",
            "\(home)/Library/Developer/Xcode/watchOS DeviceSupport",
            "\(home)/Library/Developer/Xcode/tvOS DeviceSupport",
            "\(home)/Library/Developer/Xcode/visionOS DeviceSupport",
            // dev.sh: "Simulator cache"
            "\(home)/Library/Developer/CoreSimulator/Caches",

            // ── npm / pnpm / yarn / bun ───────────────────────────
            // dev.sh: npm cache dir
            "\(home)/.npm/_cacache",
            // dev.sh: pnpm orphaned store
            "\(home)/Library/pnpm/store",
            "\(home)/.pnpm-store",
            // dev.sh: yarn cache
            "\(home)/.yarn/cache",
            // dev.sh: bun cache
            "\(home)/.bun/install/cache",

            // ── Python ─────────────────────────────────────────────
            // dev.sh: pip → ~/.cache/pip (macOS: pip 默认缓存在 ~/.cache/pip)
            "\(home)/.cache/pip",
            // dev.sh: poetry → ~/.cache/poetry
            "\(home)/.cache/poetry",
            // dev.sh: uv → ~/.cache/uv
            "\(home)/.cache/uv",
            // dev.sh: ruff → ~/.cache/ruff
            "\(home)/.cache/ruff",
            // dev.sh: mypy → ~/.cache/mypy
            "\(home)/.cache/mypy",
            // dev.sh: pyenv cache
            "\(home)/.pyenv/cache",

            // ── Go ──────────────────────────────────────────────────
            // dev.sh: go clean -cache → ~/.cache/go-build
            "\(home)/.cache/go-build",

            // ── Rust / Cargo ────────────────────────────────────────
            // dev.sh: cargo registry cache / git / rustup downloads
            "\(home)/.cargo/registry/cache",
            "\(home)/.cargo/git",
            "\(home)/.rustup/downloads",

            // ── Ruby / Bundler ──────────────────────────────────────
            // dev.sh: bundler cache
            "\(home)/.bundle/cache",

            // ── CocoaPods ───────────────────────────────────────────
            "\(home)/Library/Caches/CocoaPods",

            // ── Swift Package Manager ────────────────────────────────
            // dev.sh: ~/.cache/swift-package-manager
            "\(home)/.cache/swift-package-manager",

            // ── Frontend build tools ─────────────────────────────────
            // dev.sh: TypeScript / Electron / node-gyp / Turbo / Vite / Webpack / Parcel
            "\(home)/.cache/typescript",
            "\(home)/.cache/electron",
            "\(home)/.cache/node-gyp",
            "\(home)/.cache/turbo",
            "\(home)/.cache/vite",
            "\(home)/.cache/webpack",
            "\(home)/.parcel-cache",

            // ── Shell ───────────────────────────────────────────────
            // dev.sh: "Oh My Zsh cache"
            "\(home)/.oh-my-zsh/cache",

            // ── Docker ──────────────────────────────────────────────
            // dev.sh: Docker BuildX cache
            "\(home)/.docker/buildx/cache",

            // ── Cloud / DevOps ───────────────────────────────────────
            // dev.sh: Kubernetes / AWS CLI / gcloud / Azure
            "\(home)/.kube/cache",
            "\(home)/.aws/cli/cache",
            "\(home)/.config/gcloud/logs",
            "\(home)/.azure/logs",

            // ── VS Code ─────────────────────────────────────────────
            // dev.sh: VS Code cached data / extensions / GPU cache
            "\(home)/Library/Caches/com.microsoft.VSCode",
            "\(home)/Library/Application Support/Code/CachedData",
            "\(home)/Library/Application Support/Code/CachedExtensionVSIXs",
            "\(home)/Library/Application Support/Code/GPUCache",
            "\(home)/Library/Application Support/Code/DawnGraphiteCache",
            "\(home)/Library/Application Support/Code/DawnWebGPUCache",
            "\(home)/Library/Application Support/Code/logs",

            // ── Zed ─────────────────────────────────────────────────
            "\(home)/Library/Caches/Zed",

            // ── Android ──────────────────────────────────────────────
            "\(home)/.android/build-cache",
            "\(home)/.android/cache",
        ]
    }

    // MARK: - Temp & Crash Files (user-owned only)
    //
    // Mole 的 "Deep system" 组（/private/tmp、/Library/Logs/DiagnosticReports 等）
    // 需要 sudo，MoleUI 不处理。
    // 此处仅包含用户有写权限的崩溃报告和诊断日志路径。
    // 对应 Mole user.sh 中的 "Diagnostic reports"。

    /// 用户级临时文件及崩溃报告路径（无需 root）
    nonisolated static var tempFilePaths: [String] {
        [
            // user.sh: "Diagnostic reports"（用户目录，非 /Library）
            "\(home)/Library/DiagnosticReports",

            // user.sh: "Autosave information"
            "\(home)/Library/Autosave Information",

            // app_caches.sh: Claude / 各 app 的 log 目录示例（用户级）
            "\(home)/Library/Logs/DiagnosticReports",
        ]
    }

    // MARK: - Default Whitelist Patterns (lib/core/base.sh: DEFAULT_WHITELIST_PATTERNS)

    /// 默认白名单路径前缀（不清理）
    /// 提取自 Mole base.sh DEFAULT_WHITELIST_PATTERNS
    nonisolated static var defaultWhitelistPrefixes: [String] {
        let h = home
        return [
            "\(h)/Library/Caches/ms-playwright",
            "\(h)/.cache/huggingface",
            "\(h)/.ollama/models",
            "\(h)/Library/Caches/com.nssurge.surge-mac",
            "\(h)/Library/Application Support/com.nssurge.surge-mac",
            "\(h)/Library/Caches/org.R-project.R/R/renv",
            "\(h)/Library/Caches/pypoetry/virtualenvs",
            "\(h)/.cache/poetry/virtualenvs",
            "\(h)/Library/Caches/com.apple.finder",
            "\(h)/Library/Mobile Documents",
            "\(h)/Library/Caches/com.apple.FontRegistry",
            "\(h)/Library/Caches/com.apple.spotlight",
            "\(h)/Library/Caches/com.apple.Spotlight",
            "\(h)/Library/Caches/CloudKit",
            // Gradle 和 JetBrains 也在 Mole 白名单中
            "\(h)/.gradle/caches",
            "\(h)/.gradle/daemon",
            "\(h)/Library/Caches/JetBrains",
            "\(h)/Library/Application Support/JetBrains",
        ]
    }

    // MARK: - Helpers

    /// 获取某个类别的扫描路径
    nonisolated static func paths(for category: CleanCategory) -> [String] {
        switch category {
        case .userCaches:    return userCachePaths
        case .userLogs:      return userLogPaths
        case .trash:         return trashPaths
        case .browserCaches: return browserCachePaths
        case .devToolCaches: return devToolCachePaths
        case .tempFiles:     return tempFilePaths
        }
    }

    /// 判断路径是否在默认白名单中
    nonisolated static func isWhitelisted(_ path: String) -> Bool {
        defaultWhitelistPrefixes.contains { path.hasPrefix($0) }
    }
}
