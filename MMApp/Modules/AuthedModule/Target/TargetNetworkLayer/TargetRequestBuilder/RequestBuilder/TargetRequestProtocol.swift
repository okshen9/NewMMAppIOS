//
//  TargetRequestProtocol.swift
//  MMApp
//
//  Created by artem on 16.02.2025.
//

import Foundation

protocol TargetRequestProtocol {
    /// Получить дату пользователя
    /// - Parameters:
    ///   - model: модель получения истории пользователя
    ///   - id: id пользователя
    /// - Returns: подготовленный запрос
    func getDataRequest(model: TargetBodyModel, id: Int) throws -> URLRequest
}
