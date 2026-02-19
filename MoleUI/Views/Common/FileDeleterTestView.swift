//
//  FileDeleterTestView.swift
//  MoleUI
//
//  Created by 周椿杰 on 2026/2/18.
//

import SwiftUI

/// 文件删除测试视图
/// 用于测试和演示 FileDeleter 功能
struct FileDeleterTestView: View {
    @State private var testPath: String = ""
    @State private var scannedItems: [FileItem] = []
    @State private var selectedItems: Set<UUID> = []
    @State private var isScanning: Bool = false
    @State private var isDeleting: Bool = false
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var deleteResult: BatchDeleteResult?

    @StateObject private var permissionManager = PermissionManager.shared

    private let scanner = FileScanner()
    private let deleter = FileDeleter()

    var body: some View {
        VStack(spacing: 20) {
            // 标题和权限状态
            VStack(spacing: 10) {
                Text("File Deleter Test")
                    .font(.title)
                    .fontWeight(.bold)

                // 权限状态
                HStack {
                    Image(systemName: permissionManager.hasFullDiskAccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(permissionManager.hasFullDiskAccess ? .green : .red)
                    Text(permissionManager.hasFullDiskAccess ? "Full Disk Access Granted" : "Full Disk Access Required")
                        .font(.caption)

                    if !permissionManager.hasFullDiskAccess {
                        Button("Grant Access") {
                            permissionManager.requestFullDiskAccess()
                        }
                        .buttonStyle(.bordered)
                        .font(.caption)
                    }
                }
            }

            // 扫描区域
            VStack(alignment: .leading, spacing: 10) {
                Text("1. Scan Directory:")
                    .font(.headline)

                HStack {
                    TextField("Enter path to scan", text: $testPath)
                        .textFieldStyle(.roundedBorder)

                    Button("Scan") {
                        Task {
                            await performScan()
                        }
                    }
                    .disabled(isScanning || testPath.isEmpty)
                    .buttonStyle(.borderedProminent)
                }

                // 快捷测试路径
                HStack {
                    Text("Test paths:")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Button("~/Downloads") {
                        testPath = FileManager.default.homeDirectoryForCurrentUser
                            .appendingPathComponent("Downloads").path
                    }
                    .buttonStyle(.bordered)
                    .font(.caption)

                    Button("Create test folder") {
                        createTestFolder()
                    }
                    .buttonStyle(.bordered)
                    .font(.caption)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)

            // 扫描结果
            if isScanning {
                ProgressView("Scanning...")
            } else if !scannedItems.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("2. Select files to delete (\(scannedItems.count) items):")
                            .font(.headline)

                        Spacer()

                        Button("Select All") {
                            selectedItems = Set(scannedItems.map { $0.id })
                        }
                        .buttonStyle(.bordered)
                        .font(.caption)

                        Button("Deselect All") {
                            selectedItems = []
                        }
                        .buttonStyle(.bordered)
                        .font(.caption)
                    }

                    List(scannedItems.prefix(50)) { item in
                        HStack {
                            Button(action: {
                                toggleSelection(item)
                            }) {
                                Image(systemName: selectedItems.contains(item.id) ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(selectedItems.contains(item.id) ? .blue : .gray)
                            }
                            .buttonStyle(.plain)

                            Image(systemName: item.isDirectory ? "folder.fill" : "doc.fill")
                                .foregroundColor(item.isDirectory ? .blue : .gray)

                            VStack(alignment: .leading, spacing: 2) {
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
                    }
                    .frame(maxHeight: 300)
                }
            }

            // 删除按钮
            if !selectedItems.isEmpty {
                HStack {
                    Text("3. Delete selected files:")
                        .font(.headline)

                    Spacer()

                    Button("Delete (\(selectedItems.count) items)") {
                        Task {
                            await performDelete()
                        }
                    }
                    .disabled(isDeleting)
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                }
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
            }

            // 状态消息
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
            }

            if let success = successMessage {
                Text(success)
                    .foregroundColor(.green)
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
            }

            // 删除结果
            if let result = deleteResult {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Delete Result:")
                        .font(.headline)

                    HStack(spacing: 30) {
                        VStack {
                            Text("\(result.succeededCount)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            Text("Succeeded")
                                .font(.caption)
                        }

                        VStack {
                            Text("\(result.failedCount)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                            Text("Failed")
                                .font(.caption)
                        }
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - 操作

    @MainActor
    private func performScan() async {
        isScanning = true
        errorMessage = nil
        successMessage = nil
        scannedItems = []
        selectedItems = []
        deleteResult = nil

        do {
            let items = try await scanner.scanDirectory(at: testPath, recursive: false) { _, _, _ in }
            scannedItems = items
            print("✅ Scanned \(items.count) items")
        } catch {
            errorMessage = "Scan failed: \(error.localizedDescription)"
        }

        isScanning = false
    }

    @MainActor
    private func performDelete() async {
        isDeleting = true
        errorMessage = nil
        successMessage = nil

        let itemsToDelete = scannedItems.filter { selectedItems.contains($0.id) }

        print("🗑️ Deleting \(itemsToDelete.count) items...")

        do {
            let options = FileDeleter.DeleteOptions(
                moveToTrash: true,
                skipValidation: false,
                continueOnError: true,
                requireConfirmation: false
            )

            let result = try await deleter.deleteItems(itemsToDelete, options: options) { current, total, path in
                print("  [\(current)/\(total)] Deleting: \(FormatUtils.simplifyPath(path))")
            }

            deleteResult = result

            if result.isAllSucceeded {
                successMessage = "✅ Successfully deleted \(result.succeededCount) items"
                // 移除已删除的项
                scannedItems.removeAll { selectedItems.contains($0.id) }
                selectedItems = []
            } else if result.isAllFailed {
                errorMessage = "❌ Failed to delete all items"
            } else {
                successMessage = "⚠️ Partially succeeded: \(result.succeededCount) deleted, \(result.failedCount) failed"
            }

        } catch {
            errorMessage = "Delete failed: \(error.localizedDescription)"
        }

        isDeleting = false
    }

    private func toggleSelection(_ item: FileItem) {
        if selectedItems.contains(item.id) {
            selectedItems.remove(item.id)
        } else {
            selectedItems.insert(item.id)
        }
    }

    private func createTestFolder() {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser.path
        let testFolderPath = (homeDir as NSString).appendingPathComponent("MoleUI_Test")

        do {
            // 创建测试文件夹
            try FileManager.default.createDirectory(atPath: testFolderPath, withIntermediateDirectories: true)

            // 创建一些测试文件
            for i in 1...5 {
                let testFile = (testFolderPath as NSString).appendingPathComponent("test_file_\(i).txt")
                try "Test content \(i)".write(toFile: testFile, atomically: true, encoding: .utf8)
            }

            testPath = testFolderPath
            successMessage = "Created test folder: \(testFolderPath)"

        } catch {
            errorMessage = "Failed to create test folder: \(error.localizedDescription)"
        }
    }
}

#Preview {
    FileDeleterTestView()
        .frame(width: 700, height: 700)
}
