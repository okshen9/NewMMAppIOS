//
//  ChecksRequestProtocol.swift
//  MMApp
//
//  Created by artem on 23.02.2025.
//

import Foundation

protocol ChecksRequestProtocol {
    /// Получить дату пользователя
    /// - Parameters:
    ///   - model: модель получения истории пользователя
    ///   - id: id пользователя
    /// - Returns: подготовленный запрос
    func getCkeckRequest(model: ChecksBodyModel, id: Int) throws -> URLRequest
    
}
