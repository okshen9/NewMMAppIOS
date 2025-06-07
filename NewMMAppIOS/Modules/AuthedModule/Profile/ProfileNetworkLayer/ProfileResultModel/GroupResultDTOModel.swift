//
//  GroupResultDTOModel.swift
//  NewMMAppIOS
//
//  Created by artem on 05.06.25.
//

import Foundation

struct GroupResultDTOModel: Codable, Hashable, Equatable {
    let id: Int?
    let title: String?
    let userOwners: [UserProfileResultDto]?
    let userMembers: [UserProfileResultDto]?
    let description: String?
    let tgChatReference: String?
    let isDeleted: Bool?
    let creationDateTime: String?
    let lastUpdatingDateTime: String?
    let tgChatId: String?
    let usersGroupType: GroupTypeResultDTOModel?
    let dateFrom: String?
    let dateTo: String?
    
    init(id: Int?, title: String?, userOwners: [UserProfileResultDto]?, userMembers: [UserProfileResultDto]?, description: String?, tgChatReference: String?, isDeleted: Bool?, creationDateTime: String?, lastUpdatingDateTime: String?, tgChatId: String?, usersGroupType: GroupTypeResultDTOModel?, dateFrom: String?, dateTo: String?) {
        self.id = id
        self.title = title
        self.userOwners = userOwners
        self.userMembers = userMembers
        self.description = description
        self.tgChatReference = tgChatReference
        self.isDeleted = isDeleted
        self.creationDateTime = creationDateTime
        self.lastUpdatingDateTime = lastUpdatingDateTime
        self.tgChatId = tgChatId
        self.usersGroupType = usersGroupType
        self.dateFrom = dateFrom
        self.dateTo = dateTo
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.id = try container.decodeIfPresent(Int.self, forKey: .id)
        
        self.userOwners = try container.decodeIfPresent([UserProfileResultDto].self, forKey: .userOwners)
        self.userMembers = try container.decodeIfPresent([UserProfileResultDto].self, forKey: .userMembers)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.tgChatReference = try container.decodeIfPresent(String.self, forKey: .tgChatReference)
        self.isDeleted = try container.decodeIfPresent(Bool.self, forKey: .isDeleted)
        self.creationDateTime = try container.decodeIfPresent(String.self, forKey: .creationDateTime)
        self.lastUpdatingDateTime = try container.decodeIfPresent(String.self, forKey: .lastUpdatingDateTime)
        self.tgChatId = try container.decodeIfPresent(String.self, forKey: .tgChatId)
        self.usersGroupType = try container.decodeIfPresent(GroupTypeResultDTOModel.self, forKey: .usersGroupType)
        self.dateFrom = try container.decodeIfPresent(String.self, forKey: .dateFrom)
        self.dateTo = try container.decodeIfPresent(String.self, forKey: .dateTo)
    }
    
    /// Получаем даты активности группы/стрима
    var dateRange: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        
        guard let startDate = dateFrom?.dateFromStringISO8601?.toDisplayString,
              let endDate = dateTo?.dateFromStringISO8601?.toDisplayString else {
            return ""
        }
        
        return "\(startDate) - \(endDate)"
    }
}

enum GroupTypeResultDTOModel: String, UnknownCasedEnum, Equatable, Codable {
    case unknown = "unknown"
    
    case group = "GROUP"
    case stream = "STREAM_GROUP"
}

extension GroupTypeResultDTOModel {
    var displayName: String {
        switch self {
        case .group: return "Группа"
        case .stream: return "Стрим"
        case .unknown: return "Неизвестно"
        }
    }
}
