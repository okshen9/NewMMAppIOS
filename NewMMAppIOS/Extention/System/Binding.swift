//
//  Binding.swift
//  MMApp
//
//  Created by artem on 21.02.2025.
//

import Combine
import SwiftUI

public extension Binding {
    init(_ source: Binding<Value?>, default defaultValue: Value) {
        self.init(
            get: { source.wrappedValue ?? defaultValue },
            set: { source.wrappedValue = $0 }
        )
    }
}

public extension Binding {
    func orDefault<T>(_ defaultValue: T) -> Binding<T> where Value == T? {
        return Binding<T>(
            get: { self.wrappedValue ?? defaultValue },
            set: { self.wrappedValue = $0 }
        )
    }
}
