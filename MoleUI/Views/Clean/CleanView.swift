//
//  CleanView.swift
//  MoleUI
//
//  Created by 周椿杰 on 2026/2/18.
//

import SwiftUI

struct CleanView: View {

    @StateObject private var viewModel = CleanViewModel()
    @State private var showCleanConfirm: Bool = false

    var body: some View {
        HSplitView {
            // 左侧：类别列表 + 操作栏
            leftPanel
                .frame(minWidth: 280, maxWidth: 320)

            // 右侧：文件列表
            rightPanel
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .alert("Confirm Clean", isPresented: $showCleanConfirm) {
            Button("Move to Trash", role: .destructive) {
                Task { await viewModel.cleanSelected(moveToTrash: true) }
            }
            Button("Delete Permanently", role: .destructive) {
                Task { await viewModel.cleanSelected(moveToTrash: false) }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(
                "Delete \(viewModel.selectedItems.count) items " +
                "(\(FormatUtils.formatSize(viewModel.selectedSize)))?"
            )
        }
    }

    // MARK: - Left Panel

    private var leftPanel: some View {
        VStack(spacing: 0) {
            // 顶部操作栏
            VStack(spacing: 12) {
                // 扫描按钮
                Button(action: {
                    Task { await viewModel.scanAll() }
                }) {
                    Label(
                        viewModel.isScanning ? "Scanning…" : "Scan All",
                        systemImage: viewModel.isScanning ? "rays" : "magnifyingglass"
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isScanning || viewModel.isCleaning)
                .controlSize(.large)

                // 扫描进度条
                if viewModel.isScanning {
                    VStack(alignment: .leading, spacing: 4) {
                        ProgressView(value: viewModel.scanProgress)

                        if let cat = viewModel.scanningCategory {
                            Text("Scanning \(cat.displayName)…")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // 总大小摘要
                if viewModel.hasResults {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Found")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(FormatUtils.formatSize(viewModel.totalScannedSize))
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        Spacer()
                        Button("Select All") { viewModel.selectAll() }
                            .buttonStyle(.bordered)
                            .font(.caption)
                    }
                }
            }
            .padding()

            Divider()

            // 类别列表
            List(CleanCategory.allCases) { category in
                CategoryRowView(
                    category: category,
                    result: viewModel.categoryResults[category],
                    selectedCount: viewModel.selectedCount(in: category),
                    isScanning: viewModel.scanningCategory == category
                ) {
                    viewModel.selectAll(in: category)
                } onDeselect: {
                    viewModel.deselectAll(in: category)
                }
            }
            .listStyle(.sidebar)

            Divider()

            // 底部清理按钮
            VStack(spacing: 8) {
                if viewModel.isCleaning {
                    VStack(spacing: 4) {
                        ProgressView(value: viewModel.cleanProgress)
                        Text("Cleaning…")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else if let result = viewModel.lastCleanResult {
                    CleanResultBannerView(result: result)
                }

                Button(action: { showCleanConfirm = true }) {
                    Label(
                        "Clean \(viewModel.selectedItems.count) Items (\(FormatUtils.formatSize(viewModel.selectedSize)))",
                        systemImage: "trash"
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .disabled(!viewModel.hasSelection || viewModel.isCleaning || viewModel.isScanning)
                .controlSize(.large)
            }
            .padding()
        }
    }

    // MARK: - Right Panel

    private var rightPanel: some View {
        Group {
            if viewModel.isScanning {
                scanningPlaceholder
            } else if !viewModel.hasResults {
                emptyPlaceholder
            } else {
                fileListView
            }
        }
    }

    private var emptyPlaceholder: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("Click \"Scan All\" to find junk files")
                .font(.title3)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var scanningPlaceholder: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            if let cat = viewModel.scanningCategory {
                Text("Scanning \(cat.displayName)…")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var fileListView: some View {
        VStack(spacing: 0) {
            // 表头
            HStack {
                Text("File")
                    .fontWeight(.semibold)
                Spacer()
                Text("Category")
                    .fontWeight(.semibold)
                    .frame(width: 130)
                Text("Size")
                    .fontWeight(.semibold)
                    .frame(width: 80, alignment: .trailing)
            }
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.horizontal)
            .padding(.vertical, 6)
            .background(Color(nsColor: .controlBackgroundColor))

            Divider()

            List(viewModel.allItems) { item in
                CleanItemRowView(
                    item: item,
                    isSelected: viewModel.selectedItems.contains(item.id)
                ) {
                    viewModel.toggleSelection(item)
                }
            }
            .listStyle(.plain)
        }
    }
}

// MARK: - Category Row

private struct CategoryRowView: View {
    let category: CleanCategory
    let result: CategoryScanResult?
    let selectedCount: Int
    let isScanning: Bool
    let onSelect: () -> Void
    let onDeselect: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: category.icon)
                .frame(width: 20)
                .foregroundColor(.accentColor)

            VStack(alignment: .leading, spacing: 2) {
                Text(category.displayName)
                    .font(.body)

                if isScanning {
                    Text("Scanning…")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else if let result {
                    Text("\(result.itemCount) items · \(FormatUtils.formatSize(result.totalSize))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text(category.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            // 选中数量
            if selectedCount > 0 {
                Text("\(selectedCount)")
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.accentColor.opacity(0.15))
                    .cornerRadius(10)
                    .foregroundColor(.accentColor)
            }

            // 全选/取消按钮
            if let result, !result.isEmpty {
                Menu {
                    Button("Select All") { onSelect() }
                    Button("Deselect All") { onDeselect() }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.secondary)
                }
                .menuStyle(.borderlessButton)
                .frame(width: 24)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Clean Item Row

private struct CleanItemRowView: View {
    let item: CleanItem
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Button(action: onToggle) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .accentColor : .secondary)
            }
            .buttonStyle(.plain)

            Image(systemName: item.isDirectory ? "folder.fill" : "doc.fill")
                .foregroundColor(item.isDirectory ? .blue : .gray)
                .frame(width: 16)

            VStack(alignment: .leading, spacing: 1) {
                Text(item.name)
                    .font(.body)
                    .lineLimit(1)

                Text(FormatUtils.simplifyPath(item.path))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Text(item.category.displayName)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 130, alignment: .trailing)
                .lineLimit(1)

            Text(FormatUtils.formatSize(item.size))
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .trailing)
        }
        .padding(.vertical, 2)
        .contentShape(Rectangle())
        .onTapGesture { onToggle() }
    }
}

// MARK: - Clean Result Banner

private struct CleanResultBannerView: View {
    let result: CleanResult

    var body: some View {
        HStack {
            Image(systemName: result.isAllSucceeded ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                .foregroundColor(result.isAllSucceeded ? .green : .orange)

            if result.isAllSucceeded {
                Text("Freed \(FormatUtils.formatSize(result.freedBytes))")
                    .font(.caption)
                    .foregroundColor(.green)
            } else {
                Text("\(result.succeededCount) freed · \(result.failedCount) failed")
                    .font(.caption)
                    .foregroundColor(.orange)
            }

            Spacer()
        }
        .padding(8)
        .background(
            (result.isAllSucceeded ? Color.green : Color.orange).opacity(0.1)
        )
        .cornerRadius(6)
    }
}

#Preview {
    CleanView()
        .frame(width: 900, height: 700)
}
