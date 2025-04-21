import SwiftUI
import UIKit
import Foundation

// Глобальный класс для управления алертами
class GlobalAlertManager: ObservableObject {
    static let shared = GlobalAlertManager()
    
    @Published var isPresented = false
    @Published var title = ""
    @Published var message: String?
    @Published var content: AnyView?
    @Published var onConfirm: (() -> Void)?
    @Published var onCancel: (() -> Void)?
    
    private var alertWindow: UIWindow?
    
    private init() {}
    
    func showAlert(
        title: String,
        message: String? = nil,
        content: AnyView? = nil,
        onConfirm: @escaping () -> Void = {},
        onCancel: @escaping () -> Void = {}
    ) {
        DispatchQueue.main.async {
            self.title = title
            self.message = message
            self.content = content
            self.onConfirm = onConfirm
            self.onCancel = onCancel
            self.isPresented = true
            
            // Создаем окно для алерта
            self.createAlertWindow()
        }
    }
    
    func dismiss() {
        DispatchQueue.main.async {
            self.isPresented = false
            self.alertWindow = nil
        }
    }
    
    private func createAlertWindow() {
        // Создаем окно с размером экрана
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.windowLevel = .alert + 1 // Выше обычных окон
        
        // Создаем корневой view для окна
        let rootView = UIHostingController(
            rootView: GlobalAlertView()
                .environmentObject(self)
        )
        
        // Устанавливаем прозрачный фон
        window.backgroundColor = .clear
        window.rootViewController = rootView
        
        // Показываем окно
        window.isHidden = false
        self.alertWindow = window
    }
} 
