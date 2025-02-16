//
//  TargetServiceProtocol.swift
//  MMApp
//
//  Created by artem on 16.02.2025.
//

import Foundation

/// Создание сервис реквеста
protocol TargetServiceProtocol {
    /// Получить дату пользователя
    /// - Parameters:
    ///   - model: модель получения истории пользователя
    ///   - id: id пользователя
    /// - Returns: модель пользователя
    func getData(model: TargetBodyModel, id: Int) async throws -> TargetResultModel
}
