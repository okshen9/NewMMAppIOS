//
//  UpdateUserProfileResultDto.swift
//  MMApp
//
//  Created by artem on 25.01.2025.
//

import Foundation

struct UserProfileResultDto: Codable, Equatable, Hashable {
    let id: Int?
    let externalId: Int?
    let username: String?
    let fullName: String?
    let userProfileStatus: String?
    let userPaymentStatus: String?
    let isDeleted: Bool?
    let creationDateTime: String?
    let lastUpdatingDateTime: String?
    let phoneNumber: String?
    let location: String?
    let userGroup: UserGroupResultDto?
    let stream: StreamResultDto?
    let photoUrl: String?
    let activitySphere: String?
    let biography: String?
    let targetCalculationInfo: TargetCalculationInfoDto?
    let comment: String?
    let roles: [String]?

    static func == (lhs: UserProfileResultDto, rhs: UserProfileResultDto) -> Bool {
        return lhs.id == rhs.id
    }
}

struct UserGroupResultDto: Codable, Hashable {
    let id: Int?
    let title: String?
    let groupOwner: Int? //для получения владельца группы ищем группу (id)
    let isDeleted: Bool?
    let creationDateTime: String?
    let lastUpdatingDateTime: String? // не обновлялось, но при обновлении должно быть аналогично creationDateTime
    let streamDto: Int? // для получения стрима группы ищем группу (id)
    let owners: [StreamUserProfileShortInfoDto]?
    let participants: [StreamUserProfileShortInfoDto]?
}

struct StreamResultDto: Codable, Hashable {
    let id: Int?
    let title: String?
    let description: String?
    let dateFrom: String?
    let dateTo: String?
    let isDeleted: Bool?
    let creationDateTime: String?
    let lastUpdatingDateTime: String? // не обновлялось, но при обновлении должно быть аналогично creationDateTime
    let owners: [StreamUserProfileShortInfoDto]?
    let participants: [StreamUserProfileShortInfoDto]?
    
    var isActive: Bool {
        guard let dateToStr = dateTo,
              let dateTo = dateToStr.dateFromString() else { return false }
        return Date() < dateTo
    }
}

struct StreamUserProfileShortInfoDto: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    
    let externalId: Int?
    let username: String?
    let fullName: String?
    let targetCalculationInfoDto: TargetCalculationInfoDto?
    
    init(externalId: Int? = nil,
         username: String? = nil,
         fullName: String? = nil,
         targetCalculationInfoDto: TargetCalculationInfoDto? = nil) {
        self.externalId = externalId
        self.username = username
        self.fullName = fullName
        self.targetCalculationInfoDto = targetCalculationInfoDto
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.externalId = try container.decodeIfPresent(Int.self, forKey: .externalId)
        self.username = try container.decodeIfPresent(String.self, forKey: .username)
        self.fullName = try container.decodeIfPresent(String.self, forKey: .fullName)
        self.targetCalculationInfoDto = try container.decodeIfPresent(TargetCalculationInfoDto.self, forKey: .targetCalculationInfoDto)
    }
}

// Модель TargetCalculationInfoDto

struct TargetCalculationInfoDto: Codable, Hashable {
    var categoryToInfoMapping: [String: TargetCategoryCalculationInfoDto]
    var allCategoriesDonePercentage: Double
    
    init(categoryToInfoMapping: [String: TargetCategoryCalculationInfoDto],
         allCategoriesDonePercentage: Double = 0.0) {
        self.categoryToInfoMapping = categoryToInfoMapping
        self.allCategoriesDonePercentage = allCategoriesDonePercentage
    }
}

// Модель TargetCategoryCalculationInfoDto

struct TargetCategoryCalculationInfoDto: Codable, Hashable {
    var quantityForUserProfile: Int?
    var doneForUserProfile: Int?
    var percentageOfDoneAllCategoryForUserProfile: Double
    
    init(quantityForUserProfile: Int = 0,
         doneForUserProfile: Int = 0,
         percentageOfDoneAllCategoryForUserProfile: Double = 0.0) {
        self.quantityForUserProfile = quantityForUserProfile
        self.doneForUserProfile = doneForUserProfile
        self.percentageOfDoneAllCategoryForUserProfile = percentageOfDoneAllCategoryForUserProfile
    }
}
