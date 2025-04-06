//
//  UIViewControllerSUI.swift
//  MMApp
//
//  Created by artem on 06.04.2025.
//

import Foundation
import SwiftUI

// Создаем SwiftUI-обертку для UIKit-контроллера
struct UIViewControllerSUI<VC: UIViewController>: UIViewControllerRepresentable {
    // Замыкание для передачи данных
    var onDismiss: () -> Void

    // Создаем контроллер
    func makeUIViewController(context: Context) -> VC {
        let controller = VC()
        controller.view.backgroundColor = .blue
        return controller
    }

    // Обновляем контроллер (не требуется в этом примере)
    func updateUIViewController(_ uiViewController: VC, context: Context) {}

    // Координатор для обработки делегатов
    func makeCoordinator() -> Coordinator {
        Coordinator(onDismiss: onDismiss)
    }

    class Coordinator {
        var onDismiss: () -> Void

        init(onDismiss: @escaping () -> Void) {
            self.onDismiss = onDismiss
        }
    }
}
