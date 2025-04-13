//
//  UserSubTargetResultModel.swift
//  MMApp
//
//  Created by artem on 16.02.2025.
//
import Foundation

/// Модель результата для UserSubTargetDto
struct UserSubTargetDtoModel: Codable, JSONRepresentable, Identifiable, Hashable {
    /// Идентификатор подцели
    var id: Int?
    /// Название подцели
    var title: String?
    /// Описание подцели
    var description: String?
    /// Процент выполнения подцели
    var subTargetPercentage: Double?
    /// Статус подцели
    var targetStatus: TargetSubStatus?
    /// Идентификатор родительской цели
    var rootTargetId: Int?
    /// Флаг удаления подцели (true - удалена, false - нет)
    var isDeleted: Bool?
    /// Время создания подцели
    var creationDateTime: String?
    /// Время последнего обновления подцели
    var lastUpdatingDateTime: String?
    /// Срок выполнения подцели
    var deadLineDateTime: String?
    
    init(id: Int? = nil, title: String? = "", description: String? = nil, subTargetPercentage: Double? = 0.0, targetSubStatus: TargetSubStatus? = .notDone, rootTargetId: Int? = nil, isDeleted: Bool? = nil, creationDateTime: String? = nil, lastUpdatingDateTime: String? = nil, deadLineDateTime: String? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.subTargetPercentage = subTargetPercentage
        self.targetStatus = targetSubStatus
        self.rootTargetId = rootTargetId
        self.isDeleted = isDeleted
        self.creationDateTime = creationDateTime
        self.lastUpdatingDateTime = lastUpdatingDateTime
        self.deadLineDateTime = deadLineDateTime
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(Int.self, forKey: .id)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.subTargetPercentage = try container.decodeIfPresent(Double.self, forKey: .subTargetPercentage)
        self.targetStatus = try container.decodeIfPresent(TargetSubStatus.self, forKey: .targetStatus)
        self.rootTargetId = try container.decodeIfPresent(Int.self, forKey: .rootTargetId)
        self.isDeleted = try container.decodeIfPresent(Bool.self, forKey: .isDeleted)
        self.creationDateTime = try container.decodeIfPresent(String.self, forKey: .creationDateTime)
        self.lastUpdatingDateTime = try container.decodeIfPresent(String.self, forKey: .lastUpdatingDateTime)
        self.deadLineDateTime = try container.decodeIfPresent(String.self, forKey: .deadLineDateTime)
    }
}

extension UserSubTargetDtoModel: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.description == rhs.description &&
        lhs.subTargetPercentage == rhs.subTargetPercentage &&
        lhs.targetStatus == rhs.targetStatus &&
        lhs.rootTargetId == rhs.rootTargetId &&
        lhs.isDeleted == rhs.isDeleted &&
        lhs.creationDateTime == rhs.creationDateTime &&
        lhs.lastUpdatingDateTime == rhs.lastUpdatingDateTime &&
        lhs.deadLineDateTime == rhs.deadLineDateTime
    }
}
