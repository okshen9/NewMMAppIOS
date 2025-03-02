//
//  ToastManager.swift
//  MMApp
//
//  Created by artem on 02.03.2025.
//


import SwiftUI

/// Глобальный менеджер для управления тостом
final class ToastManager: ObservableObject {
    static let shared = ToastManager()
    
    @Published var toast: ToastModel? = nil
    
    private init() {}

    func show(_ toast: ToastModel) {
        self.toast = toast
        
        DispatchQueue.main.asyncAfter(deadline: .now() + toast.duration) {
            withAnimation {
                self.toast = nil
            }
        }
    }
}

extension View {
    func withToast() -> some View {
        self.modifier(ToastModifier())
    }
}
