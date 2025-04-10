//
//  TargetCategory.swift
//  MMApp
//
//  Created by artem on 15.03.2025.
//

import Foundation
import SwiftUICore

/// Категории задач
enum TargetCategory: String, UnknownCasedEnum, JSONRepresentable, CaseIterable, Equatable, Identifiable {
    case money = "Бизнес"
    case personal = "Личное"
    case family = "Семья"
    case health = "Здоровье"
    case other = "Свободная тема"
    case unknown = "unknown"
    
    var id: String { rawValue }
    
    var color: Color {
        switch self {
        case .money:
                .yellow
        case .personal:
                .blue
        case .family:
                .mainRed
        case .health:
                .green
        case .unknown:
                .purple
        case .other:
                .cyan
        }
    }
}
