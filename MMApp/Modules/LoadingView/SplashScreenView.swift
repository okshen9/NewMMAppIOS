//
//  SplashScreenView.swift
//  MMApp
//
//  Created by artem on 20.02.2025.
//

import SwiftUI


struct LoadingViewScreenView: View {
    @State private var scale: CGFloat = 0.5 // Масштаб логотипа
    @State private var opacity: Double = 0 // Прозрачность логотипа
    
    var body: some View {
        ZStack {
            // Фон экрана загрузки
            Color(.systemBackground)
                .ignoresSafeArea()
            
            // Логотип
            Image(.MM) // Замените на ваш логотип
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.mainRed)
                .scaleEffect(scale)
                .opacity(opacity)
                .onAppear {
                    // Анимация появления логотипа
                    withAnimation(.easeInOut(duration: 1.5)) {
                        scale = 1.0
                        opacity = 1.0
                    }
                }
            
            // Индикатор загрузки
            VStack {
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .mainRed))
                    .scaleEffect(1.5)
                    .padding(.bottom, 50)
            }
        }
    }
}

struct LoadingViewScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingViewScreenView()
    }
}
