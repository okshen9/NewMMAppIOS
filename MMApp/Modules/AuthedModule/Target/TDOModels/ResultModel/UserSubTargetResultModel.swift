//
//  UserSubTargetResultModel.swift
//  MMApp
//
//  Created by artem on 09.02.2025.
//


import Foundation

struct UserSubTargetResultModel: Codable {
    let id: Int?
    let title: String?
    let description: String?
    let subTargetPercentage: Double?
    let targetStatus: TargetStatus?
    let rootTargetId: Int?
    let isDeleted: Bool?
    let creationDateTime: Date?
    let lastUpdatingDateTime: Date?
    let deadLineDateTime: Date?
    
    enum TargetStatus: String, Codable, UnknownCasedEnum {
        case unknown = "Неизвестно"
        case completed = "Завершено"
        case inProgress = "В процессе"
        case notStarted = "Не начато"
    }
}
