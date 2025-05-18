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
	///  Просрочено
	case expired = "EXPIRED"
	/// Выполнено c просрочкой
	case expiredDone = "EXPIRED_DONE"
	/// в процессе
	case inProgress = "IN_PROGRESS"
	/// провалена
	case failed = "FAILED"
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
		case .expired:
			return "Просрочено"
		case .expiredDone:
			return "Выполненно с просрочной"
		case .inProgress:
			return "В процессе"
		case .failed:
			return "Провалено"
		}
    }
    
    mutating func changeSelfStatus() {
		if self.isDone {
			self = .inProgress
		} else {
			self = .done
		}
    }
    
    var isDone: Bool {
        return switch self {
		case .done, .expiredDone:
            true
		case .notDone, .unknown, .expired, .inProgress, .failed:
            false
		}
    }
}
