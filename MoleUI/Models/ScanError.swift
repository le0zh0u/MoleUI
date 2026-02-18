//
//  ScanError.swift
//  MoleUI
//
//  Created by 周椿杰 on 2026/2/18.
//

import Foundation

/// 扫描错误类型
enum ScanError: LocalizedError {
    /// 路径不存在
    case pathNotFound(String)

    /// 权限不足
    case permissionDenied(String)

    /// 无效路径
    case invalidPath(String)

    /// 扫描失败
    case scanFailed(String, Error)

    /// 错误描述
    var errorDescription: String? {
        switch self {
        case .pathNotFound(let path):
            return "Path not found: \(path)"
        case .permissionDenied(let path):
            return "Permission denied: \(path)"
        case .invalidPath(let path):
            return "Invalid path: \(path)"
        case .scanFailed(let path, let error):
            return "Scan failed at \(path): \(error.localizedDescription)"
        }
    }

    /// 失败原因
    var failureReason: String? {
        switch self {
        case .pathNotFound:
            return "The specified path does not exist"
        case .permissionDenied:
            return "No permission to access the path"
        case .invalidPath:
            return "The path is not valid"
        case .scanFailed:
            return "An error occurred during scanning"
        }
    }

    /// 恢复建议
    var recoverySuggestion: String? {
        switch self {
        case .pathNotFound:
            return "Check if the path exists and try again"
        case .permissionDenied:
            return "Grant Full Disk Access permission in System Settings"
        case .invalidPath:
            return "Provide a valid file path"
        case .scanFailed:
            return "Check the error details and try again"
        }
    }
}
