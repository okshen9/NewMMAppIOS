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
    func createUserTarget(model: CreateUserTargetBodyModel) async throws -> UserTargetDtoModel
    
    ///Получение цели id цели
    /// - Parameters:
    ///   - id: id цели
    /// - Returns: подготовленный запрос
    func getTarget(targetId: Int) async throws -> UserTargetDtoModel
    
    /// получение всех целей пользователя по externalId пользователя
    /// - Parameters:
    ///   - id: id пользователя
    /// - Returns: подготовленный запрос
    func getUserTargets(externalId: Int) async throws -> UserTargetsList
    
    /// Обновление цели и подцели
    /// - Parameters:
    ///   - model: моделоь
    /// - Returns: подготовленный запрос
    func updateTargetAll(model: UserTargetDtoModel) async throws -> UserTargetDtoModel
}
