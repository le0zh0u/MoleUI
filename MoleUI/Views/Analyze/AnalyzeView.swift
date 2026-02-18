//
//  AnalyzeView.swift
//  MoleUI
//
//  Created by 周椿杰 on 2026/2/18.
//

import SwiftUI

struct AnalyzeView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.pie")
                .font(.system(size: 60))
                .foregroundColor(.purple)
            Text("Analyze")
                .font(.largeTitle)
            Text("Analyze disk usage")
                .foregroundColor(.secondary)
            Text("Coming soon in Sprint 6")
                .font(.caption)
                .foregroundColor(.orange)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    AnalyzeView()
}
