//
//  ApiFactory.swift
//  MMApp
//
//  Created by artem on 05.01.2025.
//

import Foundation
import UIKit

struct EmptyResponse: Codable {}

public class APIDataTasksBuilder {
    
    private let decoder: JSONDecoder = .init()
    private var session: URLSession {
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.timeoutIntervalForRequest = 5
        return URLSession(configuration: config)
    }
    
    func buildDataTask<T: Decodable>(
        _ request: URLRequest,
        tokenNecessity: TokenNecessity = .mandatory
    ) async throws -> (response: T, headers: [AnyHashable : Any])
    {
        
        let isEmptyResponseAllowed = (T.self == EmptyResponse.self)
        let isRawResponseAllowed = (T.self == Data.self)
        let (data, response) = try await session.dataTask(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            //            let responseError = ResponseError.notHTTPResponse(response: response)
            //
            //            debugErrorHandler.error = responseError
            //
            //            throw responseError
            print("Neshko httpResponse Error")
            throw APIError.httpResponse
        }
        
        let httpStatusCode = httpResponse.statusCode
        
        
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
        
        do {
            let responseObject = try decoder.decode(T.self, from: data)
            return (responseObject, httpResponse.allHeaderFields)
        } catch {
            print("Neshko responseObject Error")
            throw APIError.responseObject
            //            let mapError = ResponseError.mapping(
            //                response: httpResponse,
            //                error: error,
            //                stringData: String(data: data, encoding: .utf8) ?? ""
            //            )
            //
            //            debugErrorHandler.error = mapError
            //            throw mapError
        }
    }
    
    /// Запрос в сеть без возвращаемого значения
    /// - Parameters:
    ///   - request: URL-request
    ///   - allowRetry: нужно ли ретраить
    public func buildEmptyDataTask(request: URLRequest, allowRetry: Bool) async throws {
        let _: (
            response: EmptyResponse, headers: [AnyHashable : Any]
        ) = try await self.buildDataTask(request)
    }

    /// Запрос в сеть, возвращает Data
    /// - Parameters:
    ///   - request: URL-request
    ///   - allowRetry: нужно ли ретраить
    public func buildRawDataTask(request: URLRequest, allowRetry: Bool) async throws -> (Data, headers: [AnyHashable : Any]) {
        let result: (
            response: Data, headers: [AnyHashable : Any]
        ) = try await self.buildDataTask(request)
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
            dataTask?.cancel()
        }

        return try await withTaskCancellationHandler(operation: {
            try await withCheckedThrowingContinuation { continuation in
                dataTask = self.dataTask(with: request) { data, response, error in
                    guard let data = data, let response = response else {
//                        let error = error ?? URLError.cannotBeFormed
//                        onError(error)
//                        return continuation.resume(throwing: error)
                        print("Neshko cannotBeFormed Error")
                        return continuation.resume(throwing: error ?? URLError.cannotBeFormed)
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
