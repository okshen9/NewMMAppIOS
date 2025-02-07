//
//  RequestUrls.swift
//  MMApp
//
//  Created by artem on 05.01.2025.
//

import Foundation

enum RequestUrls {
    /// базовый url приложения
    static let baseUrl = "http://194.87.93.98:8080"
    
    // MARK: - Работа с профилем
    
    /// Авторизация/регитсрация юзера
    static let tgCallBack = "/user/auth/telegram/callback"
    /// получение профиля Регистарции
    static let authuserMe = "/user/authuser/me"
    
    /// Создание профиля пользователя
    static let userProfile = "/user-profile"
    /// Получение профиля пользователя
    static let userProfileMe = "/user-profile/me"
    
    /// Запрашивает данные пользователя вместе с ролями
    static let userProfileWithRole = "/user-profile/"
    
    /// Обновляет данные пользователя
    static let updateUserProfile = "/user-profile/"
    
    /// Поиск пользователя по параметрам
    static let userSearch = "/user-profile/search"
    
    
    // MARK: - Чеками
    
    /// Получение чека по id чека
    static let getCheckout = "/api/checkout/"
    /// Получение чека по id пользователя
    static let getCheckoutForUserId = "/api/checkout/externalId/"
    /// Создание чека
    static let createCheckout = "/api/checkout"
    
    // MARK: - заявки на опалату
    
    
    
    
    
    
    
    
    
    
    
    /// Создание чека
    static let createCheck = "/api/checkout"
    
    
}
