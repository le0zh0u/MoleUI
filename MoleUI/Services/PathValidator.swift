//
//  PathValidator.swift
//  MoleUI
//
//  Created by 周椿杰 on 2026/2/18.
//

import Foundation
import os.log

/// 路径验证服务
/// 确保文件删除操作的安全性，防止误删系统关键文件
actor PathValidator {
    private let logger = Logger(subsystem: "com.mole.MoleUI", category: "PathValidator")

    // MARK: - 系统保护路径

    /// 系统关键路径（绝对不允许删除）
    private let criticalPaths: Set<String> = [
        "/System",
        "/bin",
        "/sbin",
        "/usr",
        "/Library",
        "/private",
        "/dev",
        "/etc",
        "/var/db",
        "/var/root"
    ]

    /// 用户关键路径（需要特别警告）
    private let userCriticalPaths: Set<String> = [
        "Documents",
        "Desktop",
        "Pictures",
        "Music",
        "Movies",
        "Downloads"
    ]

    /// 应用关键路径
    private let appCriticalPaths: Set<String> = [
        "/Applications/Safari.app",
        "/Applications/Mail.app",
        "/Applications/Messages.app",
        "/Applications/FaceTime.app",
        "/Applications/Calendar.app",
        "/Applications/Contacts.app",
        "/Applications/Notes.app",
        "/Applications/Reminders.app",
        "/Applications/Music.app",
        "/Applications/TV.app",
        "/Applications/Photos.app",
        "/Applications/App Store.app",
        "/Applications/System Settings.app",
        "/Applications/System Preferences.app"
    ]

    // MARK: - 白名单

    /// 用户自定义白名单（不会被删除的路径）
    private var whitelist: Set<String> = []

    /// 添加到白名单
    func addToWhitelist(_ path: String) {
        whitelist.insert(path)
        logger.info("Added to whitelist: \(path)")
    }

    /// 从白名单移除
    func removeFromWhitelist(_ path: String) {
        whitelist.remove(path)
        logger.info("Removed from whitelist: \(path)")
    }

    /// 获取白名单
    func getWhitelist() -> Set<String> {
        whitelist
    }

    // MARK: - 路径验证

    /// 验证路径是否安全可以删除
    /// - Parameter path: 要验证的路径
    /// - Returns: 验证结果
    func validate(_ path: String) async -> ValidationResult {
        logger.debug("Validating path: \(path)")

        // 1. 检查是否在白名单中
        if whitelist.contains(path) {
            logger.info("Path is whitelisted: \(path)")
            return .unsafe(reason: "Path is in whitelist")
        }

        // 2. 检查是否为系统关键路径
        if isCriticalPath(path) {
            logger.warning("Critical system path: \(path)")
            return .unsafe(reason: "Critical system path")
        }

        // 3. 检查是否为应用关键路径
        if isAppCriticalPath(path) {
            logger.warning("Critical application path: \(path)")
            return .warning(reason: "System application")
        }

        // 4. 检查路径遍历
        if hasPathTraversal(path) {
            logger.warning("Path traversal detected: \(path)")
            return .unsafe(reason: "Path traversal detected")
        }

        // 5. 检查符号链接
        if let resolved = try? resolveSymlink(path) {
            if resolved != path {
                logger.info("Symlink detected: \(path) -> \(resolved)")
                // 递归验证符号链接目标
                let targetValidation = await validate(resolved)
                if case .unsafe = targetValidation {
                    return .unsafe(reason: "Symlink target is unsafe")
                }
            }
        }

        // 6. 检查是否为用户关键目录
        if isUserCriticalPath(path) {
            logger.info("User critical path: \(path)")
            return .warning(reason: "User important folder")
        }

        // 7. 检查是否在用户目录外
        let homeDir = FileManager.default.homeDirectoryForCurrentUser.path
        if !path.hasPrefix(homeDir) && !path.hasPrefix("/Applications") {
            logger.info("Path outside user directory: \(path)")
            return .warning(reason: "Outside user directory")
        }

        logger.debug("Path validation passed: \(path)")
        return .safe
    }

    /// 批量验证路径
    /// - Parameter paths: 路径数组
    /// - Returns: 验证结果字典
    func validateBatch(_ paths: [String]) async -> [String: ValidationResult] {
        var results: [String: ValidationResult] = [:]

        for path in paths {
            results[path] = await validate(path)
        }

        return results
    }

    // MARK: - 私有方法

    /// 检查是否为系统关键路径
    private func isCriticalPath(_ path: String) -> Bool {
        // 精确匹配
        if criticalPaths.contains(path) {
            return true
        }

        // 检查是否为关键路径的子路径
        for criticalPath in criticalPaths {
            if path.hasPrefix(criticalPath + "/") {
                return true
            }
        }

        return false
    }

    /// 检查是否为应用关键路径
    private func isAppCriticalPath(_ path: String) -> Bool {
        appCriticalPaths.contains(path)
    }

    /// 检查是否为用户关键路径
    private func isUserCriticalPath(_ path: String) -> Bool {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser.path
        let components = path.replacingOccurrences(of: homeDir + "/", with: "").split(separator: "/")

        if let firstComponent = components.first {
            return userCriticalPaths.contains(String(firstComponent))
        }

        return false
    }

    /// 检查路径遍历
    private func hasPathTraversal(_ path: String) -> Bool {
        // 检查是否包含 ../ 或 ../
        path.contains("/../") || path.hasSuffix("/..")
    }

    /// 解析符号链接
    private func resolveSymlink(_ path: String) throws -> String {
        try FileManager.default.destinationOfSymbolicLink(atPath: path)
    }
}

// MARK: - 验证结果

/// 路径验证结果
enum ValidationResult: Equatable {
    /// 安全（可以删除）
    case safe

    /// 警告（可以删除但需要用户确认）
    case warning(reason: String)

    /// 不安全（不允许删除）
    case unsafe(reason: String)

    var isSafe: Bool {
        if case .safe = self {
            return true
        }
        return false
    }

    var isWarning: Bool {
        if case .warning = self {
            return true
        }
        return false
    }

    var isUnsafe: Bool {
        if case .unsafe = self {
            return true
        }
        return false
    }

    var reason: String? {
        switch self {
        case .safe:
            return nil
        case .warning(let reason), .unsafe(let reason):
            return reason
        }
    }
}
