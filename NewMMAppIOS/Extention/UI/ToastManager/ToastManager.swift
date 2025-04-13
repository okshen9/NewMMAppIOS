//
//  ToastManager.swift
//  MMApp
//
//  Created by artem on 02.03.2025.
//


import SwiftUI

/// Глобальный менеджер для управления тостом
final class ToastManager: ObservableObject {
    var analyticStack: [String] = []

    static let shared = ToastManager()
    
    @Published var toast: ToastModel? = nil
    let testNotification = NSNotification.Name(rawValue: "testNotification")

    private init() {
        //TODO
        NotificationCenter.default.addObserver(self, selector: #selector(notifificationReceived), name: testNotification, object: nil)
    }

    func show(_ toast: ToastModel) async {
        await MainActor.run {
            self.toast = toast
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + toast.duration) {
            withAnimation {
                self.toast = nil
            }
        }
    }

    //TODO
    @objc func notifificationReceived(_ theNotificaiton: Notification) {
        print("Notification received")
        if let parsedInfo = theNotificaiton.object as? NotyInfo {
            analyticStack.append(parsedInfo.displayMessage)
        } else {
            analyticStack.append("Не удалось расспарсить: \(theNotificaiton.description)")
        }

    }
}

extension View {
    func withToast() -> some View {
        self.modifier(ToastModifier())
    }
}
