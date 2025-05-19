//
//  View+.swift
//  NewMMAppIOS
//
//  Created by artem on 19.05.2025.
//

import Foundation
import SwiftUI

extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
    
    func frameRect(_ value: CGFloat, alignment: Alignment = .center) -> some View {
        self
            .frame(width: value, height: value, alignment: alignment)
    }
}
