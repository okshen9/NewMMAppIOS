//
//  TargetModerationStatus.swift
//  NewMMAppIOS
//
//  Created by artem on 07.05.2025.
//

import Foundation
import SwiftUICore

/// Статус запрувлена ли цель
enum TargetModerationStatus: String, UnknownCasedEnum, Codable, JSONRepresentable {
	case unknown = "unknown"
	case DRAFT = "DRAFT"
	case APPROVED = "APPROVED"
	case REJECTED = "REJECTED"
}

extension TargetModerationStatus {
	/// Локализованное название статуса целевой задачи
	/// - `.DRAFT` → "На рассмотрении"
	/// - `.APPROVED` → "Одобрена"
	/// - `.REJECTED` → "Отклонена"
	var title: String {
		switch self {
		case .DRAFT:
			return "На рассмотрении"
		case .APPROVED:
			return "Одобрена"
		case .REJECTED:
			return "Отклонена"
		default:
			return ""
		}
	}
	
	/// Возвращает детальное описание статуса цели с возможностью указания ментора
	///
	/// Предоставляет расширенное текстовое описание для каждого статуса цели:
	/// - `.DRAFT`: Указывает, что цель находится на рассмотрении
	/// - `.APPROVED`: Информирует о успешной модерации
	/// - `.REJECTED`: Объясняет причину отклонения с рекомендацией
	///
	/// - Parameters:
	///	   - mentor: Опциональный объект ментора указания контакта кому написать
	/// - Returns: Локализованное описание статуса с учетом наличия ментора.
	func description(mentor: UserProfileResultDto? = nil) -> String {
		let metorText = mentor?.username == nil ? "" : " \(mentor!.username!)"
		switch self {
		case .DRAFT:
			return "Цель на рассмотрении у ментора, после одобрения вы сможете приступить к ее выполнению."
		case .APPROVED:
			return "Цел прошла модерацию и доступна для выполнения."
		case .REJECTED:
			return "Цель не прошла модерацию. Скорее всего она составлена не по SMART. Внесите изменения и попробуйте еще раз."
		default:
			return ""
		}
	}
	
	/// Цветовое представление статуса цели
	/// - `.DRAFT`: Оранжевый (требует внимания)
	/// - `.APPROVED`: Зеленый (успешный статус)
	/// - `.REJECTED`: Красный (критический статус)
	var color: Color {
		switch self {
		case .DRAFT:
			return .orange
		case .APPROVED:
			return .green
		case .REJECTED:
			return .red
		default:
			return .orange
		}
	}
	
	/// Локализованное название статуса целевой задачи
	/// - `.DRAFT` → "Открытая ладонь"
	/// - `.APPROVED` → "Палец в верх"
	/// - `.REJECTED` → "Палец вниз"
	var image: String {
		switch self {
		case .DRAFT:
			return "hand.raised"
		case .APPROVED:
			return "hand.thumbsup"
		case .REJECTED:
			return "hand.thumbsdown"
		default:
			return "hand.raised"
		}
	}
}
