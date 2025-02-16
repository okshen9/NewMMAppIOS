//
//  UpdateUserProfileResultDto.swift
//  MMApp
//
//  Created by artem on 25.01.2025.
//

import Foundation

struct UserProfileResultDto: Codable {
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
}
