//
//  RefreshRequest.swift
//  MMApp
//
//  Created by artem on 08.02.2025.
//


import Foundation

// Модель запроса на обновление
struct RefreshBodyModel: JSONRepresentable {
//    /// Множество ролей, которые необходимо обновить для пользователя.", example = "[\"ADMIN\", \"USER\"]
//    var roles: [Roles]
//    /// Идентификатор пользователя, для которого обновляются роли.", example = "123
//    var authUserId: Int
    /// Refresh Token
    var refreshToken: String
    
    // Конструктор для инициализации
    init(/*roles: [Roles], authUserId: Int, */refreshToken: String) {
//        self.roles = roles
//        self.authUserId = authUserId
        self.refreshToken = refreshToken
    }
}
