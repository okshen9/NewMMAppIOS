//
//  TargetCategory.swift
//  MMApp
//
//  Created by artem on 15.03.2025.
//

import Foundation
import SwiftUI

/// Категории задач
enum TargetCategory: String, UnknownCasedEnum, JSONRepresentable, CaseIterable, Equatable, Identifiable {
    case money = "Бизнес"
    case personal = "Личное"
    case family = "Семья"
    case health = "Здоровье"
    case other = "Свободная тема"
    case unknown = "unknown"
    
    var id: String {
        switch self {
        case .money: return "Бизнес"
        case .personal: return "Личное"
        case .family: return "Семья"
        case .health: return "Здоровье"
        case .other: return "Свободная тема"
        case .unknown: return "unknown"
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        switch rawValue {
        case "Бизнес", "BUSINESS": self = .money
        case "Личное", "PERSONAL": self = .personal
        case "Семья", "FAMILY": self = .family
        case "Здоровье", "HEALTH": self = .health
        case "Свободная тема", "FREE TOPIC": self = .other
        default: self = .unknown
        }
    }
    
    init(rawValue: String) {
        switch rawValue {
        case "Бизнес", "BUSINESS": self = .money
        case "Личное", "PERSONAL": self = .personal
        case "Семья", "FAMILY": self = .family
        case "Здоровье", "HEALTH": self = .health
        case "Свободная тема", "FREE TOPIC": self = .other
        default: self = .unknown
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(id)
    }

    var color: Color {
        switch self {
        case .money:
            return .yellow
        case .personal:
            return .blue
        case .family:
            return Color.mainRed
        case .health:
            return .green
        case .other:
            return .cyan
        case .unknown:
            return .purple
        }
    }
}

extension TargetCategory? {
	func orDefault(_ defaultValue: TargetCategory) -> TargetCategory {
		self ?? defaultValue
	}
}
