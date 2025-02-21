//
//  Binding.swift
//  MMApp
//
//  Created by artem on 21.02.2025.
//

import Combine
import SwiftUI

extension Binding {
    init(_ source: Binding<Value?>, default defaultValue: Value) {
        self.init(
            get: { source.wrappedValue ?? defaultValue },
            set: { source.wrappedValue = $0 }
        )
    }
}
