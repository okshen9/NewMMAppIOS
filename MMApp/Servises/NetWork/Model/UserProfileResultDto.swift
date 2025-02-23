//
//  UpdateUserProfileResultDto.swift
//  MMApp
//
//  Created by artem on 25.01.2025.
//

import Foundation

struct UserProfileResultDto: Codable, Equatable {
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
    
    static func == (lhs: UserProfileResultDto, rhs: UserProfileResultDto) -> Bool {
        return lhs.id == rhs.id
    }
}

struct UserGroupResultDto: Codable {
    let id: Int
    let title: String
    let groupOwner: Int? //для получения владельца группы ищем группу (id)
    let isDeleted: Bool?
    let creationDateTime: String?
    let lastUpdatingDateTime: String? // не обновлялось, но при обновлении должно быть аналогично creationDateTime
    let streamDto: Int? // для получения стрима группы ищем группу (id)
}

struct StreamResultDto: Codable {
    let id: Int?
    let title: String?
    let description: String?
    let dateFrom: String?
    let dateTo: String?
    let isDeleted: Bool?
    let creationDateTime: String?
    let lastUpdatingDateTime: String? // не обновлялось, но при обновлении должно быть аналогично creationDateTime
    
    var isActive: Bool {
        guard let dateToStr = dateTo,
              let dateTo = dateToStr.dateFromString() else { return false }
        return Date() < dateTo
    }
}
