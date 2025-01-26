//
//  JSONRepresentable.swift
//  MMApp
//
//  Created by artem on 07.01.2025.
//

import Foundation

// Если запрос требует наличие message body с CamalCase кодировкой contractID -> contractId
public protocol JSONRepresentable: Codable {
    func toData() -> Data?
}

public extension JSONRepresentable {
    func toData() -> Data? {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .useDefaultKeys
        return try? encoder.encode(self)
    }
}
