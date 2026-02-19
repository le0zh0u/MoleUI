//
//  CleanItem.swift
//  MoleUI
//
//  Created by 周椿杰 on 2026/2/18.
//

import Foundation

// MARK: - CleanItem

/// 可清理项目
/// 代表某个清理类别下扫描到的一个文件或目录
struct CleanItem: Identifiable, Hashable {
    let id: UUID
    /// 所属清理类别
    let category: CleanCategory
    /// 底层文件元数据
    let fileItem: FileItem

    /// 文件路径
    var path: String { fileItem.path }

    /// 文件名
    var name: String { fileItem.name }

    /// 大小（字节）
    var size: Int64 { fileItem.size }

    /// 是否为目录
    var isDirectory: Bool { fileItem.isDirectory }

    init(category: CleanCategory, fileItem: FileItem) {
        self.id = UUID()
        self.category = category
        self.fileItem = fileItem
    }
}

// MARK: - CategoryScanResult

/// 单个类别的扫描结果
struct CategoryScanResult {
    let category: CleanCategory
    let items: [CleanItem]

    /// 该类别下所有文件的总大小
    var totalSize: Int64 {
        items.reduce(0) { $0 + $1.size }
    }

    var itemCount: Int { items.count }

    var isEmpty: Bool { items.isEmpty }
}

// MARK: - CleanResult

/// 清理操作结果
struct CleanResult {
    /// 成功清理的项目
    let succeeded: [CleanItem]

    /// 清理失败的项目及原因
    let failed: [(CleanItem, Error)]

    /// 成功数量
    var succeededCount: Int { succeeded.count }

    /// 失败数量
    var failedCount: Int { failed.count }

    /// 总共释放的空间（字节）
    var freedBytes: Int64 {
        succeeded.reduce(0) { $0 + $1.size }
    }

    /// 是否全部成功
    var isAllSucceeded: Bool { failed.isEmpty }

    /// 是否全部失败
    var isAllFailed: Bool { succeeded.isEmpty }
}

// MARK: - ScanState

/// 扫描状态
enum ScanState: Equatable {
    case idle
    case scanning(category: CleanCategory, progress: Double)
    case completed
    case failed(String)
}

// MARK: - CleanState

/// 清理状态
enum CleanState: Equatable {
    case idle
    case cleaning(current: Int, total: Int)
    case completed(CleanResult)
    case failed(String)

    static func == (lhs: CleanState, rhs: CleanState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle): return true
        case (.cleaning(let lc, let lt), .cleaning(let rc, let rt)):
            return lc == rc && lt == rt
        case (.failed(let l), .failed(let r)): return l == r
        default: return false
        }
    }
}
