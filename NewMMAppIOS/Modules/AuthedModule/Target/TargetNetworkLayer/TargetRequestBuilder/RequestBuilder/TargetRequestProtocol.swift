//
//  TargetRequestProtocol.swift
//  MMApp
//
//  Created by artem on 16.02.2025.
//

import Foundation

protocol TargetRequestProtocol {    
    /// Создать цель
    /// - Parameters:
    ///   - model: модель получения истории пользователя
    ///   - id: id пользователя
    /// - Returns: подготовленный запрос
    func createUserTarget(model: CreateUserTargetBodyModel) throws -> URLRequest
    
    ///Получение цели id цели
    /// - Parameters:
    ///   - id: id цели
    /// - Returns: подготовленный запрос
    func getTarget(targetId: Int) throws -> URLRequest
    
    /// получение всех целей пользователя по externalId пользователя
    /// - Parameters:
    ///   - id: id пользователя
    /// - Returns: подготовленный запрос
    func getUserTargets(externalId: Int) throws -> URLRequest
    
    /// Обновление цели и подцели
    /// - Parameters:
    ///   - model: моделоь
    /// - Returns: подготовленный запрос
    func updateTargetAll(model: UserTargetDtoModel) throws -> URLRequest
}
