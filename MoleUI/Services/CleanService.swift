//
//  CleanService.swift
//  MoleUI
//
//  Created by 周椿杰 on 2026/2/18.
//

import Foundation
import os.log

/// 扫描进度回调
/// - Parameters:
///   - category: 当前扫描类别
///   - progress: 进度 (0.0 ~ 1.0)
///   - message:  当前路径或说明
typealias CleanScanProgressHandler = (CleanCategory, Double, String) -> Void

/// 清理核心服务
/// 整合 FileScanner + FileDeleter，按 CleanCategory 批量扫描和清理
actor CleanService {

    private let logger = Logger(subsystem: "com.mole.MoleUI", category: "CleanService")
    private let scanner = FileScanner()
    private let deleter = FileDeleter()

    // MARK: - 扫描

    /// 扫描单个类别，返回可清理项列表
    func scan(
        category: CleanCategory,
        progress: CleanScanProgressHandler? = nil
    ) async throws -> CategoryScanResult {
        let paths = CleanConfig.paths(for: category)
        logger.info("Scanning category: \(category.rawValue) (\(paths.count) paths)")

        var items: [CleanItem] = []
        let total = paths.count

        for (index, path) in paths.enumerated() {
            let relativeProg = Double(index) / Double(max(total, 1))
            progress?(category, relativeProg, path)

            guard FileManager.default.fileExists(atPath: path) else {
                logger.debug("Path not found, skipping: \(path)")
                continue
            }

            do {
                let fileItems = try await scanner.scanDirectory(
                    at: path,
                    recursive: false
                ) { _, _, _ in }

                // 过滤白名单
                let filtered = fileItems.filter { !CleanConfig.isWhitelisted($0.path) }
                let cleanItems = filtered.map { CleanItem(category: category, fileItem: $0) }
                items.append(contentsOf: cleanItems)

                logger.info("Scanned \(path): \(filtered.count) items")
            } catch {
                logger.warning("Failed to scan \(path): \(error.localizedDescription)")
            }
        }

        progress?(category, 1.0, "Done")

        return CategoryScanResult(category: category, items: items)
    }

    /// 扫描所有类别（并发）
    func scanAll(
        progress: CleanScanProgressHandler? = nil
    ) async -> [CleanCategory: CategoryScanResult] {
        logger.info("Starting full scan of all categories")

        var results: [CleanCategory: CategoryScanResult] = [:]

        // 逐个扫描（保证进度回调有序）
        for category in CleanCategory.allCases {
            let result = (try? await scan(category: category, progress: progress))
                ?? CategoryScanResult(category: category, items: [])
            results[category] = result
        }

        let totalItems = results.values.reduce(0) { $0 + $1.itemCount }
        logger.info("Full scan complete: \(totalItems) items across \(results.count) categories")

        return results
    }

    // MARK: - 清理

    /// 清理指定的可清理项
    func clean(
        items: [CleanItem],
        moveToTrash: Bool = true,
        progress: DeleteProgressHandler? = nil
    ) async throws -> CleanResult {
        logger.info("Cleaning \(items.count) items (moveToTrash=\(moveToTrash))")

        let options = FileDeleter.DeleteOptions(
            moveToTrash: moveToTrash,
            skipValidation: false,
            continueOnError: true,
            requireConfirmation: false
        )

        let fileItems = items.map { $0.fileItem }
        let batchResult = try await deleter.deleteItems(fileItems, options: options, progress: progress)

        // 将 BatchDeleteResult 映射回 CleanResult
        let succeededPaths = Set(batchResult.succeeded)
        let succeededItems = items.filter { succeededPaths.contains($0.path) }

        let failedPaths = Dictionary(uniqueKeysWithValues: batchResult.failed)
        let failedItems: [(CleanItem, Error)] = items
            .filter { failedPaths[$0.path] != nil }
            .compactMap { item in
                guard let err = failedPaths[item.path] else { return nil }
                return (item, err)
            }

        let result = CleanResult(succeeded: succeededItems, failed: failedItems)

        let freed = result.freedBytes
        let succeeded = result.succeededCount
        let failedCount = result.failedCount
        logger.info("Clean complete: \(succeeded) succeeded, \(failedCount) failed, freed \(freed) bytes")

        return result
    }

    // MARK: - 大小估算

    /// 快速估算某个类别已占用磁盘大小
    func estimateSize(for category: CleanCategory) async -> Int64 {
        let paths = CleanConfig.paths(for: category)
        var total: Int64 = 0

        for path in paths {
            guard FileManager.default.fileExists(atPath: path) else { continue }
            if let size = try? await scanner.calculateSize(of: path) {
                total += size
            }
        }

        return total
    }
}
