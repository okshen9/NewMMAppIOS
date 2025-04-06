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

    /// user-profile/me
    case patchMe

    /// /user/auth/refresh
    case authuserRefreshJWT
    
    case getUserProfile(Int)

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
        case .getUserProfile(_):
            return nil
        case .patchMe:
            return nil
        }
    }

    /// Путь
    var path: String {
        switch self {
        case .sendTGToken:
            print("Neshko - sendTGToken")
            return RequestUrls.tgCallBack
        case .getUserMe:
            return RequestUrls.userProfileMe
        case .createProfile:
            return RequestUrls.userProfile
        case .patchMe:
            return RequestUrls.userProfileMe
        case .authuserRefreshJWT:
            return RequestUrls.authuserRefresh
        case .getUserProfile(let externalId):
            return "\(RequestUrls.userProfile)/\(externalId)"
        }
    }

    /// Метод
    var method: HTTPMethod {
        switch self {
        case .sendTGToken, .getUserMe, .getUserProfile(_):
            return .get
        case .createProfile, .authuserRefreshJWT:
            return .post
        case .patchMe:
            return .patch
        }
    }
}
