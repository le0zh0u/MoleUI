//
//  Tab.swift
//  MoleUI
//
//  Created by 周椿杰 on 2026/2/18.
//

import Foundation

enum Tab: String, CaseIterable, Identifiable {
    case clean = "Clean"
    case uninstall = "Uninstall"
    case optimize = "Optimize"
    case analyze = "Analyze"
    case status = "Status"
    case purge = "Purge"
    case installer = "Installer"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .clean:
            return "sparkles"
        case .uninstall:
            return "trash"
        case .optimize:
            return "gearshape.2"
        case .analyze:
            return "chart.pie"
        case .status:
            return "chart.bar"
        case .purge:
            return "folder.badge.minus"
        case .installer:
            return "shippingbox"
        }
    }

    var description: String {
        switch self {
        case .clean:
            return "Deep clean your Mac"
        case .uninstall:
            return "Remove apps completely"
        case .optimize:
            return "Optimize system performance"
        case .analyze:
            return "Analyze disk usage"
        case .status:
            return "Monitor system health"
        case .purge:
            return "Clean project artifacts"
        case .installer:
            return "Remove installer files"
        }
    }
}
