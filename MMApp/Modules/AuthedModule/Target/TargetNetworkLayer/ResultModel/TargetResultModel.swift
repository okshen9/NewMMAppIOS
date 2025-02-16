//
//  TargetResultModel.swift
//  MMApp
//
//  Created by artem on 16.02.2025.
//

import Foundation

/// Создание сервис реквеста
struct TargetResultModel: Codable {
    // id пользователя
    let externalId: String?
    // роль пользователя
    let role: Roles?
}
