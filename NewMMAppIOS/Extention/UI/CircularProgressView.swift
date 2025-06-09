//
//  CircularProgressView.swift
//  MMApp
//
//  Created by artem on 04.03.2025.
//


import SwiftUI

struct CircularProgressView: View {
    @State private var animatedProgress: CGFloat = 0.0
    @State private var glowOpacity: Double = 0.3
    @State private var isPulsing: Bool = false
    var progress: CGFloat
    var lineWidth: CGFloat = 8
    var color: Color = .mainRed
    
    var body: some View {
        ZStack {
            // Фоновый круг с градиентом
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [color.opacity(0.2), color.opacity(0.1)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: lineWidth
                )
            
            // Свечение с пульсацией
            Circle()
                .trim(from: 0.0, to: animatedProgress)
                .stroke(
                    color.opacity(glowOpacity),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .blur(radius: 4)
                .rotationEffect(.degrees(-90))
                .scaleEffect(isPulsing ? 1.05 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true),
                    value: isPulsing
                )
            
            // Основной прогресс-бар с градиентом
            Circle()
                .trim(from: 0.0, to: animatedProgress)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [color, color.opacity(0.8)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 1.0, dampingFraction: 0.8), value: animatedProgress)
            
            // Текст с процентами
            Text("\(Int(progress * 100))%")
                .font(MMFonts.body)
                .foregroundColor(.black.opacity(0.7))
                .scaleEffect(isPulsing ? 1.1 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true),
                    value: isPulsing
                )
        }
        .onAppear {
            animatedProgress = progress > 1.0 ? 1.0 : progress
            withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                glowOpacity = 0.7
                isPulsing = true
            }
        }
    }
}

