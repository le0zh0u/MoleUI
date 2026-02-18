//
//  FileScannerViewModel.swift
//  MoleUI
//
//  Created by 周椿杰 on 2026/2/18.
//

import Foundation
import Combine

/// 文件扫描视图模型
@MainActor
final class FileScannerViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var items: [FileItem] = []
    @Published var isScanning: Bool = false
    @Published var scanProgress: Double = 0.0
    @Published var currentPath: String = ""
    @Published var itemCount: Int = 0
    @Published var errorMessage: String?

    // MARK: - Statistics

    @Published var fileCount: Int = 0
    @Published var dirCount: Int = 0
    @Published var totalSize: Int64 = 0

    // MARK: - Private Properties

    private let scanner = FileScanner()
 
    // MARK: - Public Methods

    /// 扫描目录
    /// - Parameter path: 目录路径
    func scanDirectory(_ path: String) async {
        isScanning = true
        scanProgress = 0.0
        items = []
        errorMessage = nil
        fileCount = 0
        dirCount = 0
        totalSize = 0

        do {
            // 执行扫描
            let scannedItems = try await scanner.scanDirectory(at: path) { progress, currentPath, count in
                Task { @MainActor in
                    self.scanProgress = progress
                    self.currentPath = currentPath
                    self.itemCount = count
                }
            }

            // 更新结果
            items = scannedItems

            // 计算统计信息
            let stats = await scanner.statistics(for: scannedItems)
            fileCount = stats.fileCount
            dirCount = stats.dirCount
            totalSize = stats.totalSize

        } catch let error as ScanError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Unknown error: \(error.localizedDescription)"
        }

        isScanning = false
        scanProgress = 1.0
    }

    /// 扫描多个目录
    /// - Parameter paths: 目录路径数组
    func scanDirectories(_ paths: [String]) async {
        isScanning = true
        scanProgress = 0.0
        items = []
        errorMessage = nil

        do {
            let scannedItems = try await scanner.scanDirectories(paths) { progress, currentPath, count in
                Task { @MainActor in
                    self.scanProgress = progress
                    self.currentPath = currentPath
                    self.itemCount = count
                }
            }

            items = scannedItems

            let stats = await scanner.statistics(for: scannedItems)
            fileCount = stats.fileCount
            dirCount = stats.dirCount
            totalSize = stats.totalSize

        } catch let error as ScanError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Unknown error: \(error.localizedDescription)"
        }

        isScanning = false
        scanProgress = 1.0
    }

    /// 清除结果
    func clear() {
        items = []
        fileCount = 0
        dirCount = 0
        totalSize = 0
        errorMessage = nil
    }
}
