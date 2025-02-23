//
//  ServiceBuilder+Checks.swift
//  MMApp
//
//  Created by artem on 23.02.2025.
//

import Foundation

/// Создание сервис реквеста
extension ServiceBuilder: ChecksServiceProtocol {
    /// Получить дату пользователя
    /// - Parameters:
    ///   - model: модель получения истории пользователя
    ///   - id: id пользователя
    /// - Returns: модель пользователя
    func getData(model: ChecksBodyModel, id: Int) async throws -> ChecksResultModel {
        try await performRequest {
            try apiFactory.getDataRequest(model: model, id: id)
        }
    }
}
