//
//  AuthResultModel.swift
//  MMApp
//
//  Created by artem on 18.02.2025.
//

import Foundation

/// Создание сервис реквеста
struct AuthResultModel: Codable {
    // id пользователя
    let externalId: String?
    // роль пользователя
    let role: Roles?
}
