//
//  AuthUserJwtResponse.swift
//  MMApp
//
//  Created by artem on 08.02.2025.
//

import Foundation

// Модель ответа JWT аутентификации
struct AuthUserJwtResult: Codable {
    let jwt: String?
    let refreshToken: String?
    let authUserDto: AuthUserDtoResult?
    let status: String?
}
