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
    case failedRefreshToken
}

public enum URLError: Error {
    case cannotBeFormed
}


// Ошибки сети
enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingFailed
}
