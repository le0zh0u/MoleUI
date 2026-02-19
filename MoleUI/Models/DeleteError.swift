//
//  DeleteError.swift
//  MoleUI
//
//  Created by 周椿杰 on 2026/2/18.
//

import Foundation

/// 文件删除错误类型
enum DeleteError: LocalizedError {
    /// 不安全的路径（系统保护路径）
    case unsafePath(String)

    /// 权限不足
    case permissionDenied(String)

    /// 文件不存在
    case fileNotFound(String)

    /// 删除失败
    case deleteFailed(String, Error)

    /// 移至垃圾箱失败
    case trashFailed(String, Error)

    /// 批量删除部分失败
    case partialFailure(succeeded: Int, failed: Int, errors: [Error])

    /// 用户取消操作
    case userCancelled

    /// 错误描述
    var errorDescription: String? {
        switch self {
        case .unsafePath(let path):
            return "Unsafe path (system protected): \(path)"
        case .permissionDenied(let path):
            return "Permission denied: \(path)"
        case .fileNotFound(let path):
            return "File not found: \(path)"
        case .deleteFailed(let path, let error):
            return "Failed to delete \(path): \(error.localizedDescription)"
        case .trashFailed(let path, let error):
            return "Failed to move to trash \(path): \(error.localizedDescription)"
        case .partialFailure(let succeeded, let failed, _):
            return "Partial failure: \(succeeded) succeeded, \(failed) failed"
        case .userCancelled:
            return "Operation cancelled by user"
        }
    }

    /// 失败原因
    var failureReason: String? {
        switch self {
        case .unsafePath:
            return "The path is protected by the system"
        case .permissionDenied:
            return "No permission to delete the file"
        case .fileNotFound:
            return "The file does not exist"
        case .deleteFailed, .trashFailed:
            return "An error occurred during deletion"
        case .partialFailure:
            return "Some files failed to delete"
        case .userCancelled:
            return "The user cancelled the operation"
        }
    }

    /// 恢复建议
    var recoverySuggestion: String? {
        switch self {
        case .unsafePath:
            return "Do not delete system protected paths"
        case .permissionDenied:
            return "Grant necessary permissions or run as administrator"
        case .fileNotFound:
            return "Check if the file exists"
        case .deleteFailed, .trashFailed:
            return "Check permissions and try again"
        case .partialFailure:
            return "Review the failed items and retry if needed"
        case .userCancelled:
            return nil
        }
    }
}
