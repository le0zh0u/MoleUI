//
//  PermissionManager.swift
//  MoleUI
//
//  Created by 周椿杰 on 2026/2/18.
//

import Foundation
import AppKit
import Combine
import os.log

/// 权限管理服务
/// 检查和请求应用所需的各种系统权限
final class PermissionManager: ObservableObject {
    static let shared = PermissionManager()

    private let logger = Logger(subsystem: "com.mole.MoleUI", category: "PermissionManager")

    // MARK: - Published Properties

    @Published var hasFullDiskAccess: Bool = false

    private init() {
        checkFullDiskAccess()
    }

    // MARK: - 完全磁盘访问权限

    /// 检查是否有完全磁盘访问权限
    /// - Returns: 是否有权限
    @discardableResult
    func checkFullDiskAccess() -> Bool {
        let testPaths = [
            "/Library/Application Support",
            "/Library/Safari",
            "/Library/Mail"
        ]

        for testPath in testPaths {
            if fileManager.isReadableFile(atPath: testPath) {
                hasFullDiskAccess = true
                logger.info("Full disk access granted")
                return true
            }
        }

        hasFullDiskAccess = false
        logger.warning("Full disk access not granted")
        return false
    }

    /// 请求完全磁盘访问权限
    /// 引导用户到系统设置
    func requestFullDiskAccess() {
        logger.info("Requesting full disk access")

        // macOS 13+ 使用新的 URL scheme
        if #available(macOS 13.0, *) {
            if let url = URL(string: "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension") {
                NSWorkspace.shared.open(url)
            }
        } else {
            // macOS 12 及更早版本
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles") {
                NSWorkspace.shared.open(url)
            }
        }
    }

    // MARK: - 文件访问权限

    /// 检查是否有权限访问特定路径
    /// - Parameter path: 文件路径
    /// - Returns: 是否有权限
    func checkAccess(to path: String) -> Bool {
        fileManager.isReadableFile(atPath: path) && fileManager.isWritableFile(atPath: path)
    }

    /// 请求访问特定路径的权限
    /// - Parameter path: 文件路径
    /// - Returns: 用户选择的 URL（如果授权）
    func requestAccess(to path: String) -> URL? {
        let openPanel = NSOpenPanel()
        openPanel.message = "Grant access to: \(path)"
        openPanel.prompt = "Grant Access"
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = false
        openPanel.directoryURL = URL(fileURLWithPath: path)

        if openPanel.runModal() == .OK {
            return openPanel.url
        }

        return nil
    }

    // MARK: - 权限状态

    /// 获取权限状态摘要
    /// - Returns: 权限状态字符串
    func getPermissionStatus() -> String {
        var status: [String] = []

        if hasFullDiskAccess {
            status.append("✅ Full Disk Access")
        } else {
            status.append("❌ Full Disk Access")
        }

        return status.joined(separator: "\n")
    }

    /// 是否所有必要权限都已授予
    var hasAllRequiredPermissions: Bool {
        hasFullDiskAccess
    }

    // MARK: - Private

    private let fileManager = FileManager.default
}

// MARK: - 权限状态

/// 权限状态
enum PermissionStatus {
    /// 已授权
    case authorized

    /// 未授权
    case denied

    /// 未确定
    case notDetermined

    var isAuthorized: Bool {
        self == .authorized
    }
}
