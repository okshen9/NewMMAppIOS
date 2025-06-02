//
//  ApiFactory.swift
//  MMApp
//
//  Created by artem on 05.01.2025.
//

import Foundation
import UIKit
import SwiftUI

struct EmptyResponse: Codable {}

public class APIDataTasksBuilder {
    
    private let apiFactory: APIFactory
//    private let authService: AuthServiceProtocol
    private var decoder: JSONDecoder = .init()
    private var session: URLSession {
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.timeoutIntervalForRequest = 5
		var delegat: URLSessionDelegate? {
			if AppStateSystemService.shared.prodServ != .prod {
				return UnsafeSSLDelegate()
			} else {
				return nil
			}
		}
		var session = URLSession(configuration: config, delegate: delegat, delegateQueue: .main)

        return session
    }
    

    private var refreshManager = UserRepository.shared
    
    public init(
        apiFactory: APIFactory? = nil
//        authService: AuthServiceProtocol,
//        decoder: JSONDecoder,
//        session: URLSession,
//        serverApiUrlString: String
    ) {
        self.apiFactory = apiFactory ?? APIFactory.global
//        self.authService = authService
//        self.decoder = decoder
//        self.session = session
//        self.serverApiUrlString = serverApiUrlString
    }

    private func setTokensToRequest(_ request: inout URLRequest, authTokens: String) -> URLRequest {
        request.setValue("Bearer \(authTokens)", forHTTPHeaderField: HTTPHeader.authorization)
        
        return request
    }
}
//TODO
struct NotyInfo {
    let plase: String
    let status: String
    let url: String
    let description: String
    let code: String

    var displayMessage: String {
        return """
===== Start
plase: \(plase)
status: \(status)
url: \(url)
description: \(description)
code: \(code)
===== End
"""
    }
}

extension APIDataTasksBuilder {
    
    func buildDataTask<T: Decodable>(
        _ request: URLRequest,
        tokenNecessity: TokenNecessity = .mandatory,
        allowRetry: Bool
    ) async throws -> (response: T, headers: [AnyHashable : Any])
    {
        let testNotification = NSNotification.Name(rawValue: "testNotification")

        let isEmptyResponseAllowed = (T.self == EmptyResponse.self)
        let isRawResponseAllowed = (T.self == Data.self)
        let (data, response) = try await session.dataTask(for: request)
        //TODO
        defer {
            let httpResponse = (response as? HTTPURLResponse)?.statusCode.toString
            let noty = NotyInfo(
                plase: "APIDataTasksBuilder defer",
                status: "Any",
                url: (response.url?.absoluteString) ?? "-",
                description: response.description,
                code: httpResponse ?? "NoCode")

            NotificationCenter.default.post(name: testNotification, object: noty)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            //            let responseError = ResponseError.notHTTPResponse(response: response)
            //            throw responseError
            print("Neshko httpResponse Error")
            throw APIError.httpResponse
        }

        let apiError = (try? JSONDecoder().decode(BaseError.self, from: data)) ?? BaseError(errorCode: "UNKNOWN", errorMessage: "Что-то пошло не так")

        let httpStatusCode = httpResponse.statusCode
        
        switch httpStatusCode {
        case 200..<300:
            break
        case 401:
            if allowRetry {
                do {
//                    guard let refreshManager else {
//                        throw ResponseError.invalidToken
//                    }
                    let newToken = try await refreshManager.makeRefreshToken()
                    var request = request
                    let newRequest = setTokensToRequest(&request, authTokens: newToken)
                    return try await buildDataTask(newRequest, allowRetry: true)
                } catch {
                    do {
                        let newToken = try await refreshManager.makeRefreshAuthFormTG()
                        var request = request
                        let newRequest = setTokensToRequest(&request, authTokens: newToken)
                        return try await buildDataTask(newRequest, allowRetry: false)
                    }
                    catch{
                        await MainActor.run {
                            refreshManager.clearAll()
                            let authView = AuthSUIView()
                            let newViewController = UIHostingController(rootView: authView)
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let window = windowScene.windows.first {
                                window.rootViewController = newViewController
                                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {}, completion: nil)
                            }
                        }
                        throw ResponseError.invalidRefreshToken
                    }
                }
            }
        case 402:
            throw ResponseError.responseBase(response: apiError, statusCode: httpStatusCode)
        case 403:
            print("==== Закрыт доступ - кривой URL ====")
            throw ResponseError.responseBase(response: apiError, statusCode: 403)
        case 404..<600:
            throw ResponseError.responseBase(response: apiError, statusCode: httpStatusCode)
        default:
            break
        }
        
        if data.isEmpty {
            if isEmptyResponseAllowed {
                // For case when backend send empty response (only http code)
                return (EmptyResponse() as! T, httpResponse.allHeaderFields)
            } else {
                //                let responseError = ResponseError.emptyData
                //                debugErrorHandler.error = ResponseError.emptyData
                //
                //                throw responseError
                print("Neshko isEmptyResponseAllowed Error")
                throw APIError.isEmptyResponseAllowed
            }
        } else if isEmptyResponseAllowed {
            // For case when backend sent nonempty response and we don't care of it
            return (EmptyResponse() as! T, httpResponse.allHeaderFields)
        } else if isRawResponseAllowed {
            return (data as! T, httpResponse.allHeaderFields)
        }
        
        let jsonString = String(data: data, encoding: .utf8) ?? "<не удалось сконвертировать в строку>"
        
        do {
            let responseObject = try decoder.decode(T.self, from: data)
            return (responseObject, httpResponse.allHeaderFields)
        } catch let error as DecodingError {
            switch error {
            case .keyNotFound(let key, let context):
                print("❌ Key '\(key.stringValue)' not found: \(context.debugDescription), path: \(context.codingPath)")
            case .typeMismatch(let type, let context):
                print("❌ Type '\(type)' mismatch: \(context.debugDescription), path: \(context.codingPath)")
            case .valueNotFound(let type, let context):
                print("❌ Value '\(type)' not found: \(context.debugDescription), path: \(context.codingPath)")
            case .dataCorrupted(let context):
                print("❌ Data corrupted: \(context.debugDescription), path: \(context.codingPath)")
            @unknown default:
                print("❌ Unknown decoding error: \(error)")
            }
            throw APIError.responseObject
        } catch {
            print("❌ Other error: \(error)")
            throw APIError.responseObject
        }
    }
    
    /// Запрос в сеть без возвращаемого значения
    /// - Parameters:
    ///   - request: URL-request
    ///   - allowRetry: нужно ли ретраить
    public func buildEmptyDataTask(request: URLRequest, allowRetry: Bool) async throws {
        let _: (
            response: EmptyResponse, headers: [AnyHashable : Any]
        ) = try await self.buildDataTask(request, allowRetry: allowRetry)
    }

    /// Запрос в сеть, возвращает Data
    /// - Parameters:
    ///   - request: URL-request
    ///   - allowRetry: нужно ли ретраить
    public func buildRawDataTask(request: URLRequest, allowRetry: Bool) async throws -> (Data, headers: [AnyHashable : Any]) {
        let result: (
            response: Data, headers: [AnyHashable : Any]
        ) = try await self.buildDataTask(request, allowRetry: allowRetry)
        return result
    }
}


extension URLSession {
    /// Позволяет отдать управление URLSessionDataDelegate
    /// По дефолту, если юзать async/await, URLSession не нотифает `URLSessionDataDelegate`.
    func dataTask(for request: URLRequest) async throws -> (Data, URLResponse) {
        var dataTask: URLSessionDataTask?

        let onSuccess: (Data, URLResponse) -> Void = { (data, response) in
            guard let dataTask, let dataDelegate = self.delegate as? URLSessionDataDelegate else {
                return
            }
            dataDelegate.urlSession?(self, dataTask: dataTask, didReceive: data)
            dataDelegate.urlSession?(self, task: dataTask, didCompleteWithError: nil)
        }

        let onError: (Error) -> Void = { error in
            guard let dataTask, let dataDelegate = self.delegate as? URLSessionDataDelegate else {
                return
            }
            dataDelegate.urlSession?(self, task: dataTask, didCompleteWithError: error)

        }

        let onCancel = {
            print("onCancel")
            dataTask?.cancel()
        }

        return try await withTaskCancellationHandler(operation: {
            try await withCheckedThrowingContinuation { continuation in
                dataTask = self.dataTask(with: request) { data, response, error in
                    guard let data = data, let response = response else {
                        let error = error ?? URLError.cannotBeFormed
                        onError(error)
                        print("Neshko withCheckedThrowingContinuation Error")
                        return continuation.resume(throwing: error)

//                        return continuation.resume(throwing: error ?? URLError.cannotBeFormed)
                    }
                    onSuccess(data, response)
                    continuation.resume(returning: (data, response))
                }
                dataTask?.resume()
            }
        }, onCancel: {
            onCancel()
        })
    }
}
