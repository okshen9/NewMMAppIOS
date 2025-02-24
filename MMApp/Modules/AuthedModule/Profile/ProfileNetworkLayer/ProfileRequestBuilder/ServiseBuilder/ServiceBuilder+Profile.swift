//
//  ServiceBuilder+Profile.swift
//  MMApp
//
//  Created by artem on 24.02.2025.
//

import Foundation

/// Создание сервис реквеста
extension ServiceBuilder: ProfileServiceProtocol {
    /// Получить дату пользователя
    /// - Parameters:
    ///   - model: модель получения истории пользователя
    ///   - id: id пользователя
    /// - Returns: модель пользователя
    func getData(model: ProfileBodyModel, id: Int) async throws -> UserProfileWithAuthData {
        try await performRequest {
            try apiFactory.getDataRequest(model: model, id: id)
        }
    }
}
