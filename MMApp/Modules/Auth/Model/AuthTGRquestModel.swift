//
//  AuthTGRequestModel.swift
//  MMApp
//
//  Created by artem on 07.01.2025.
//

import Foundation

struct AuthTGRequestModel: Codable {
    let jwt: String
    let authUserDto: AuthUserDtoResult?
    
//    enum CodingKeys: String, CodingKey {
//        case jwt
//        case authUserDto = "authUserDto"
//    }
//    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.jwt = try container.decodeIfPresent(String.self, forKey: .jwt)
//        self.authUserDto = try container.decodeIfPresent(AuthUserDtoResult.self, forKey: .authUserDto)
//    }
//    
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encodeIfPresent(jwt, forKey: .jwt)
//        try container.encodeIfPresent(authUserDto, forKey: .authUserDto)
//    }
}

struct AuthUserDtoResult: Codable {
    let id: Int?
    let telegramId: String?
    let authDate: String?
    let hash: String?
    let lastName: String?
    let firstName: String?
    let username: String?
    let enabled: Bool
    let authStatus: AuthStatus?
    let roles: [Roles]?
}

enum AuthStatus: String, Codable {
    case approved = "APPROVED"
    case wait = "WAIT"
    case reject = "REJECT"
    case finished = "FINISHED"
    case unknown = "UNKNOWN"

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        switch rawValue {
        case AuthStatus.approved.rawValue:
            self = .approved
        case AuthStatus.wait.rawValue:
            self = .wait
        case AuthStatus.reject.rawValue:
            self = .reject
        case AuthStatus.finished.rawValue:
            self = .finished
        default:
            self = .unknown
        }
    }
}

enum Roles: String, Codable {
    case user = "ROLE_USER"
    case admin = "ROLE_ADMIN"
    case unknown = "UNKNOWN"

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        switch rawValue {
        case Roles.user.rawValue:
            self = .user
        case Roles.admin.rawValue:
            self = .admin
        default:
            self = .unknown
        }
    }
}
