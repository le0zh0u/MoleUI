//
//  FileDeleter.swift
//  MoleUI
//
//  Created by 周椿杰 on 2026/2/18.
//

import Foundation
import os.log

/// 删除进度回调
/// - Parameters:
///   - current: 当前进度
///   - total: 总数
///   - path: 当前删除的文件路径
typealias DeleteProgressHandler = (Int, Int, String) -> Void

/// 文件删除服务
/// 提供安全的文件删除功能
actor FileDeleter {
    private let logger = Logger(subsystem: "com.mole.MoleUI", category: "FileDeleter")
    private let validator = PathValidator()
    private let fileManager = FileManager.default

    // MARK: - 删除选项

    /// 删除选项
    struct DeleteOptions {
        /// 是否移至垃圾箱（true）还是永久删除（false）
        var moveToTrash: Bool = true

        /// 是否跳过验证（危险！）
        var skipValidation: Bool = false

        /// 是否在遇到错误时继续
        var continueOnError: Bool = true

        /// 删除前是否需要确认
        var requireConfirmation: Bool = true
    }

    // MARK: - 单文件删除

    /// 删除单个文件或目录
    /// - Parameters:
    ///   - path: 文件路径
    ///   - options: 删除选项
    /// - Returns: 删除是否成功
    func deleteFile(at path: String, options: DeleteOptions = DeleteOptions()) async throws {
        logger.info("Deleting file: \(path)")

        // 1. 路径验证
        if !options.skipValidation {
            let validation = await validator.validate(path)

            switch validation {
            case .unsafe(let reason):
                logger.error("Unsafe path: \(path) - \(reason)")
                throw DeleteError.unsafePath(path)

            case .warning(let reason):
                logger.warning("Warning for path: \(path) - \(reason)")
                // 继续执行，但应该在 UI 层提示用户

            case .safe:
                break
            }
        }

        // 2. 检查文件是否存在
        guard fileManager.fileExists(atPath: path) else {
            logger.error("File not found: \(path)")
            throw DeleteError.fileNotFound(path)
        }

        // 3. 执行删除
        let url = URL(fileURLWithPath: path)

        do {
            if options.moveToTrash {
                // 移至垃圾箱
                try fileManager.trashItem(at: url, resultingItemURL: nil)
                logger.info("Moved to trash: \(path)")
            } else {
                // 永久删除
                try fileManager.removeItem(at: url)
                logger.info("Permanently deleted: \(path)")
            }
        } catch {
            logger.error("Failed to delete: \(path) - \(error.localizedDescription)")

            if options.moveToTrash {
                throw DeleteError.trashFailed(path, error)
            } else {
                throw DeleteError.deleteFailed(path, error)
            }
        }
    }

    // MARK: - 批量删除

    /// 批量删除文件
    /// - Parameters:
    ///   - paths: 文件路径数组
    ///   - options: 删除选项
    ///   - progress: 进度回调
    /// - Returns: 删除结果
    func deleteFiles(
        _ paths: [String],
        options: DeleteOptions = DeleteOptions(),
        progress: DeleteProgressHandler? = nil
    ) async throws -> BatchDeleteResult {
        logger.info("Starting batch delete: \(paths.count) items")

        var succeeded: [String] = []
        var failed: [(String, Error)] = []

        for (index, path) in paths.enumerated() {
            // 报告进度
            progress?(index + 1, paths.count, path)

            do {
                try await deleteFile(at: path, options: options)
                succeeded.append(path)
            } catch {
                logger.error("Failed to delete \(path): \(error.localizedDescription)")
                failed.append((path, error))

                // 如果不继续执行，抛出错误
                if !options.continueOnError {
                    throw DeleteError.partialFailure(
                        succeeded: succeeded.count,
                        failed: failed.count,
                        errors: failed.map { $0.1 }
                    )
                }
            }
        }

        let result = BatchDeleteResult(succeeded: succeeded, failed: failed)
        logger.info("Batch delete completed: \(result.succeeded.count) succeeded, \(result.failed.count) failed")

        return result
    }

    /// 批量删除 FileItem
    /// - Parameters:
    ///   - items: FileItem 数组
    ///   - options: 删除选项
    ///   - progress: 进度回调
    /// - Returns: 删除结果
    func deleteItems(
        _ items: [FileItem],
        options: DeleteOptions = DeleteOptions(),
        progress: DeleteProgressHandler? = nil
    ) async throws -> BatchDeleteResult {
        let paths = items.map { $0.path }
        return try await deleteFiles(paths, options: options, progress: progress)
    }

    // MARK: - 验证

    /// 验证路径是否可以安全删除
    /// - Parameter path: 文件路径
    /// - Returns: 验证结果
    func validatePath(_ path: String) async -> ValidationResult {
        await validator.validate(path)
    }

    /// 批量验证路径
    /// - Parameter paths: 路径数组
    /// - Returns: 验证结果字典
    func validatePaths(_ paths: [String]) async -> [String: ValidationResult] {
        await validator.validateBatch(paths)
    }

    // MARK: - 白名单管理

    /// 添加到白名单
    func addToWhitelist(_ path: String) async {
        await validator.addToWhitelist(path)
    }

    /// 从白名单移除
    func removeFromWhitelist(_ path: String) async {
        await validator.removeFromWhitelist(path)
    }

    /// 获取白名单
    func getWhitelist() async -> Set<String> {
        await validator.getWhitelist()
    }
}

// MARK: - 批量删除结果

/// 批量删除结果
struct BatchDeleteResult {
    /// 成功删除的路径
    let succeeded: [String]

    /// 失败的路径和错误
    let failed: [(String, Error)]

    /// 成功数量
    var succeededCount: Int {
        succeeded.count
    }

    /// 失败数量
    var failedCount: Int {
        failed.count
    }

    /// 总数
    var totalCount: Int {
        succeededCount + failedCount
    }

    /// 是否全部成功
    var isAllSucceeded: Bool {
        failed.isEmpty
    }

    /// 是否全部失败
    var isAllFailed: Bool {
        succeeded.isEmpty
    }
}
