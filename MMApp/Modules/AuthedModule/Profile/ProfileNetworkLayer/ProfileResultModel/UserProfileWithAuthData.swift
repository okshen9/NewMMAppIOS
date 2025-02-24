//
//  ProfileResultModel.swift
//  MMApp
//
//  Created by artem on 24.02.2025.
//

import Foundation

/// Создание сервис реквеста
struct UserProfileWithAuthData: Codable {
    // болеь профиля
    let userProfileDto: UserProfileResultDto?
    // модель автризации
    let authUserDto: AuthUserDtoResult?
}
