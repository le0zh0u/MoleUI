//
//  FileItem.swift
//  MoleUI
//
//  Created by 周椿杰 on 2026/2/18.
//

import Foundation

/// 文件项模型，表示扫描到的文件或目录
struct FileItem: Identifiable, Hashable {
    /// 唯一标识符
    let id: UUID

    /// 文件 URL
    let url: URL

    /// 文件大小（字节）
    let size: Int64

    /// 修改时间
    let modifiedDate: Date

    /// 是否为目录
    let isDirectory: Bool

    /// 文件名
    var name: String {
        url.lastPathComponent
    }

    /// 文件路径
    var path: String {
        url.path
    }

    /// 文件扩展名
    var fileExtension: String {
        url.pathExtension
    }

    /// 初始化
    init(
        id: UUID = UUID(),
        url: URL,
        size: Int64,
        modifiedDate: Date,
        isDirectory: Bool
    ) {
        self.id = id
        self.url = url
        self.size = size
        self.modifiedDate = modifiedDate
        self.isDirectory = isDirectory
    }

    /// Hashable 实现
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    /// Equatable 实现
    static func == (lhs: FileItem, rhs: FileItem) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - 便利扩展

extension FileItem {
    /// 从文件路径创建 FileItem
    static func from(path: String) throws -> FileItem {
        let url = URL(fileURLWithPath: path)
        let fileManager = FileManager.default

        guard fileManager.fileExists(atPath: path) else {
            throw ScanError.pathNotFound(path)
        }

        let attributes = try fileManager.attributesOfItem(atPath: path)
        let size = attributes[.size] as? Int64 ?? 0
        let modifiedDate = attributes[.modificationDate] as? Date ?? Date()
        let isDirectory = (attributes[.type] as? FileAttributeType) == .typeDirectory

        return FileItem(
            url: url,
            size: size,
            modifiedDate: modifiedDate,
            isDirectory: isDirectory
        )
    }
}
