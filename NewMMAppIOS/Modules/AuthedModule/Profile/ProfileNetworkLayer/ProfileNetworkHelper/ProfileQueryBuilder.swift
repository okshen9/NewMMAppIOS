//
//  ProfileQueryBuilder.swift
//  MMApp
//
//  Created by artem on 24.02.2025.
//

import Foundation

enum ProfileQueryBuilder: QueryItemsRepresentable {
    // MARK: - Кейсы
    /// получение данных
    case getData(id: Int)

    // MARK: Query
    var query: ProfileQueryBuilder? {
        switch self {
        case let .getData(externalId):
            return ProfileQueryBuilder.getData(id: externalId)
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

private extension ProfileQueryBuilder {
    enum Constants {
        static let externalId = "externalId"
    }
}
