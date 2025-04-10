//
//  CircularProgressView.swift
//  MMApp
//
//  Created by artem on 04.03.2025.
//


import SwiftUI

struct CircularProgressView: View {
    @State private var animatedProgress: CGFloat = 0.0
    @State private var glowOpacity: Double = 0.3 // Для анимации свечения
    var progress: CGFloat // От 0.0 до 1.0
    
    var lineWidth: CGFloat = 8

    var body: some View {
        ZStack {
            // Фоновый серый круг
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 8)

            // Свечение (размытый круг)
            Circle()
                .trim(from: 0.0, to: animatedProgress)
                .stroke(
                    Color.mainRed.opacity(glowOpacity),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .blur(radius: 4) // Дает эффект свечения
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1.5), value: animatedProgress)

            // Прогресс-бар
            Circle()
                .trim(from: 0.0, to: animatedProgress)
                .stroke(
                    Color.mainRed,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 1.5), value: animatedProgress)

            // Текст с процентами
            Text("\(Int(progress * 100))%")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.black.opacity(0.7))
        }
        .onAppear {
            animatedProgress = progress > 1.0 ? 1.0 : progress
            withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                glowOpacity = 0.7 // Плавное мерцание свечения
            }
        }
    }
}


#Preview {
    CircularProgressView(progress: 0.5, lineWidth: 4)
}
