//
//  RequestUrls.swift
//  MMApp
//
//  Created by artem on 05.01.2025.
//

import Foundation

enum RequestUrls {
    /// базовый url приложения
//    static let baseUrl = "http://194.87.93.98:8080"
    static let prodBaseUrl = "https://appmastermind.ru/api"
    static let testBaseUrl = "http://45.141.102.197/api"
//    http:45.141.102.197
//    static let baseUrl = "http://localhost:8080"
    
    // MARK: - Работа с профилем
    
    /// Авторизация/регитсрация юзера
    static let tgCallBack = "/user/auth/telegram/callback"
    /// Получение профиля Регистарции
    static let authuserMe = "/user/authuser/me"
    /// Запрос на рерфреш , обновление refreshToken, accessToken
    static let authuserRefresh = "/user/auth/refresh"
    
    /// Создание профиля пользователя
    static let userProfile = "/user-profile"
    /// Получение профиля пользователя
    static let userProfileMe = "/user-profile/me"
    
    /// Запрашивает данные пользователя вместе с ролями
    static let userProfileWithRole = "/user-profile"

    /// Обновляет данные пользователя
    static let updateUserProfile = "/user-profile"
    
    /// Поиск пользователя по параметрам
    static let userSearch = "/user-profile/search"
    
    
    
    // MARK: - Цели
    /// Создание(POST) цели с подцелями для пользователя в БД
    /// Получение(GET) цели с подцелями по ID цели
    /// Обновление(PATCH) цели и подцелей цели по ID из тела запроса и ID подцелей из целей запроса
    /// Отметить(DELETE) цель как удалённую вместе с её подцелями по ID цели
    static let userTarget = "/user-target"
    
    /// Получить все цели с подцелями пользователя по его внешнему ID
    static let userTargetForUser = "/user-target/user-profile"
    
    /// Обновление(/PATCH) цели и подцели (включая добавление подцели и изменения статусов цели/подцели на isDeleted и других статусов из dto)
    static let userTargetAllUpdate = "/user-target/all"
    
    /// Заменить(PATCH) статус подцели по её ID. Если все подцели в статусе FINISHED - закрывается рутовая цель (переводится в FINISHED)
    static let userTargetUpdateSubTarget = "/user-target/user-sub-target"
    
    /// Отметить(DELETE) подцель как удалённую
    static let userTargetSubTargetDelete = "/user-target/sub-user-target"
    
    /// Создать(POST) отчёт по цели
    static let userTargetReport = "/user-report"
    
    /// Получение(GET) списка отчётов по цели
    static let userTargetGetReport = "/user-report/user-target"
    
    // MARK: - Чеками
    
    /// Получение чека по id чека
    static let getCheckout = "/api/checkout"
    /// Получение чека по id пользователя
    static let getCheckoutForUserId = "/api/checkout/externalId"
    /// Создание чека
    static let createCheckout = "/api/checkout"
    
    // MARK: - заявки на опалату
    
    static let paymentPlanForExternalId = "/payment-requests/externalId/me"
    
    
}
