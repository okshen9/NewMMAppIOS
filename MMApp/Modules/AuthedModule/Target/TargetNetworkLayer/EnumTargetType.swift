//
//  EnumTargetType.swift
//  MMApp
//
//  Created by artem on 16.02.2025.
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

enum TargetStatus: String, UnknownCasedEnum, JSONRepresentable, CaseIterable, Equatable {
    /// Цель успешно завершена в срок.
    case done = "DONE"
    
    // Другие
    case unknown = "unknown"
    
    /// Только создано и не получен аппрув для цели от админа.
    case draft = "DRAFT"
    
    /// Цель аппрувнута админом и в прогрессе
    case inProgress = "IN_PROGRESS"
    
    /// Успешно завершена цель, но с просрочкой.
    case doneExpired = "DONE_EXPIRED"
    
    /// Цель отменена.
    case cancelled = "CANCELLED"
    
    /// Цель провалена.
    case failed = "FAILED"
    
    /// Цель просрочена.
    case expired = "EXPIRED"
    
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
        }
    }
    
    mutating func changeSelf() {
        self = switch self {
        case .done, .doneExpired:
            TargetStatus.inProgress
        case .draft, .expired, .inProgress, .cancelled, .unknown, .failed:
            TargetStatus.done
        }
    }
    
    var isDone: Bool {
        return switch self {
        case .done, .doneExpired:
            true
        case .draft, .expired, .inProgress, .cancelled:
            false
        default:
            false
        }
    }
}


enum TargetSubStatus: String, UnknownCasedEnum, JSONRepresentable, CaseIterable, Equatable {
    // Для целей и подцелей
    /// Подцель не выполнена
    case notDone = "NOT_DONE"
    /// Цель успешно завершена в срок.
    case done = "DONE"
    
    
    // Другие
    case unknown = "unknown"
    

    var title: String {
        switch self {
        case .unknown:
            return "инзвестно"
        case .done:
            return "Завершене"
        case .notDone:
            return "Не завершена"
        }
    }
    
    mutating func changeSelfStatus() {
        self = self == .done ? .notDone : .done
    }
    
    var isDone: Bool {
        return switch self {
        case .done:
            true
        case .notDone, .unknown:
            false
        }
    }
}
