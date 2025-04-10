//
//  AuthQueryBuilder.swift
//  MMApp
//
//  Created by artem on 18.02.2025.
//

import Foundation

enum AuthQueryBuilder: QueryItemsRepresentable {
    // MARK: - Кейсы
    /// получение данных
    case getData(id: Int)

    // MARK: Query
    var query: AuthQueryBuilder? {
        switch self {
        case let .getData(externalId):
            return AuthQueryBuilder.getData(id: externalId)
        default:
            return nil
        }
    }
    
    // MARK: Путь
    func queryItems() -> [URLQueryItem] {
        var items = [URLQueryItem]()
        
        switch self {
        case let .getData(externalId):
            items.append(URLQueryItem(name: Constants.externalId, value: externalId.toString))
            return items
        default:
            return items
        }
    }
}

private extension AuthQueryBuilder {
    enum Constants {
        static let externalId = "externalId"
    }
}
