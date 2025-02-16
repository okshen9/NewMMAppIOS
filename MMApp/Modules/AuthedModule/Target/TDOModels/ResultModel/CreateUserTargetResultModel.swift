//
//  CreateUserTargetResultModel.swift
//  MMApp
//
//  Created by artem on 09.02.2025.
//


import Foundation

struct CreateUserTargetResultModel: Codable {
    let title: String?
    let description: String?
    let userExternalId: Int?
    let deadLineDateTime: Date?
    let streamId: Int?
    let subTargets: [CreateSubTargetResultModel]?
    let category: Category?
    
    struct CreateSubTargetResultModel: Codable {}
    
    enum Category: String, Codable, UnknownCasedEnum {
        case unknown = "Неизвестно"
        case business = "Бизнес"
        case personal = "Личная"
    }
}
