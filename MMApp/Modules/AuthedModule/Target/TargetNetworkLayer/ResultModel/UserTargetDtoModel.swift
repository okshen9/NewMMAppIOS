//
//  CreateUserTargetResultModel.swift
//  MMApp
//
//  Created by artem on 16.02.2025.
//

import Foundation

/// Модель результата для UserTargetDto
struct UserTargetDtoModel: Codable, JSONRepresentable, Identifiable {
    /// Уникальный идентификатор цели
    var id: Int?
    /// Наименование цели
    var title: String?
    /// Описание цели
    var description: String?
    /// Внешний ID пользователя, которому принадлежит цель
    var userExternalId: Int?
    /// Процент выполнения цели в процентах
    var percentage: Double?
    /// Дедлайн цели
    var deadLineDateTime: String?
    /// ID стрима для цели
    var streamId: Int?
    /// Статус цели
    var targetStatus: TargetStatus?
    /// Подцели для выполнения цели
    var subTargets: [UserSubTargetDtoModel]?
    /// Признак (флаг) удаления цели (true - удалена, false - нет)
    var isDeleted: Bool?
    /// Дата и время создания цели
    var creationDateTime: String?
    /// Дата и время последнего обновления цели
    var lastUpdatingDateTime: String?
    /// Категория цели
    var category: TargetCategory?
    
    mutating func update(_ newTitle: String? = nil,
                         _ newDescription: String? = nil,
                         _ newDeadLineDateTime: String? = nil,
                         _ newCategory: TargetCategory? = nil,
                         _ newSubTargets: [UserSubTargetDtoModel]? = nil) {
        self.title = newTitle ?? self.title
        self.description = newDescription ?? self.description
        self.deadLineDateTime = newDeadLineDateTime ?? self.deadLineDateTime
        self.category = newCategory ?? self.category
        self.subTargets = newSubTargets ?? self.subTargets
        
        self.targetStatus = .draft
    }
    
    init(id: Int? = nil, title: String? = nil, description: String? = nil, userExternalId: Int? = nil, percentage: Double? = nil, deadLineDateTime: String? = nil, streamId: Int? = nil, targetStatus: TargetStatus? = nil, subTargets: [UserSubTargetDtoModel]? = nil, isDeleted: Bool? = nil, creationDateTime: String? = nil, lastUpdatingDateTime: String? = nil, category: TargetCategory? = nil) {
        self.id = id
        self.title = title ?? "какой-то тайтл"
        self.description = description ?? "какой-то описание"
        self.userExternalId = userExternalId ?? .random(in: 1...10000)
        self.percentage = percentage ?? .random(in: 0...100)
        self.deadLineDateTime = deadLineDateTime ?? Date.nowWith(plus: .random(in: 0...10)).toApiString
        self.streamId = streamId ?? .random(in: 1...10000)
        self.targetStatus = targetStatus ?? .expired
        self.subTargets = subTargets ?? .none
        self.isDeleted = isDeleted ?? false
        self.creationDateTime = creationDateTime ?? deadLineDateTime ?? Date.nowWith(plus: .random(in: 0...10)).toApiString
        self.lastUpdatingDateTime = lastUpdatingDateTime ?? deadLineDateTime ?? Date.nowWith(plus: .random(in: 0...10)).toApiString
        self.category = category ?? .money
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(Int.self, forKey: .id)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.userExternalId = try container.decodeIfPresent(Int.self, forKey: .userExternalId)
        self.percentage = try container.decodeIfPresent(Double.self, forKey: .percentage)
        self.deadLineDateTime = try container.decodeIfPresent(String.self, forKey: .deadLineDateTime)
        self.streamId = try container.decodeIfPresent(Int.self, forKey: .streamId)
        self.targetStatus = try container.decodeIfPresent(TargetStatus.self, forKey: .targetStatus)
        self.subTargets = try container.decodeIfPresent([UserSubTargetDtoModel].self, forKey: .subTargets)
        self.isDeleted = try container.decodeIfPresent(Bool.self, forKey: .isDeleted)
        self.creationDateTime = try container.decodeIfPresent(String.self, forKey: .creationDateTime)
        self.lastUpdatingDateTime = try container.decodeIfPresent(String.self, forKey: .lastUpdatingDateTime)
        self.category = try container.decodeIfPresent(TargetCategory.self, forKey: .category)
    }
    
    mutating
    func changeSelfStatus() {
        switch targetStatus {
        case .draft, .failed, .inProgress:
            self.targetStatus = .done
            
        case .doneExpired, .cancelled, .done:
            self.targetStatus = .inProgress
            
        case .expired:
            self.targetStatus = .doneExpired
            
        case .unknown, nil:
            self.targetStatus = .draft
        }
    }
}

extension UserTargetDtoModel: Equatable {
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.description == rhs.description &&
        lhs.userExternalId == rhs.userExternalId &&
        lhs.percentage == rhs.percentage &&
        lhs.deadLineDateTime == rhs.deadLineDateTime &&
        lhs.streamId == rhs.streamId &&
        lhs.targetStatus == rhs.targetStatus &&
        lhs.subTargets == rhs.subTargets &&
        lhs.isDeleted == rhs.isDeleted &&
        lhs.creationDateTime == rhs.creationDateTime &&
        lhs.lastUpdatingDateTime == rhs.lastUpdatingDateTime &&
        lhs.category == rhs.category
    }
}
