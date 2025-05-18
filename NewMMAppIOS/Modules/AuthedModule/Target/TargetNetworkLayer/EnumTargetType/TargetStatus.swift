//
//  TargetStatus.swift
//  MMApp
//
//  Created by artem on 15.03.2025.
//

import Foundation
import SwiftUICore

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
	
	init(from decoder: any Decoder) throws {
		let container = try decoder.singleValueContainer()
		let tampValue = try container.decode(String.self)
		if tampValue == Self.draft.rawValue {
			self = .inProgress
		} else {
			self = Self(rawValue: tampValue)
		}
			
	}
}

extension TargetStatus {
	/// Описание статуса
    var title: String {
        switch self {
        case .unknown:
            return "Статус неизвестен"
        case .draft:
            return "На рассмотрении"
        case .inProgress:
            return "В процессе"
        case .done:
            return "Завершена"
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

    /// Подробное описание статуса
    var description: String {
        switch self {
        case .draft:
            return "Цель создана и ожидает рассмотрения ментором. После одобрения вы сможете приступить к выполнению."
        case .inProgress:
            return "Цель в процессе выполнения. Вы можете отслеживать прогресс и вносить изменения по согласованию ментора."
        case .done:
            return "Цель успешно достигнута в заданные сроки. Поздравляем с выполнением!"
        case .doneExpired:
            return "Цель выполнена, но с задержкой. Постарайтесь планировать время точнее в будущем."
        case .cancelled:
            return "Цель отменена. Вы можете создать новую цель или изменить текущие условия."
        case .failed:
            return "Цель провалена. Не удалось достичь намеченных результатов."
        case .expired:
            return "Срок выполнения цели истёк. Надо удвоить усилия и закрыть её!"
        case .unknown:
            return "Статус цели неизвестен. Обратитесь к метору для уточнения информации."
        }
    }
	
	var targetIcon: String {
		switch self {
		case .inProgress:
			return "star"
		case .done:
			return "star.fill"
		case .doneExpired:
			return "star.leadinghalf.filled"
		case .expired:
			return "calendar.badge.clock"
		case .draft:
			return "hand.raised.fill"
		case .cancelled, .failed:
			return "star.slash.fill"
		case .unknown:
			return "questionmark.diamond.fill"
		}
	}
	
	/// Получить цвет для иконки цели в зависимости от статуса
	var tagetColor: Color {
		switch self {
		case .inProgress:
			return .green
		case .done, .doneExpired:
			return .green
		case .expired:
			return .orange
		default:
			return .green
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
	
	static var valueCases: [TargetStatus] {
		return [.inProgress, .done, .expired, .doneExpired, .cancelled, .failed]
	}
}
