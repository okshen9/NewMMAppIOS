//
//  RequestBulder.swift
//  MMApp
//
//  Created by artem on 05.01.2025.
//

import Foundation

enum AuthRequestHelper {
    /// Очистить Избранные
    case sendTGToken(String)

    /// Массив параметров
    var query: AuthQueryModel? {
        switch self {
        case .sendTGToken(let token):
            return AuthQueryModel(tgData: token)
        }
    }

    /// Путь
    var path: String {
        switch self {
        case .sendTGToken:
            return RequestUrls.tgCallBack
        }
    }

    /// Метод
    var method: HTTPMethod {
        switch self {
        case .sendTGToken:
            return .get
        }
    }
}
