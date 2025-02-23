//
//  PayRequestRequestProtocol.swift
//  MMApp
//
//  Created by artem on 23.02.2025.
//

import Foundation

protocol PayRequestRequestProtocol {
    /// Получить дату пользователя
    /// - Parameters:
    ///   - model: модель получения истории пользователя
    ///   - id: id пользователя
    /// - Returns: подготовленный запрос
    func getDataRequest(model: PayRequestBodyModel, id: Int) throws -> URLRequest
}
