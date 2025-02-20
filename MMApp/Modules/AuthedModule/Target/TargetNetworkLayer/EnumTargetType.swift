//
//  EnumTargetType.swift
//  MMApp
//
//  Created by artem on 16.02.2025.
//

import Foundation
import SwiftUICore

/// Категории задач
enum TargetCategory: String, UnknownCasedEnum, JSONRepresentable, CaseIterable {
    case money = "Бизнес"
    case personal = "Личное"
    case family = "Семья"
    case health = "Здоровье"
    case other = "Свободная тема"
    case unknown = "unknown"
    
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

enum TargetStatus: String, UnknownCasedEnum, JSONRepresentable, CaseIterable {
    case unknown = "unknown"
    
    /// Только создано и не получен аппрув для цели от админа.
    case draft = "DRAFT"
    
    /// Цель аппрувнута админом и в прогрессе
    case inProgress = "IN_PROGRESS"
    
    /// Цель успешно завершена в срок.
    case done = "DONE"
    
    /// Успешно завершена цель, но с просрочкой.
    case doneExpired = "DONE_EXPIRED"
    
    /// Цель отменена.
    case cancelled = "CANCELLED"
    
    /// Цель провалена.
    case failed = "FAILED"
    
    /// Цель просрочена.
    case expired = "EXPIRED"
    
    /// Подцель не выполнена
    case notDone = "NOT_DONE"
    
    
    var title: String {
        switch self {
        case .unknown:
            return "инзвестно"
        case .draft:
            return "На рассмотрении"
        case .inProgress:
            return "В процессе"
        case .done:
            return "Завершене"
        case .doneExpired:
            return "Завершена с просрочкой"
        case .cancelled:
            return "Отменена"
        case .failed:
            return "Провалена"
        case .expired:
            return "Просрочена"
        case .notDone:
            return "Не завершена"
        }
    }
}
