//
//  FormatUtils.swift
//  MoleUI
//
//  Created by 周椿杰 on 2026/2/18.
//

import Foundation

/// 格式化工具类
enum FormatUtils {
    // MARK: - 文件大小格式化

    /// 格式化文件大小
    /// - Parameter bytes: 字节数
    /// - Returns: 格式化后的字符串（如 "1.5 GB"）
    static func formatSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        formatter.includesUnit = true
        formatter.isAdaptive = true
        return formatter.string(fromByteCount: bytes)
    }

    /// 格式化文件大小（精确到小数点后一位）
    /// - Parameter bytes: 字节数
    /// - Returns: 格式化后的字符串
    static func formatSizePrecise(_ bytes: Int64) -> String {
        let units = ["B", "KB", "MB", "GB", "TB", "PB"]
        var size = Double(bytes)
        var unitIndex = 0

        while size >= 1024 && unitIndex < units.count - 1 {
            size /= 1024
            unitIndex += 1
        }

        if unitIndex == 0 {
            return "\(Int(size)) \(units[unitIndex])"
        } else {
            return String(format: "%.1f %@", size, units[unitIndex])
        }
    }

    // MARK: - 日期格式化

    /// 格式化日期为相对时间
    /// - Parameter date: 日期
    /// - Returns: 相对时间字符串（如 "2 hours ago"）
    static func formatRelativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    /// 格式化日期为短格式
    /// - Parameter date: 日期
    /// - Returns: 短格式日期字符串（如 "2026/2/18"）
    static func formatShortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    /// 格式化日期为完整格式
    /// - Parameter date: 日期
    /// - Returns: 完整格式日期字符串（如 "2026年2月18日 12:00:00"）
    static func formatFullDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }

    // MARK: - 数字格式化

    /// 格式化数字（添加千位分隔符）
    /// - Parameter number: 数字
    /// - Returns: 格式化后的字符串（如 "1,234,567"）
    static func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }

    /// 格式化百分比
    /// - Parameter value: 数值（0.0 - 1.0）
    /// - Returns: 百分比字符串（如 "75.5%"）
    static func formatPercentage(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter.string(from: NSNumber(value: value)) ?? "\(Int(value * 100))%"
    }

    // MARK: - 时间间隔格式化

    /// 格式化时间间隔
    /// - Parameter seconds: 秒数
    /// - Returns: 格式化后的字符串（如 "1h 30m 45s"）
    static func formatDuration(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = Int(seconds) / 60 % 60
        let secs = Int(seconds) % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m \(secs)s"
        } else if minutes > 0 {
            return "\(minutes)m \(secs)s"
        } else {
            return "\(secs)s"
        }
    }

    // MARK: - 路径格式化

    /// 简化路径（将用户目录替换为 ~）
    /// - Parameter path: 完整路径
    /// - Returns: 简化后的路径
    static func simplifyPath(_ path: String) -> String {
        let homeDirectory = NSHomeDirectory()
        if path.hasPrefix(homeDirectory) {
            return path.replacingOccurrences(of: homeDirectory, with: "~")
        }
        return path
    }

    /// 获取文件名（不含扩展名）
    /// - Parameter path: 文件路径
    /// - Returns: 文件名
    static func fileName(from path: String) -> String {
        let url = URL(fileURLWithPath: path)
        return url.deletingPathExtension().lastPathComponent
    }
}
