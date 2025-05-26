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
    
    /// Отправить жалобу на пользователя
    /// - Parameter message: текст жалобы
    /// - Parameter userId: id пользователя
    /// - Returns: успешность отправки
    func sendReport(_ message: String, userId: Int)  async throws -> ComplaintResult {
        try await performRequest {
            try apiFactory.sendComplaintRequest(model: .init(message: message, toUserExtId: userId))
        }
    }
}
