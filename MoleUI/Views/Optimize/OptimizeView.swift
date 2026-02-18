//
//  OptimizeView.swift
//  MoleUI
//
//  Created by 周椿杰 on 2026/2/18.
//

import SwiftUI

struct OptimizeView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "gearshape.2")
                .font(.system(size: 60))
                .foregroundColor(.green)
            Text("Optimize")
                .font(.largeTitle)
            Text("Optimize system performance")
                .foregroundColor(.secondary)
            Text("Coming soon in Sprint 8")
                .font(.caption)
                .foregroundColor(.orange)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    OptimizeView()
}
