//
//  UpdateUserProfileResultDto.swift
//  MMApp
//
//  Created by artem on 25.01.2025.
//

import Foundation

struct UserProfileResultDto: Codable, Equatable, Hashable {
    let id: Int?
    let externalId: Int
    let username: String?
    let fullName: String?
    let userProfileStatus: String?
    let userPaymentStatus: String?
    let isDeleted: Bool?
    let creationDateTime: String?
    let lastUpdatingDateTime: String?
	// TODO: Neshko
//    let userGroups: UserGroupResultDto?
    let stream: StreamResultDto?
    let comment: String?
    let photoUrl: String?
    let userTargets: [UserTargetDtoModel]?
    let targetCalculationInfo: TargetCalculationInfoDto?
    let location: String?
    let phoneNumber: String?
    let activitySphere: String?
    let paymentCalculationInfo: PaymentCalculationInfoDto?
    let biography: String?
    var forUserHideThisExtIdUsersEvents: [Int]?

    static func == (lhs: UserProfileResultDto, rhs: UserProfileResultDto) -> Bool {
        return lhs.id == rhs.id
    }

    init(id: Int?, externalId: Int, username: String?, fullName: String?, userProfileStatus: String?, userPaymentStatus: String?, isDeleted: Bool?, creationDateTime: String?, lastUpdatingDateTime: String?, userGroups: UserGroupResultDto?, stream: StreamResultDto?, comment: String?, photoUrl: String?, userTargets: [UserTargetDtoModel]?, targetCalculationInfo: TargetCalculationInfoDto?, location: String?, phoneNumber: String?, activitySphere: String?, paymentCalculationInfo: PaymentCalculationInfoDto?, biography: String?, forUserHideThisExtIdUsersEvents: [Int]?) {
        self.id = id
        self.externalId = externalId
        self.username = username
        self.fullName = fullName
        self.userProfileStatus = userProfileStatus
        self.userPaymentStatus = userPaymentStatus
        self.isDeleted = isDeleted
        self.creationDateTime = creationDateTime
        self.lastUpdatingDateTime = lastUpdatingDateTime
		//TODO: neshko
//        self.userGroups = userGroups
        self.stream = stream
        self.comment = comment
        self.photoUrl = photoUrl
        self.userTargets = userTargets
        self.targetCalculationInfo = targetCalculationInfo
        self.location = location
        self.phoneNumber = phoneNumber
        self.activitySphere = activitySphere
        self.paymentCalculationInfo = paymentCalculationInfo
        self.biography = biography
        self.forUserHideThisExtIdUsersEvents = forUserHideThisExtIdUsersEvents
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(Int.self, forKey: .id)
        self.externalId = try container.decode(Int.self, forKey: .externalId)
        self.username = try container.decodeIfPresent(String.self, forKey: .username)
        self.fullName = try container.decodeIfPresent(String.self, forKey: .fullName)
        self.userProfileStatus = try container.decodeIfPresent(String.self, forKey: .userProfileStatus)
        self.userPaymentStatus = try container.decodeIfPresent(String.self, forKey: .userPaymentStatus)
        self.isDeleted = try container.decodeIfPresent(Bool.self, forKey: .isDeleted)
        self.creationDateTime = try container.decodeIfPresent(String.self, forKey: .creationDateTime)
        self.lastUpdatingDateTime = try container.decodeIfPresent(String.self, forKey: .lastUpdatingDateTime)
		//TODO: neshko
//        self.userGroups = try container.decodeIfPresent(UserGroupResultDto.self, forKey: .userGroups)
        self.stream = try container.decodeIfPresent(StreamResultDto.self, forKey: .stream)
        self.comment = try container.decodeIfPresent(String.self, forKey: .comment)
        self.photoUrl = try container.decodeIfPresent(String.self, forKey: .photoUrl)
        self.userTargets = try container.decodeIfPresent([UserTargetDtoModel].self, forKey: .userTargets)
        self.targetCalculationInfo = try container.decodeIfPresent(TargetCalculationInfoDto.self, forKey: .targetCalculationInfo)
        self.location = try container.decodeIfPresent(String.self, forKey: .location)
        self.phoneNumber = try container.decodeIfPresent(String.self, forKey: .phoneNumber)
        self.activitySphere = try container.decodeIfPresent(String.self, forKey: .activitySphere)
        self.paymentCalculationInfo = try container.decodeIfPresent(PaymentCalculationInfoDto.self, forKey: .paymentCalculationInfo)
        self.biography = try container.decodeIfPresent(String.self, forKey: .biography)
        self.forUserHideThisExtIdUsersEvents = try container.decodeIfPresent([Int].self, forKey: .forUserHideThisExtIdUsersEvents)
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
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.categoryToInfoMapping = try container.decode([String : TargetCategoryCalculationInfoDto].self, forKey: .categoryToInfoMapping)
        let allCategoriesDonePercentageStr = try container.decodeIfPresent(String.self, forKey: .allCategoriesDonePercentage).orEmpty
        self.allCategoriesDonePercentage = Double(allCategoriesDonePercentageStr) ?? 0
    }
}

// Модель TargetCategoryCalculationInfoDto

struct TargetCategoryCalculationInfoDto: Codable, Hashable {
    /// количество целей в профиле
    var quantityForUserProfile: Int?
    /// количество готовых
    var doneForUserProfile: Int?
    /// процент выполнения
    var percentageOfDoneAllCategoryForUserProfile: Double
    
    init(quantityForUserProfile: Int = 0,
         doneForUserProfile: Int = 0,
         percentageOfDoneAllCategoryForUserProfile: Double = 0.0) {
        self.quantityForUserProfile = quantityForUserProfile
        self.doneForUserProfile = doneForUserProfile
        self.percentageOfDoneAllCategoryForUserProfile = percentageOfDoneAllCategoryForUserProfile
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.quantityForUserProfile = try container.decodeIfPresent(Int.self, forKey: .quantityForUserProfile)
        self.doneForUserProfile = try container.decodeIfPresent(Int.self, forKey: .doneForUserProfile)
        let percentageOfDoneAllCategoryForUserProfileStr = try container.decodeIfPresent(String.self, forKey: .percentageOfDoneAllCategoryForUserProfile).orEmpty
        self.percentageOfDoneAllCategoryForUserProfile = Double(percentageOfDoneAllCategoryForUserProfileStr) ?? 0
    }
}


extension UserProfileResultDto {
    static func getTestUser() -> UserProfileResultDto {
        UserProfileResultDto.init(
            id: 16,
            externalId: 17,
            username: "dashabebneva",
            fullName: "Daria Bebneva",
            userProfileStatus: "DRAFT",
            userPaymentStatus: "DRAFT",
            isDeleted: false,
            creationDateTime: "2025-04-06T13:43:27.782416",
            lastUpdatingDateTime: "2025-04-06T13:49:39.54274",
            userGroups: nil,
            stream: nil,
            comment: "Тестовый пользователь!\nШтрафы можно назначить только для теста!",
            photoUrl: "https://t.me/i/userpic/320/i6xQ9kQLTuX0pwKKHNHP9EPcZ9mtatdhZFdTCOQzWfo.jpg",
            userTargets: nil,
            targetCalculationInfo: nil,
            location: "Саратов",
            phoneNumber: "+79272243688",
            activitySphere: "Психолог",
            paymentCalculationInfo: nil,
            biography: "Что-то о себе",
            forUserHideThisExtIdUsersEvents: nil
        )
    }
}
