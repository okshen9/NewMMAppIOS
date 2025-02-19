//
//  ServiceBuilder+Target.swift
//  MMApp
//
//  Created by artem on 16.02.2025.
//

import Foundation

/// Создание сервис реквеста
extension ServiceBuilder: TargetServiceProtocol {
    /// Получить дату пользователя
    /// - Parameters:
    ///   - model: модель получения истории пользователя
    ///   - id: id пользователя
    /// - Returns: модель пользователя
    func createUserTarget(model: CreateUserTargetBodyModel) async throws -> UserTargetDtoModel {
        try await performRequest {
            try apiFactory.createUserTarget(model: model)
        }
    }
    
    ///Получение цели id цели
    /// - Parameters:
    ///   - id: id цели
    /// - Returns: подготовленный запрос
    func getTarget(targetId: Int) async throws -> UserTargetDtoModel {
        try await performRequest {
            try apiFactory.getTarget(targetId: targetId)
        }
    }
    
    /// получение всех целей пользователя по externalId пользователя
    /// - Parameters:
    ///   - id: id пользователя
    /// - Returns: подготовленный запрос
    func getUserTargets(externalId: Int) async throws -> UserTargetsList {
        try await performRequest {
            try apiFactory.getUserTargets(externalId: externalId)
        }
    }
    
    /// Обновление цели и подцели
    /// - Parameters:
    ///   - model: моделоь
    /// - Returns: подготовленный запрос
    func updateTargetAll(model: UserTargetDtoModel) async throws -> UserTargetDtoModel {
        try await performRequest {
            try apiFactory.updateTargetAll(model: model)
        }
    }
}
