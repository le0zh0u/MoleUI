//
//  FileScannerTestView.swift
//  MoleUI
//
//  Created by 周椿杰 on 2026/2/18.
//

import SwiftUI

/// 文件扫描测试视图
/// 用于测试和演示 FileScanner 功能
struct FileScannerTestView: View {
    @State private var testPath: String = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Downloads").path
    @State private var items: [FileItem] = []
    @State private var isScanning: Bool = false
    @State private var errorMessage: String?
    @State private var scanStats: (fileCount: Int, dirCount: Int, totalSize: Int64)?

    private let scanner = FileScanner()

    // 真实用户主目录
    private var realHomeDirectory: String {
        FileManager.default.homeDirectoryForCurrentUser.path
    }

    var body: some View {
        VStack(spacing: 20) {
            // 标题
            Text("File Scanner Test")
                .font(.title)
                .fontWeight(.bold)

            // 输入区域
            VStack(alignment: .leading, spacing: 10) {
                Text("Test Directory:")
                    .font(.headline)

                HStack {
                    TextField("Enter path", text: $testPath)
                        .textFieldStyle(.roundedBorder)

                    Button("Scan") {
                        Task {
                            await performScan()
                        }
                    }
                    .disabled(isScanning || testPath.isEmpty)
                    .buttonStyle(.borderedProminent)
                }

                // 快捷路径按钮
                HStack {
                    Button("Downloads") {
                        testPath = FileManager.default.homeDirectoryForCurrentUser
                            .appendingPathComponent("Downloads").path
                    }
                    .buttonStyle(.bordered)

                    Button("Documents") {
                        testPath = FileManager.default.homeDirectoryForCurrentUser
                            .appendingPathComponent("Documents").path
                    }
                    .buttonStyle(.bordered)

                    Button("Desktop") {
                        testPath = FileManager.default.homeDirectoryForCurrentUser
                            .appendingPathComponent("Desktop").path
                    }
                    .buttonStyle(.bordered)

                    Button("Applications") {
                        testPath = "/Applications"
                    }
                    .buttonStyle(.bordered)
                }

                // 显示当前路径（用于调试）
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current path: \(testPath)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("Real home: \(realHomeDirectory)")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)

            // 扫描状态
            if isScanning {
                ProgressView("Scanning...")
                    .padding()
            }

            // 错误信息
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
            }

            // 统计信息
            if let stats = scanStats {
                HStack(spacing: 30) {
                    VStack {
                        Text("\(stats.fileCount)")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Files")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    VStack {
                        Text("\(stats.dirCount)")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Directories")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    VStack {
                        Text(FormatUtils.formatSize(stats.totalSize))
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Total Size")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }

            // 结果列表
            if !items.isEmpty {
                VStack(alignment: .leading) {
                    Text("Scan Results (\(items.count) items)")
                        .font(.headline)

                    List(items.prefix(100)) { item in
                        HStack {
                            Image(systemName: item.isDirectory ? "folder.fill" : "doc.fill")
                                .foregroundColor(item.isDirectory ? .blue : .gray)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.name)
                                    .font(.body)

                                Text(FormatUtils.simplifyPath(item.path))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            if !item.isDirectory {
                                Text(FormatUtils.formatSize(item.size))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - 扫描操作

    @MainActor
    private func performScan() async {
        isScanning = true
        errorMessage = nil
        items = []
        scanStats = nil

        print("📂 Starting scan at: \(testPath)")

        // 检查路径是否存在
        guard FileManager.default.fileExists(atPath: testPath) else {
            errorMessage = "Path does not exist: \(testPath)"
            isScanning = false
            return
        }

        do {
            // 执行扫描（改为递归扫描）
            let scannedItems = try await scanner.scanDirectory(
                at: testPath,
                recursive: true
            ) { progress, currentPath, count in
                // 进度回调
                print("📊 Scanning: \(FormatUtils.simplifyPath(currentPath)) - \(count) items")
            }

            print("✅ Scan completed: \(scannedItems.count) items found")
            items = scannedItems

            // 计算统计信息
            let stats = await scanner.statistics(for: items)
            scanStats = stats
            print("📈 Stats - Files: \(stats.fileCount), Dirs: \(stats.dirCount), Size: \(FormatUtils.formatSize(stats.totalSize))")

        } catch let error as ScanError {
            print("❌ Scan error: \(error.errorDescription ?? "Unknown")")
            errorMessage = error.errorDescription
        } catch {
            print("❌ Unknown error: \(error.localizedDescription)")
            errorMessage = "Unknown error: \(error.localizedDescription)"
        }

        isScanning = false
    }
}

#Preview {
    FileScannerTestView()
        .frame(width: 700, height: 600)
}
