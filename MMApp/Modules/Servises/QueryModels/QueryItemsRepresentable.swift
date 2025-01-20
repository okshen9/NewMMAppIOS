//
//  QueryItemsRepresentable.swift
//  MMApp
//
//  Created by artem on 05.01.2025.
//

import Foundation

// Если запрос требует наличия каких либо параметров, например '?source_lang=en&target_lang=ru&text=query'
public protocol QueryItemsRepresentable {
    func queryItems() -> [URLQueryItem]
}
