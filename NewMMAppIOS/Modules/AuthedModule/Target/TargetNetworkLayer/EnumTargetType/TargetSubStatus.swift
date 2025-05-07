//
//  TargetSubStatus.swift
//  MMApp
//
//  Created by artem on 15.03.2025.
//

import Foundation
import SwiftUICore

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
