//
//  CleanViewModel.swift
//  MoleUI
//
//  Created by 周椿杰 on 2026/2/18.
//

import Foundation
import Combine
import os.log

@MainActor
final class CleanViewModel: ObservableObject {

    // MARK: - Published

    /// 每个类别的扫描结果
    @Published var categoryResults: [CleanCategory: CategoryScanResult] = [:]

    /// 被用户勾选的可清理项 ID
    @Published var selectedItems: Set<UUID> = []

    /// 当前正在扫描的类别（nil 表示未在扫描）
    @Published var scanningCategory: CleanCategory?

    /// 扫描整体进度 (0.0 ~ 1.0)
    @Published var scanProgress: Double = 0

    /// 是否正在扫描
    @Published var isScanning: Bool = false

    /// 是否正在清理
    @Published var isCleaning: Bool = false

    /// 清理进度
    @Published var cleanProgress: Double = 0

    /// 最近一次清理结果
    @Published var lastCleanResult: CleanResult?

    /// 错误信息
    @Published var errorMessage: String?

    // MARK: - Private

    private let service = CleanService()
    private let logger = Logger(subsystem: "com.mole.MoleUI", category: "CleanViewModel")

    // MARK: - Computed

    /// 所有已扫描到的可清理项
    var allItems: [CleanItem] {
        categoryResults.values.flatMap { $0.items }
    }

    /// 被选中的可清理项
    var selectedCleanItems: [CleanItem] {
        allItems.filter { selectedItems.contains($0.id) }
    }

    /// 所有已扫描大小总和
    var totalScannedSize: Int64 {
        categoryResults.values.reduce(0) { $0 + $1.totalSize }
    }

    /// 选中项大小总和
    var selectedSize: Int64 {
        selectedCleanItems.reduce(0) { $0 + $1.size }
    }

    /// 是否有扫描结果
    var hasResults: Bool { !categoryResults.isEmpty }

    /// 是否有选中项
    var hasSelection: Bool { !selectedItems.isEmpty }

    // MARK: - 扫描

    /// 扫描所有类别
    func scanAll() async {
        guard !isScanning else { return }

        isScanning = true
        scanProgress = 0
        errorMessage = nil
        lastCleanResult = nil
        categoryResults = [:]
        selectedItems = []

        let categories = CleanCategory.allCases
        let categoryCount = Double(categories.count)
        var completedCount = 0

        for category in categories {
            scanningCategory = category
            let catIndex = Double(completedCount)

            let result: CategoryScanResult
            do {
                result = try await service.scan(category: category) { [weak self] _, prog, _ in
                    Task { @MainActor [weak self] in
                        guard let self else { return }
                        self.scanProgress = (catIndex + prog) / categoryCount
                    }
                }
            } catch {
                logger.warning("Scan failed for \(category.rawValue): \(error.localizedDescription)")
                result = CategoryScanResult(category: category, items: [])
            }

            categoryResults[category] = result
            completedCount += 1
            scanProgress = Double(completedCount) / categoryCount

            logger.info("Category \(category.rawValue): \(result.itemCount) items, \(result.totalSize) bytes")
        }

        scanningCategory = nil
        isScanning = false
        scanProgress = 1.0

        logger.info("Scan complete: \(self.allItems.count) total items")
    }

    /// 扫描单个类别
    func scan(category: CleanCategory) async {
        guard !isScanning else { return }

        isScanning = true
        scanningCategory = category
        errorMessage = nil

        do {
            let result = try await service.scan(category: category) { [weak self] _, prog, _ in
                Task { @MainActor [weak self] in
                    self?.scanProgress = prog
                }
            }

            categoryResults[category] = result
        } catch {
            errorMessage = "Scan failed: \(error.localizedDescription)"
        }

        scanningCategory = nil
        isScanning = false
    }

    // MARK: - 清理

    /// 清理选中的项
    func cleanSelected(moveToTrash: Bool = true) async {
        guard !isCleaning, hasSelection else { return }

        isCleaning = true
        cleanProgress = 0
        errorMessage = nil

        let items = selectedCleanItems
        let total = items.count

        do {
            let result = try await service.clean(
                items: items,
                moveToTrash: moveToTrash
            ) { current, totalItems, _ in
                Task { @MainActor [weak self] in
                    self?.cleanProgress = Double(current) / Double(max(totalItems, 1))
                }
            }

            lastCleanResult = result

            // 从扫描结果中移除已成功清理的项
            let succeededPaths = Set(result.succeeded.map { $0.path })
            for category in CleanCategory.allCases {
                if let catResult = categoryResults[category] {
                    let remaining = catResult.items.filter { !succeededPaths.contains($0.path) }
                    categoryResults[category] = CategoryScanResult(
                        category: category,
                        items: remaining
                    )
                }
            }

            // 清理选中状态
            selectedItems.subtract(Set(result.succeeded.map { $0.id }))

            let freedStr = FormatUtils.formatSize(result.freedBytes)
            let failedCount = result.failedCount
            logger.info("Clean complete: freed \(freedStr), \(failedCount) failed")
        } catch {
            errorMessage = "Clean failed: \(error.localizedDescription)"
        }

        isCleaning = false
        cleanProgress = 1.0
    }

    // MARK: - 选择管理

    /// 全选某个类别下的所有项
    func selectAll(in category: CleanCategory) {
        let ids = categoryResults[category]?.items.map { $0.id } ?? []
        selectedItems.formUnion(ids)
    }

    /// 取消选择某个类别下的所有项
    func deselectAll(in category: CleanCategory) {
        let ids = Set(categoryResults[category]?.items.map { $0.id } ?? [])
        selectedItems.subtract(ids)
    }

    /// 全选所有类别
    func selectAll() {
        selectedItems = Set(allItems.map { $0.id })
    }

    /// 取消全选
    func deselectAll() {
        selectedItems = []
    }

    func toggleSelection(_ item: CleanItem) {
        if selectedItems.contains(item.id) {
            selectedItems.remove(item.id)
        } else {
            selectedItems.insert(item.id)
        }
    }

    // MARK: - 辅助

    /// 某个类别下选中的项数量
    func selectedCount(in category: CleanCategory) -> Int {
        let ids = Set(categoryResults[category]?.items.map { $0.id } ?? [])
        return selectedItems.intersection(ids).count
    }

    /// 重置所有状态
    func reset() {
        categoryResults = [:]
        selectedItems = []
        scanProgress = 0
        cleanProgress = 0
        lastCleanResult = nil
        errorMessage = nil
        isScanning = false
        isCleaning = false
        scanningCategory = nil
    }
}
