//
//  AuthRequestHelper.swift
//  MMApp
//
//  Created by artem on 18.02.2025.
//

enum AuthRequestHelper {
    /// user/auth/telegram/callback
    case sendTGToken(AuthQueryModel)
    
    /// user/authuser/me
    case getUserMe
    
    /// user-profile/me
    case createProfile
    
    /// /auth/refresh/
    case authuserRefreshJWT

    /// Массив параметров
    var query: QueryItemsRepresentable? {
        switch self {
        case .sendTGToken(let model):
            return model
        case .getUserMe:
            return nil
        case let .createProfile:
            return nil
        case .authuserRefreshJWT:
            return nil
        }
    }

    /// Путь
    var path: String {
        switch self {
        case .sendTGToken:
            return RequestUrls.tgCallBack
        case .getUserMe:
            return RequestUrls.userProfileMe
        case .createProfile:
            return RequestUrls.userProfile
        case .authuserRefreshJWT:
            return RequestUrls.authuserRefresh
        }
    }

    /// Метод
    var method: HTTPMethod {
        switch self {
        case .sendTGToken, .getUserMe:
            return .get
        case .createProfile, .authuserRefreshJWT:
            return .post
        }
    }
}
