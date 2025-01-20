//
//  RequestUrls.swift
//  MMApp
//
//  Created by artem on 05.01.2025.
//

import Foundation

enum RequestUrls {
    static let baseUrl = "http://194.87.93.98:8080"
    
    
    static let favorites = "/v3/favorites"
    
    
    /// Вернуть пользователя, который обращается к системе
    static let getProfile = "/user/authuser/me"
    /// Авторизация/регитсрация юзера
    static let tgCallBack = "/user/auth/telegram/callback"
}
