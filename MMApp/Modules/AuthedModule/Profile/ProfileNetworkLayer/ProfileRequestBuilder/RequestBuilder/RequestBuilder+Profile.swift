//
//  RequestBuilder+Profile.swift
//  MMApp
//
//  Created by artem on 24.02.2025.
//

import Foundation

/// Создание сервис реквеста
extension APIFactory :ProfileRequestProtocol {
    /// Получить дату пользователя
    /// - Parameters:
    ///   - model: модель получения истории пользователя
    ///   - id: id пользователя
    /// - Returns: подготовленный запрос
    func getDataRequest(model: ProfileBodyModel, id: Int) throws -> URLRequest {
        let helper = ProfileRequestHelper.getData(id: id)
        let url = try urlBuilder.buildURL(path: helper.path)

        let urlRequest = try requestBuilder.buildJSONParamsRequest(
            url: url,
            bodyModel: model,
            query: helper.query,
            method: helper.method,
            tokenNeccessity: .mandatory
        )
        return urlRequest
        
//        let urlRequest = try requestBuilder.buildURLRequest(
//            url: url,
//            query: helper.query,
//            method: helper.method)
//        return try await dataTaskBuilder.buildDataTask(urlRequest).response
    }
}
