//
//  CreateUserTargetDto.swift
//  MMApp
//
//  Created by artem on 09.02.2025.
//

import Foundation

struct CreateUserTargetBodyModel: JSONRepresentable {
    let title: String?
    let description: String?
    let userExternalId: Int64?
    let deadLineDateTime: Date?
    let streamId: Int?
    let subTargets: [CreateSubTargetBodyModel]?
    let category: Category?
    
    enum Category: String, UnknownCasedEnum, JSONRepresentable {
        case business = "Бизнес"
        case personal = "Личная"
        case unknown = "unknown"
    }
}
