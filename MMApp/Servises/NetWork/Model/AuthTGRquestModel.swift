//
//  AuthTGRequestModel.swift
//  MMApp
//
//  Created by artem on 07.01.2025.
//

import Foundation

struct AuthTGRequestModel: Codable {
    let jwt: String
    let refreshToken: String
    let authUserDto: AuthUserDtoResult?
    let status: AuthStatus?
}

struct AuthUserDtoResult: Codable, JSONRepresentable {
    /// externalId
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
    var photoUrl: String?
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

enum Roles: String, Codable, UnknownCasedEnum {
    case user = "ROLE_USER"
    case admin = "ROLE_ADMIN"
    case draft = "ROLE_DRAFT"
    case unknown = "UNKNOWN"

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        switch rawValue {
        case Roles.user.rawValue:
            self = .user
        case Roles.admin.rawValue:
            self = .admin
        case Roles.draft.rawValue:
            self = .draft
        default:
            self = .unknown
        }
    }
}
