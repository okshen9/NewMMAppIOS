//
//  ShimmerView.swift
//  MMApp
//
//  Created by artem on 22.02.2025.
//


import SwiftUI

/// Шиммерящий прямоугольник
struct ShimmeringRectangle: View {
    @State private var move = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.gray.opacity(0.3))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .fill(shimmerGradient)
                    .mask(RoundedRectangle(cornerRadius: 8))
                    .offset(x: move ? 200 : -200)
            )
            .onAppear {
                withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    move.toggle()
                }
            }
    }
    
    private var shimmerGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.white.opacity(0),
                Color.white.opacity(0.4),
                Color.white.opacity(0)
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}


