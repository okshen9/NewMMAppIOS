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
    
    func orDefault<T>(_ defaultValue: T) -> Binding<T> where Value == Optional<T> {
        return Binding<T>.init(
            get: { self.wrappedValue.self ?? defaultValue },
            set: { self.wrappedValue = $0 }
        )
    }
}
