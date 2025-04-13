//
//  ToastModifier.swift
//  MMApp
//
//  Created by artem on 02.03.2025.
//

import SwiftUI

struct ToastModifier: ViewModifier {
    @ObservedObject var toastManager = ToastManager.shared
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if let toast = toastManager.toast {
                VStack {
                    Spacer()
                    HStack {
                        if let icon = toast.icon {
                            Image(systemName: icon)
                                .foregroundColor(.white)
                        }
                        Text(toast.message)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(10)
                    .padding(.bottom, 50)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: toastManager.toast)
    }
}

#Preview {
    Button("Показать тост") {
        Task {
            await ToastManager.shared.show(
                ToastModel(message: "Цель закрыта 🎯", icon: "xmark.app", duration: 2)
            )
        }
    }
    .withToast()
}

