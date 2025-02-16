//
//  RequestBuilder+Target.swift
//  MMApp
//
//  Created by artem on 16.02.2025.
//

import Foundation

/// Создание сервис реквеста
extension APIFactory: TargetRequestProtocol {
    /// Получить дату пользователя
    /// - Parameters:
    ///   - model: модель получения истории пользователя
    ///   - id: id пользователя
    /// - Returns: подготовленный запрос
    func getDataRequest(model: TargetBodyModel, id: Int) throws -> URLRequest {
        let helper = TargetRequestHelper.getData(id: id)
        let url = try urlBuilder.buildURL(path: helper.path)

        let urlRequest = try requestBuilder.buildJSONParamsRequest(
            url: url,
            bodyModel: model,
            query: helper.query,
            method: helper.method,
            tokenNeccessity: .mandatory
        )
        return urlRequest
    }
}
