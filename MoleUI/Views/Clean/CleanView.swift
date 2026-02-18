//
//  CleanView.swift
//  MoleUI
//
//  Created by 周椿杰 on 2026/2/18.
//

import SwiftUI

struct CleanView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            Text("Clean")
                .font(.largeTitle)
            Text("Deep clean your Mac")
                .foregroundColor(.secondary)
            Text("Coming soon in Sprint 3")
                .font(.caption)
                .foregroundColor(.orange)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    CleanView()
}
