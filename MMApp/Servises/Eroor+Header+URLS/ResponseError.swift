//
//  ResponseError.swift
//  MMApp
//
//  Created by artem on 16.02.2025.
//

import Foundation

public enum ResponseError: Error {
    case noConnection
    case emptyData
    case notHTTPResponse(response: URLResponse?)
    case responseBase(response: BaseError, statusCode: Int)
    case response(response: HTTPURLResponse, responseData: Data, statusCode: Int, decoder: JSONDecoder)
    case mapping(response: HTTPURLResponse, error: Error, stringData: String)
    case invalidToken
    case invalidRefreshToken
    
    public var statusCode: Int? {
        switch self {
        case let .mapping(_, error, _):
            let nsError = error as NSError
            return nsError.code
            
        case let .response(_, _, statusCode, _):
            return statusCode

        case let .responseBase(_, statusCode):
            return statusCode

        default:
            return nil
        }
    }
}

extension ResponseError {
    func description(with path: String) -> String {
        let lineCount = max(path.count * 2, 30)
        var result = "\n\n  INFORMATION API ERROR \n"
        result += .topDebugLine(with: lineCount)
        result += "  Status Code: \(statusCode ?? 0000)"
        result += "\n  Path: \(path)"
        result += "\n  Error: \(descriptionError)\n"
        result += .bottomDebugLine(with: lineCount)
        return result
    }
    
    private var descriptionError: String {
        switch self {
        case .noConnection:
            return "noConnection"
        case .emptyData:
            return "emptyData"
        case let .mapping(_, error, _):
            return error.prettyDecodingDescription
        case let .notHTTPResponse(response):
            return "not a HTTPResponse: \(response?.url?.debugDescription ?? "nil url")"
        case let .response(response, _, _, _):
            return "\(response.url?.debugDescription ?? "nil url")"
        case let .responseBase(error, _):
            return error.message ?? "error message is empty"
        case .invalidToken:
            return "invalidToken"
        case .invalidRefreshToken:
            return "invalidRefreshToken"
        }
    }

    private var headers: String? {
        switch self {
        case .noConnection:
            return "noConnection"
        case .emptyData:
            return "emptyData"
        case let .mapping(_, error, _):
            return error.prettyDecodingDescription
        case let .notHTTPResponse(response):
            return "not a HTTPResponse: \(response?.url?.debugDescription ?? "nil url")"
        case let .response(response, _, _, _):
            return "\(response.allHeaderFields)"
        case .responseBase:
            return nil
        case .invalidToken:
            return "invalidToken"
        case .invalidRefreshToken:
            return "invalidRefreshToken"
        }
    }
}

// MARK: - Equatable

extension ResponseError: Equatable {
    public static func ==(lhs: ResponseError, rhs: ResponseError) -> Bool {
        switch (lhs, rhs) {
        case (.noConnection, .noConnection),
             (.emptyData, .emptyData),
             (.invalidToken, .invalidToken):
            return true
        case let (.notHTTPResponse(lhsResponse), .notHTTPResponse(rhsResponse)):
            return lhsResponse == rhsResponse
        case let (.responseBase(lhsResponse, lhsStatusCode), .responseBase(rhsResponse, rhsStatusCode)):
            return lhsResponse == rhsResponse && lhsStatusCode == rhsStatusCode
        case let (.response(lhsResponse, lhsData, lhsStatusCode, _), .response(rhsResponse, rhsData, rhsStatusCode, _)):
            return lhsResponse == rhsResponse && lhsData == rhsData && lhsStatusCode == rhsStatusCode
        case let (.mapping(lhsResponse, lhsError, lhsStringData), .mapping(rhsResponse, rhsError, rhsStringData)):
            return lhsResponse == rhsResponse && "\(lhsError)" == "\(rhsError)" && lhsStringData == rhsStringData
        default:
            return false
        }
    }
}

// MARK: - Debug line

public extension String {
    static func topDebugLine(with lineCount: Int) -> String {
        return "┏\(String(repeating: "━", count: lineCount))┓\n"
    }

    static func bottomDebugLine(with lineCount: Int) -> String {
        "┗\(String(repeating: "━", count: lineCount))┛\n"
    }
}
