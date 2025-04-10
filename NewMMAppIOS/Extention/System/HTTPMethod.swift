//
//  HTTPMethod.swift
//  MMApp
//
//  Created by artem on 05.01.2025.
//

import Foundation

public enum HTTPMethod: String, CustomStringConvertible {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
    case put = "PUT"
    case patch = "PATCH"

    public var description: String {
        return rawValue
    }
}
