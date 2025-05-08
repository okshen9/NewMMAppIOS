//
//  CreateUserTargetResultModel.swift
//  MMApp
//
//  Created by artem on 16.02.2025.
//

import Foundation
import SwiftUICore

/// Модель результата для UserTargetDto
struct UserTargetDtoModel: Codable, JSONRepresentable, Identifiable, Hashable {
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
	/// Статус модерации цели
	var targetModerationStatus: TargetModerationStatus?
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
                         _ newSubTargets: [UserSubTargetDtoModel]? = nil,
                         _ sattus: TargetStatus) {
        self.title = newTitle ?? self.title
        self.description = newDescription ?? self.description
        self.deadLineDateTime = newDeadLineDateTime ?? self.deadLineDateTime
        self.category = newCategory ?? self.category
        self.subTargets = newSubTargets ?? self.subTargets
        
        self.targetStatus = sattus
    }
    
    init(id: Int? = nil, title: String? = nil, description: String? = nil, userExternalId: Int? = nil, percentage: Double? = nil, deadLineDateTime: String? = nil, streamId: Int? = nil, targetStatus: TargetStatus? = nil, targetModerationStatus: TargetModerationStatus? = nil, subTargets: [UserSubTargetDtoModel]? = nil, isDeleted: Bool? = nil, creationDateTime: String? = nil, lastUpdatingDateTime: String? = nil, category: TargetCategory? = nil) {
		self.id = id
        self.title = title
        self.description = description
        self.userExternalId = userExternalId
        self.percentage = percentage
        self.deadLineDateTime = deadLineDateTime
        self.streamId = streamId
        self.targetStatus = targetStatus
        self.subTargets = subTargets
        self.isDeleted = isDeleted
        self.creationDateTime = creationDateTime
        self.lastUpdatingDateTime = lastUpdatingDateTime
        self.category = category
		self.targetModerationStatus = targetModerationStatus
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
		self.targetModerationStatus = try container.decodeIfPresent(TargetModerationStatus.self, forKey: .targetModerationStatus)
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
		lhs.targetModerationStatus == rhs.targetModerationStatus &&
        lhs.isDeleted == rhs.isDeleted &&
        lhs.creationDateTime == rhs.creationDateTime &&
        lhs.lastUpdatingDateTime == rhs.lastUpdatingDateTime &&
        lhs.category == rhs.category
    }
}


extension UserTargetDtoModel {
	func getStatusDescription(status: TargetStatus? = nil) -> String {
		guard let status = status ?? self.targetStatus else { return TargetStatus.unknown.title }
		switch status {
			case .inProgress:
			return "\(status.title) + \(Int(self.percentage ?? 0))%"
		default:
			return status.title
		}
	}
	
	/// Создает модель, содержащую только ID и измененные поля по сравнению с предыдущей моделью
	/// - Parameter oldModel: Предыдущая модель для сравнения
	/// - Returns: Минимальная модель с измененными полями
	func minimalChangeModel(oldModel: UserTargetDtoModel) -> UserTargetDtoModel {
		// Создаем новую модель только с ID
		var minimalModel = UserTargetDtoModel(id: self.id)
		
		// Сравниваем каждое поле и добавляем только те, которые изменились
		if title != oldModel.title {
			minimalModel.title = title
		}
		
		if description != oldModel.description {
			minimalModel.description = description
		}
		
		if userExternalId != oldModel.userExternalId {
			minimalModel.userExternalId = userExternalId
		}
		
		if percentage != oldModel.percentage {
			minimalModel.percentage = percentage
		}
		
		if deadLineDateTime != oldModel.deadLineDateTime {
			minimalModel.deadLineDateTime = deadLineDateTime
		}
		
		if streamId != oldModel.streamId {
			minimalModel.streamId = streamId
		}
		
		if targetStatus != oldModel.targetStatus {
			minimalModel.targetStatus = targetStatus
		}
		
		if targetModerationStatus != oldModel.targetModerationStatus {
			minimalModel.targetModerationStatus = targetModerationStatus
		}
		
		if let newSubTargets = subTargets, let oldSubTargets = oldModel.subTargets {
			// Если размеры массивов разные, считаем что массив изменился
			var tempArray: [UserSubTargetDtoModel] = []
			if newSubTargets.count != oldSubTargets.count {
				minimalModel.subTargets = newSubTargets
			} else {
				// Проверяем, есть ли различия в подцелях
				zip(newSubTargets, oldSubTargets).forEach { newTarget, oldTarget in
					if newTarget != oldTarget {
						tempArray.append(newTarget.minimalChangeModel(oldModel: oldTarget))
					}
				}

				
				if !tempArray.isEmpty {
					minimalModel.subTargets = tempArray
				}
			}
		} else if (subTargets == nil && oldModel.subTargets != nil) || 
				  (subTargets != nil && oldModel.subTargets == nil) {
			// Если один из массивов nil, а другой нет, считаем что изменился
			minimalModel.subTargets = subTargets
		}
		
		if isDeleted != oldModel.isDeleted {
			minimalModel.isDeleted = isDeleted
		}
		
		if creationDateTime != oldModel.creationDateTime {
			minimalModel.creationDateTime = creationDateTime
		}
		
		if lastUpdatingDateTime != oldModel.lastUpdatingDateTime {
			minimalModel.lastUpdatingDateTime = lastUpdatingDateTime
		}
		
		if category != oldModel.category {
			minimalModel.category = category
		}
		
		return minimalModel
	}
	
	
	
    static func getBaseTarget(withOutSub: Bool = false, withOutDesc: Bool = false) -> UserTargetDtoModel {
        let subTargets = [
            UserSubTargetDtoModel(
                id: 32,
                title: "sfdsfsdf",
                description: nil,
                subTargetPercentage: 50,
                targetSubStatus: .notDone,
                rootTargetId: 45,
                isDeleted: false,
                creationDateTime: "2025-03-29T16:45:24.752615",
                lastUpdatingDateTime: nil,
                deadLineDateTime: "2025-03-31T23:59:59.999"
            ),
            UserSubTargetDtoModel(
                id: 33,
                title: "sddfsdfdsf",
                description: "длинное описание 3.Собрал команду в корпоративной практике - подписал трудовые договоры с новыми сотрудниками (ведущий юрист, юрист, руководитель отдела) до 12.05.2025",
                subTargetPercentage: 50,
                targetSubStatus: .notDone,
                rootTargetId: 45,
                isDeleted: false,
                creationDateTime: "2025-03-29T16:45:24.753233",
                lastUpdatingDateTime: nil,
                deadLineDateTime: "2025-03-31T23:59:59.999"
            )
        ]

        return UserTargetDtoModel(
            id: 45,
            title: "sfsdfsdfsdf",
            description: withOutDesc ? nil : "длинное описание Цели 3.Собрал команду в корпоративной практике - подписал трудовые договоры с новыми сотрудниками (ведущий юрист, юрист, руководитель отдела) до 12.05.2025",
            userExternalId: 11,
            percentage: 0,
            deadLineDateTime: "2025-03-31T23:59:59.999",
            streamId: nil,
            targetStatus: .inProgress,
            subTargets: withOutSub ? nil : subTargets,
            isDeleted: false,
            creationDateTime: "2025-03-29T16:45:24.752155",
            lastUpdatingDateTime: nil,
            category: .money
        )
    }
}
