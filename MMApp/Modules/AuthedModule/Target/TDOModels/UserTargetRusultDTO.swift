//
//  UserTargetRusultDTO.swift
//  MMApp
//
//  Created by artem on 30.01.2025.
//

import Foundation
import SwiftUICore

struct UserTarget: Identifiable, Codable {
    var id: Int
    var title: String
    var description: String
    var userExternalId: Int64
    var percentage: Double
    var deadLineDateTime: Date
    var streamId: Int
    var targetStatus: String
    var subTargets: [UserSubTarget]
    var isDeleted: Bool
    var creationDateTime: Date
    var lastUpdatingDateTime: Date
    var category: Category

    enum Category: String, Codable, CaseIterable {
        case money = "Деньги"
        case personal = "Личное"
        case family = "Семья"
        case health = "Здоровье"
        case unknown = "Неизвестно"

        // Кастомный инициализатор для обработки неизвестных значений
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)
            self = Category(rawValue: rawValue) ?? .unknown
        }
        
        var color: Color {
            switch self {
            case .money:
                    .yellow
            case .personal:
                    .blue
            case .family:
                    .mainRed
            case .health:
                    .green
            case .unknown:
                    .purple
            }
        }
    }
}
