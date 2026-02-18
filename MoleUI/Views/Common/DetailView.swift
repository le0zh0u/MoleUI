//
//  DetailView.swift
//  MoleUI
//
//  Created by 周椿杰 on 2026/2/18.
//

import SwiftUI

struct DetailView: View {
    let tab: Tab

    var body: some View {
        Group {
            switch tab {
            case .clean:
                CleanView()
            case .uninstall:
                UninstallView()
            case .optimize:
                OptimizeView()
            case .analyze:
                AnalyzeView()
            case .status:
                StatusView()
            case .purge:
                PurgeView()
            case .installer:
                InstallerView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    DetailView(tab: .clean)
}
