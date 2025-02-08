//
//  Errors.swift
//  MMApp
//
//  Created by artem on 05.01.2025.
//

import Foundation

public enum APIError: Error {
    case httpResponse
    case isEmptyResponseAllowed
    case responseObject
    case cannotBeFormed
    case failedToken
}

public enum URLError: Error {
    case cannotBeFormed
}
