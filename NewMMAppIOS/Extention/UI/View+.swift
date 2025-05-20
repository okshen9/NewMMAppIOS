//
//  View+.swift
//  NewMMAppIOS
//
//  Created by artem on 19.05.2025.
//

import Foundation
import SwiftUI
import UIKit

extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
    
    func frameRect(_ value: CGFloat, alignment: Alignment = .center) -> some View {
        self
            .frame(width: value, height: value, alignment: alignment)
    }
    
    func asUIImage() -> UIImage {
        let renderer = ImageRenderer(content: self)
        
        // Укажите желаемый размер (например, размер контента)
        renderer.proposedSize = ProposedViewSize(width: 100, height: 100)
        
        // Конвертируем в UIImage
        return renderer.uiImage!
    }
    
    /// превращаем View в  UIMage
    func snapshot() -> UIImage {
        let hostingController = UIHostingController(rootView: self)
        let targetSize = hostingController.view.intrinsicContentSize
        hostingController.view.bounds = CGRect(origin: .zero, size: targetSize)
        hostingController.view.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            hostingController.view.drawHierarchy(in: hostingController.view.bounds, afterScreenUpdates: true)
        }
    }
}
