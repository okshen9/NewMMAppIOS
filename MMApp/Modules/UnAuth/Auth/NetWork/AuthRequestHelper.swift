//
//  RequestBulder.swift
//  MMApp
//
//  Created by artem on 05.01.2025.
//

import Foundation

enum AuthRequestHelper {
    /// user/auth/telegram/callback
    case sendTGToken(AuthQueryModel)
    
    /// user/authuser/me
    case getMe
    
    /// user-profile/me
    case createProfile

    /// Массив параметров
    var query: QueryItemsRepresentable? {
        switch self {
        case .sendTGToken(let model):
            return model
        case .getMe:
            return nil
        case let .createProfile:
            return nil
        }
    }

    /// Путь
    var path: String {
        switch self {
        case .sendTGToken:
            return RequestUrls.tgCallBack
        case .getMe:
            return RequestUrls.userProfileMe
        case .createProfile:
            return RequestUrls.userProfile
        }
    }

    /// Метод
    var method: HTTPMethod {
        switch self {
        case .sendTGToken, .getMe:
            return .get
        case .createProfile:
            return .post
        }
    }
}
