//
//  APIURLRequestsBuilder.swift
//  MMApp
//
//  Created by artem on 07.01.2025.
//

import Foundation
import UIKit

public enum TokenNecessity {
    case mandatory
    case notNeeded
    case upload
    case refreshToken
}

public protocol RequestDecorator {
    func decorate(_ request: inout URLRequest)
}

public struct APIURLRequestsBuilder {
//    private let tokenStorage: KeychainStorageProtocol = KeychainStorage()
    private let requestDecorators: [RequestDecorator]
    
    public init(
        requestDecorators: [RequestDecorator] = []
    ) {
        self.requestDecorators = requestDecorators
    }
}

// MARK: APIURLRequestsBuilding

extension APIURLRequestsBuilder {
    // Create simple URL query. Params added to url string
    public func buildURLRequest(
        url: URL,
        query: QueryItemsRepresentable?,
        method: HTTPMethod,
        tokenNeccessity: TokenNecessity = .mandatory
    ) throws -> URLRequest {
        var completedURL = url
        
        if let query = query {
            completedURL = try url.appendedURL(queryItems: query.queryItems())
        }
        
        var request = URLRequest(
            url: completedURL
        )
        request.httpMethod = method.rawValue
        
        try addCommonHeaders(&request, tokenNeccessity: tokenNeccessity)
        
        return request
    }

    // Create URL query. JSON params added to body
    public func buildJSONParamsRequest(
        url: URL,
        bodyModel: JSONRepresentable,
        query: QueryItemsRepresentable? = nil,
        method: HTTPMethod,
        tokenNeccessity: TokenNecessity = .mandatory
    ) throws -> URLRequest {
        var completedURL = url
        
        if let query = query {
            completedURL = try url.appendedURL(queryItems: query.queryItems())
        }
        
        var request = URLRequest(url: completedURL)
        request.httpMethod = method.rawValue
        request.httpBody = bodyModel.toData()
        
        request.httpShouldHandleCookies = false

        request.addValue(
            HTTPHeaderValue.appJson,
            forHTTPHeaderField: HTTPHeader.contentType
        )

        try addCommonHeaders(&request, tokenNeccessity: tokenNeccessity)

        return request
    }
}

extension APIURLRequestsBuilder {
    // Add additional headers to URLRequest
    public func addAdditionalHeaders(_ request: inout URLRequest, additionalHeaders: [String: String]) {
        additionalHeaders.forEach { header in
            request.addValue(header.value, forHTTPHeaderField: header.key)
        }
    }
    
    private func addCommonHeaders(
        _ request: inout URLRequest,
        tokenNeccessity: TokenNecessity = .mandatory
    ) throws {
        switch tokenNeccessity {
        case .mandatory:
            

            if let token = KeyChainStorage.jwtToken.getData() {
                
                request.setValue("Bearer \(token)", forHTTPHeaderField: HTTPHeader.authorization)
            }
            print("\(request)")
        case .notNeeded:
            break
        case .upload:
//            let tokens: AuthTokens? = try? tokenStorage.read()
//
//            if let accessToken = tokens?.accessToken {
//                request.setValue("wasd-access-token=\(accessToken)", forHTTPHeaderField: HTTPHeader.authorization)
//            }
            break
        case .refreshToken:
//            let tokens: AuthTokens? = try? tokenStorage.read()

//            if let captcha = tokens?.captchaToken {
//                request.setValue(HTTPHeaderValue.smartCaptcha, forHTTPHeaderField: HTTPHeader.captchaVersion)
//            }
            break
        }

        // device_id (wudid) для событий аналитики
//        request.setValue(UIDevice.current.identifierForVendor?.uuidString ?? "", forHTTPHeaderField: HTTPHeader.wudid)

        // TODO - Вынести extension с Bundle в Foundation и переписать на Bundle.main.buildVersionNumber ..
//        let releaseVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? ""
//        let buildVersion = (Bundle.main.infoDictionary?["CFBundleVersion"] as? String) ?? ""
//
//        request.setValue("iOS/\(releaseVersion) (\(buildVersion))", forHTTPHeaderField: HTTPHeader.userAgent)

        requestDecorators.forEach { $0.decorate(&request) }
    }
    
}
