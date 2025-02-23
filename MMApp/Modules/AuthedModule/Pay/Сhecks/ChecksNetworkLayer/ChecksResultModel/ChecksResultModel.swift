//
//  ChecksResultModel.swift
//  MMApp
//
//  Created by artem on 23.02.2025.
//

import Foundation

/// Создание сервис реквеста
struct ChecksResultModel: Codable {
    // id пользователя
    let externalId: String?
    // роль пользователя
    let role: Roles?
}
