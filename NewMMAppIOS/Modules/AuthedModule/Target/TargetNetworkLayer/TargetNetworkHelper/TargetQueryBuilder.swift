//
//  TargetQueryBuilder.swift
//  MMApp
//
//  Created by artem on 16.02.2025.
//

import Foundation

enum TargetQueryBuilder: QueryItemsRepresentable {
    // MARK: - Кейсы
    /// получение данных
    case getData(id: Int)

    // MARK: Query
    var query: TargetQueryBuilder? {
        switch self {
        case let .getData(externalId):
            return TargetQueryBuilder.getData(id: externalId)
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

private extension TargetQueryBuilder {
    enum Constants {
        static let externalId = "externalId"
    }
}
