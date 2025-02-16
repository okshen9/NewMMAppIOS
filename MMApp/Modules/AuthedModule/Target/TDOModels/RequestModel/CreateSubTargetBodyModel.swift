//
//  CreateSubTargetBodyModel.swift
//  MMApp
//
//  Created by artem on 09.02.2025.
//

import Foundation

struct CreateSubTargetBodyModel: JSONRepresentable {
    let title: String?
    let description: String?
    let subTargetPercentage: Double?
    let deadLineDateTime: Date?
    let targetStatus: TargetStatus?
    
    enum TargetStatus: String, Codable, UnknownCasedEnum {
        case completed = "Завершено"
        case inProgress = "В процессе"
        case notStarted = "Не начато"
        case unknown = "Неизвестно"
    }
}
