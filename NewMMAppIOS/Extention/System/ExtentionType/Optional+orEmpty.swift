//
//  Optional+orEmpty.swift
//  MMApp
//
//  Created by artem on 18.12.2024.
//

import UIKit
import SwiftUICore

extension String? {
    var orEmpty: String {
        get { self ?? "" }
        set { self = newValue.isEmpty ? nil : newValue }
    }
}

extension String.SubSequence? {
    var orEmpty: String {
        String(self ?? "")
    }
}

extension AttributedString? {
    var orEmpty: AttributedString {
        self ?? AttributedString()
    }
}

extension UIView? {
    /// В случае отсутствия вью - подставляем пустую вью
    var orEmpty: UIView {
        self ?? UIView()
    }
}

extension Binding where Value == String? {
    var asBindingDate: Binding<Date> {
        Binding<Date>(
            get: { (wrappedValue?.dateFromStringISO8601) ?? Date() },
            set: { wrappedValue = $0.toApiString }
        )
    }
    
    var orEmptyBinding: Binding<String> {
        Binding<String>(
            get: { wrappedValue ?? "" },
            set: { wrappedValue = $0.isEmpty ? nil : $0 }
        )
    }
}


extension Bool? {
    var orFalse: Bool {
        self ?? false
    }

    var orTrue: Bool {
        self ?? true
    }
}


extension Int? {
    var orZero: Int {
        self ?? 0
    }
}
