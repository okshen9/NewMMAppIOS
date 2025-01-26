//
//  QueryModel.swift
//  MMApp
//
//  Created by artem on 05.01.2025.
//

import Foundation
struct FavoritesQueryModel: QueryItemsRepresentable {
    /// ТГ токен
    let jwt: String

    func queryItems() -> [URLQueryItem] {
        var items = [URLQueryItem]()

        items.append(URLQueryItem(name: Constants.jwtKey, value: jwt))

        return items
    }
}

private extension FavoritesQueryModel {
    // MARK: - Constants

    enum Constants {
        static let jwtKey = "jwt"
    }
}
