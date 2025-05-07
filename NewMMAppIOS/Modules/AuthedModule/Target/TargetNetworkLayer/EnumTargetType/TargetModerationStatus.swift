//
//  TargetModerationStatus.swift
//  NewMMAppIOS
//
//  Created by artem on 07.05.2025.
//

import Foundation

/// Статус запрувлена ли цель
enum TargetModerationStatus: String, UnknownCasedEnum, Codable, JSONRepresentable {
	case unknown = "unknown"
	case DRAFT = "DRAFT"
	case APPROVED = "APPROVED"
	case REJECTED = "REJECTED"
}
