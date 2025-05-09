//
//  ProfileStatsView.swift
//  MMApp
//
//  Created by artem on 04.03.2025.
//

import SwiftUI

struct ProfileStatsView: View {
    let progress: Double
    var lineWidth: CGFloat = 3
    
    var title: String = "Название"
    
    var body: some View {
        VStack(spacing: 8) {
            CircularProgressView(progress: progress, lineWidth: lineWidth)
                .frame(height: 60)
            Text(title)
                .multilineTextAlignment(.center)
                .font(MMFonts.caption)
                .foregroundStyle(Color.headerText)
        }
        .frame(width: 85)
        .padding(4)
    }
}

#Preview {
    ProfileStatsView(progress: 0.5, lineWidth: 4, title: "Вовлек: 20/40 \nTesting")
}
