//
//  UserSubTargetRuseltDTO.swift
//  MMApp
//
//  Created by artem on 30.01.2025.
//

import Foundation

struct UserSubTarget: Identifiable, Codable {
    var id: Int
    var title: String
    var description: String
    var subTargetPercentage: Decimal
    var targetStatus: StatusSub
    var rootTargetId: Int
    var isDeleted: Bool
    var creationDateTime: Date
    var lastUpdatingDateTime: Date
    var deadLineDateTime: Date
    
    // Инициализатор
    init(id: Int,
         title: String,
         description: String,
         subTargetPercentage: Decimal,
         targetStatus: String,
         rootTargetId: Int,
         isDeleted: Bool,
         creationDateTime: Date,
         lastUpdatingDateTime: Date,
         deadLineDateTime: Date) {
        self.id = id
        self.title = title
        self.description = description
        self.subTargetPercentage = subTargetPercentage
        self.targetStatus = StatusSub(rawValue: targetStatus) ?? .NOT_STARTED
        self.rootTargetId = rootTargetId
        self.isDeleted = isDeleted
        self.creationDateTime = creationDateTime
        self.lastUpdatingDateTime = lastUpdatingDateTime
        self.deadLineDateTime = deadLineDateTime
    }
    
}

enum StatusSub: String, Codable {
    case NOT_STARTED = "NOT_STARTED"
    case IN_PROGRESS = "IN_PROGRESS"
    case COMPLETED = "COMPLETED"
}
