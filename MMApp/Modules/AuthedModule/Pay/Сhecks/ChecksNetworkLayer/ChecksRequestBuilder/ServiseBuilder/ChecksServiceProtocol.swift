//
//  ChecksServiceProtocol.swift
//  MMApp
//
//  Created by artem on 23.02.2025.
//

import Foundation

/// Создание сервис реквеста
protocol ChecksServiceProtocol {
    /// Получить дату пользователя
    /// - Parameters:
    ///   - model: модель получения истории пользователя
    ///   - id: id пользователя
    /// - Returns: модель пользователя
    func getCheck(model: ChecksBodyModel, id: Int) async throws -> ChecksResultModel
}
