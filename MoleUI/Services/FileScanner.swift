//
//  FileScanner.swift
//  MoleUI
//
//  Created by 周椿杰 on 2026/2/18.
//

import Foundation
import os.log

/// 文件扫描进度回调
/// - Parameters:
///   - progress: 进度值（0.0 - 1.0）
///   - currentPath: 当前扫描的路径
///   - itemCount: 已扫描的项目数量
typealias ScanProgressHandler = (Double, String, Int) -> Void

/// 文件扫描服务
/// 提供文件和目录的扫描功能，支持异步操作和进度回调
actor FileScanner {
    private let logger = Logger(subsystem: "com.mole.MoleUI", category: "FileScanner")
    private let fileManager = FileManager.default

    /// 扫描单个目录
    /// - Parameters:
    ///   - path: 目录路径
    ///   - recursive: 是否递归扫描子目录
    ///   - progress: 进度回调
    /// - Returns: 扫描到的文件项数组
    func scanDirectory(
        at path: String,
        recursive: Bool = true,
        progress: ScanProgressHandler? = nil
    ) async throws -> [FileItem] {
        logger.info("Starting scan at: \(path)")

        let url = URL(fileURLWithPath: path)

        // 验证路径
        guard fileManager.fileExists(atPath: path) else {
            logger.error("Path not found: \(path)")
            throw ScanError.pathNotFound(path)
        }

        var items: [FileItem] = []

        // 创建枚举器
        let resourceKeys: [URLResourceKey] = [
            .fileSizeKey,
            .contentModificationDateKey,
            .isDirectoryKey,
            .nameKey
        ]

        guard let enumerator = fileManager.enumerator(
            at: url,
            includingPropertiesForKeys: resourceKeys,
            options: recursive ? [] : [.skipsSubdirectoryDescendants]
        ) else {
            logger.error("Failed to create enumerator for: \(path)")
            throw ScanError.invalidPath(path)
        }

        var count = 0

        for case let fileURL as URL in enumerator {
            do {
                // 读取文件属性
                let resourceValues = try fileURL.resourceValues(forKeys: Set(resourceKeys))

                let item = FileItem(
                    url: fileURL,
                    size: Int64(resourceValues.fileSize ?? 0),
                    modifiedDate: resourceValues.contentModificationDate ?? Date(),
                    isDirectory: resourceValues.isDirectory ?? false
                )

                items.append(item)
                count += 1

                // 报告进度（每 100 个文件报告一次）
                if count % 100 == 0 {
                    progress?(0.0, fileURL.path, count)
                }

            } catch {
                // 记录错误但继续扫描
                logger.warning("Failed to read attributes for: \(fileURL.path) - \(error.localizedDescription)")
                continue
            }
        }

        logger.info("Scan completed. Found \(count) items at: \(path)")
        progress?(1.0, path, count)

        return items
    }

    /// 计算目录或文件的总大小
    /// - Parameter path: 文件或目录路径
    /// - Returns: 总大小（字节）
    func calculateSize(of path: String) async throws -> Int64 {
        let url = URL(fileURLWithPath: path)

        guard fileManager.fileExists(atPath: path) else {
            throw ScanError.pathNotFound(path)
        }

        // 获取文件属性
        let resourceValues = try url.resourceValues(forKeys: [.isDirectoryKey, .fileSizeKey])

        // 如果是文件，直接返回大小
        if let isDirectory = resourceValues.isDirectory, !isDirectory {
            return Int64(resourceValues.fileSize ?? 0)
        }

        // 如果是目录，递归计算
        var totalSize: Int64 = 0

        guard let enumerator = fileManager.enumerator(
            at: url,
            includingPropertiesForKeys: [.fileSizeKey, .isDirectoryKey]
        ) else {
            throw ScanError.invalidPath(path)
        }

        for case let fileURL as URL in enumerator {
            do {
                let values = try fileURL.resourceValues(forKeys: [.fileSizeKey, .isDirectoryKey])
                if let isDirectory = values.isDirectory, !isDirectory {
                    totalSize += Int64(values.fileSize ?? 0)
                }
            } catch {
                logger.warning("Failed to calculate size for: \(fileURL.path)")
                continue
            }
        }

        return totalSize
    }

    /// 扫描多个目录（并发）
    /// - Parameters:
    ///   - paths: 目录路径数组
    ///   - progress: 进度回调
    /// - Returns: 所有扫描到的文件项
    func scanDirectories(
        _ paths: [String],
        progress: ScanProgressHandler? = nil
    ) async throws -> [FileItem] {
        logger.info("Starting concurrent scan for \(paths.count) directories")

        return try await withThrowingTaskGroup(of: [FileItem].self) { group in
            // 为每个路径创建扫描任务
            for path in paths {
                group.addTask {
                    try await self.scanDirectory(at: path, progress: progress)
                }
            }

            // 收集所有结果
            var allItems: [FileItem] = []
            for try await items in group {
                allItems.append(contentsOf: items)
            }

            logger.info("Concurrent scan completed. Total items: \(allItems.count)")
            return allItems
        }
    }

    /// 统计扫描结果
    /// - Parameter items: 文件项数组
    /// - Returns: 统计信息（文件数、目录数、总大小）
    func statistics(for items: [FileItem]) -> (fileCount: Int, dirCount: Int, totalSize: Int64) {
        var fileCount = 0
        var dirCount = 0
        var totalSize: Int64 = 0

        for item in items {
            if item.isDirectory {
                dirCount += 1
            } else {
                fileCount += 1
                totalSize += item.size
            }
        }

        return (fileCount, dirCount, totalSize)
    }
}
