//
//  CleanCategory.swift
//  MoleUI
//
//  Created by 周椿杰 on 2026/2/18.
//

import Foundation

/// 清理类别
/// 每个类别对应 Mole CLI 中的一类清理功能
enum CleanCategory: String, CaseIterable, Identifiable {
    /// 用户应用缓存 (~Library/Caches)
    case userCaches = "user_caches"

    /// 用户日志 (~/Library/Logs)
    case userLogs = "user_logs"

    /// 废纸篓 (~/.Trash)
    case trash = "trash"

    /// 浏览器缓存
    case browserCaches = "browser_caches"

    /// 开发者工具缓存 (Xcode DerivedData、npm、yarn 等)
    case devToolCaches = "dev_tool_caches"

    /// 临时文件及崩溃报告
    case tempFiles = "temp_files"

    var id: String { rawValue }

    /// 显示名称
    var displayName: String {
        switch self {
        case .userCaches:    return "User Caches"
        case .userLogs:      return "User Logs"
        case .trash:         return "Trash"
        case .browserCaches: return "Browser Caches"
        case .devToolCaches: return "Developer Caches"
        case .tempFiles:     return "Temp & Crash Files"
        }
    }

    /// 功能描述
    var description: String {
        switch self {
        case .userCaches:
            return "App caches in ~/Library/Caches"
        case .userLogs:
            return "Log files in ~/Library/Logs"
        case .trash:
            return "Files waiting in the Trash"
        case .browserCaches:
            return "Safari, Chrome, Firefox caches"
        case .devToolCaches:
            return "Xcode DerivedData, npm, yarn, pip, Cargo and more"
        case .tempFiles:
            return "Temporary files and crash reports"
        }
    }

    /// SF Symbol 图标
    var icon: String {
        switch self {
        case .userCaches:    return "internaldrive"
        case .userLogs:      return "doc.text"
        case .trash:         return "trash"
        case .browserCaches: return "safari"
        case .devToolCaches: return "hammer"
        case .tempFiles:     return "doc.badge.clock"
        }
    }
}
