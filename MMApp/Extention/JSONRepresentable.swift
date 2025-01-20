//
//  JSONRepresentable.swift
//  MMApp
//
//  Created by artem on 07.01.2025.
//

import Foundation

// Если запрос требует наличие message body с SnakeCase кодировкой contractID -> contract_id
public protocol JSONRepresentable: Codable {
    func toData() -> Data?
}

public extension JSONRepresentable {
    func toData() -> Data? {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return try? encoder.encode(self)
    }
}
