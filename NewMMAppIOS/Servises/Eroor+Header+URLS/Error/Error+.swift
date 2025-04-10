//
//  File.swift
//  MMApp
//
//  Created by artem on 18.02.2025.
//


import Foundation

extension Error {
    var prettyDecodingDescription: String {

        guard let decodingError = self as? DecodingError else {
            return String(describing: self)
        }

        switch decodingError {
        case let .typeMismatch(key, context), let .valueNotFound(key, context):
            return decodingError.prettyPrint(key: key, context: context)
        case let .keyNotFound(key, context):
            return decodingError.prettyPrint(key: key.description, context: context)
        case let .dataCorrupted(context):
            return decodingError.prettyPrint(key: nil, context: context)
        default:
            return decodingError.typeName
        }
    }
}

private extension Error where Self == DecodingError {
    func prettyPrint(key: Any?, context: DecodingError.Context) -> String {
        var result = localizedDescription

        if let key = key {
            result += "\n   \(typeName): \(key)"
        }
        result += "\n   \(context.debugDescription)"
        return result
    }

    var typeName: String {
        switch self {
        case .typeMismatch:
            return "TypeMismatch"
        case .valueNotFound:
            return "ValueNotFound"
        case .keyNotFound:
            return "KeyNotFound"
        case .dataCorrupted:
            return "DataCorrupted"
        default:
            return "No name decoding error"
        }
    }
}
