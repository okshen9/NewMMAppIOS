//
//  RequestBuilder+Target.swift
//  MMApp
//
//  Created by artem on 16.02.2025.
//

import Foundation

/// Создание сервис реквеста
extension APIFactory: TargetRequestProtocol {
    /// Создать цель
    /// - Parameters:
    ///   - model: модель получения истории пользователя
    ///   - id: id пользователя
    /// - Returns: подготовленный запрос
    func createUserTarget(model: CreateUserTargetBodyModel) throws -> URLRequest {
        let helper = TargetRequestHelper.createUserTarget
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
    
    ///Получение цели id цели
    /// - Parameters:
    ///   - id: id цели
    /// - Returns: подготовленный запрос
    func getTarget(targetId: Int) throws -> URLRequest {
        let helper = TargetRequestHelper.getTarget(targetId: targetId)
        let url = try urlBuilder.buildURL(path: helper.path)

        let urlRequest = try requestBuilder.buildURLRequest(
            url: url,
            query: helper.query,
            method: helper.method,
            tokenNeccessity: .mandatory)
        return urlRequest
    }
    
    /// получение всех целей пользователя по externalId пользователя
    /// - Parameters:
    ///   - id: id пользователя
    /// - Returns: подготовленный запрос
    func getUserTargets(externalId: Int) throws -> URLRequest {
        let helper = TargetRequestHelper.getUserTargets(externalId: externalId)
        let url = try urlBuilder.buildURL(path: helper.path)

        let urlRequest = try requestBuilder.buildURLRequest(
            url: url,
            query: helper.query,
            method: helper.method,
            tokenNeccessity: .mandatory)
        return urlRequest
    }
    
    /// Обновление цели и подцели
    /// - Parameters:
    ///   - model: моделоь
    /// - Returns: подготовленный запрос
    func updateTargetAll(model: UserTargetDtoModel) throws -> URLRequest {
        let helper = TargetRequestHelper.createUserTarget
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
