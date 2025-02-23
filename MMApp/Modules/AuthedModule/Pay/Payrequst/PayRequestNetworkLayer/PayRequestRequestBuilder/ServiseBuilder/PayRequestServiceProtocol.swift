//
//  PayRequestServiceProtocol.swift
//  MMApp
//
//  Created by artem on 23.02.2025.
//

import Foundation

/// Создание сервис реквеста
protocol PayRequestServiceProtocol {
    /// Получить дату пользователя
    /// - Parameters:
    ///   - model: модель получения истории пользователя
    ///   - id: id пользователя
    /// - Returns: модель пользователя
    func getData(model: PayRequestBodyModel, id: Int) async throws -> PaymentRequestResponseDto
}
