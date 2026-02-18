//
//  StatusView.swift
//  MoleUI
//
//  Created by 周椿杰 on 2026/2/18.
//

import SwiftUI

struct StatusView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar")
                .font(.system(size: 60))
                .foregroundColor(.cyan)
            Text("Status")
                .font(.largeTitle)
            Text("Monitor system health")
                .foregroundColor(.secondary)
            Text("Coming soon in Sprint 7")
                .font(.caption)
                .foregroundColor(.orange)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    StatusView()
}
