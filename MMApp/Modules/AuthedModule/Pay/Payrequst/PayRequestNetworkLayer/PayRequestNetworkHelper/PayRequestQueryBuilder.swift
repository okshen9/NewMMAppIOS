//
//  PayRequestQueryBuilder.swift
//  MMApp
//
//  Created by artem on 23.02.2025.
//

import Foundation

enum PayRequestQueryBuilder: QueryItemsRepresentable {
    // MARK: - Кейсы
    /// получение данных
    case getData(id: Int)

    // MARK: Query
    var query: PayRequestQueryBuilder? {
        switch self {
        case let .getData(externalId):
            return PayRequestQueryBuilder.getData(id: externalId)
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

private extension PayRequestQueryBuilder {
    enum Constants {
        static let externalId = "externalId"
    }
}
