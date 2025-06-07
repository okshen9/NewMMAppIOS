//
//  ProfileRequestProtocol.swift
//  MMApp
//
//  Created by artem on 24.02.2025.
//

import Foundation

protocol ProfileRequestProtocol {
    /// Получить дату пользователя
    /// - Parameters:
    ///   - model: модель получения истории пользователя
    ///   - id: id пользователя
    /// - Returns: подготовленный запрос
    func getDataRequest(model: ProfileBodyModel, id: Int) throws -> URLRequest
    
    /// Отправить жалобу на пользователя
    /// - Parameter model: модель жалобы
    /// - Returns: подготовленный запрос
    func sendComplaintRequest(model: ComplaintBodyModel) throws -> URLRequest
    
    /// Получить детальную информацию по группе
    /// - Parameter idGroup: id группы
    /// - Returns: подготовленный запрос
    func getGroup(idGroup: Int) throws -> URLRequest
}
