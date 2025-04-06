//
//  CreateUserProfileQuery.swift
//  MMApp
//
//  Created by artem on 25.01.2025.
//

import Foundation


struct CreateUserProfileBodyModel: JSONRepresentable {
    
    /// "Уникальный идентификатор пользователя (ID) для внешней системы", example = "1")
    var externalId: Int
    
    /// "Уникальное имя пользователя", example = "TestUser")
    var username: String
    
    /// "Полное имя пользователя", example = "Андрей")
    var fullName: String
    
    /// "Статус профиля пользователя", example = "DRAFT")
    var userProfileStatus: String
    
    /// "Статус оплаты пользователя", example = "DRAFT")
    var userPaymentStatus: String
    
    /// "Комментрий к профилю", example = "Хороший чел")
//    var comment: String
    
    /// "Ссылка на фото в ТГ", example = "http://telegram.com/photourl")
    var photoUrl: String
    
    /// "Где живёт", example = "Париж")
    var location: String
    
    /// "Номер тел", example = "88005553535")
    var phoneNumber: String
    
    /// Биография, макс 256 символов
    var biography: String?

    /// Чем занимется человек
    var activitySphere: String?
}
