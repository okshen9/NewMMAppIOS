//
//  AbstractService.swift
//  MMApp
//
//  Created by artem on 16.02.2025.
//

import Foundation

open class AbstractService {
    private let dataTaskBuilder: APIDataTasksBuilder
    
    public init(dataTaskBuilder: APIDataTasksBuilder) {
        self.dataTaskBuilder = dataTaskBuilder
    }
    
    public func performRequest<Response: Decodable>(
        makeRequest: () throws -> URLRequest,
        allowRetry: Bool = true
    ) async throws -> Response {
        let request: URLRequest
        do {
            request = try makeRequest()
        } catch {
            throw ResponseError.noConnection
        }

        return try await self.dataTaskBuilder.buildDataTask(request, allowRetry: allowRetry).response
    }
    
    public func performEmptyRequest(
        makeRequest: () throws -> URLRequest
    ) async throws {
        let request: URLRequest
        do {
            request = try makeRequest()
        } catch {
            throw ResponseError.noConnection
        }
        return try await self.dataTaskBuilder.buildEmptyDataTask(request: request, allowRetry: true)
    }

    public func performRequestWithHeaders<Response: Decodable> (
        makeRequest: () throws -> URLRequest,
        allowRetry: Bool = true
    ) async throws -> (response: Response, headers: [AnyHashable : Any]) {
        let request: URLRequest
        do {
            request = try makeRequest()
        } catch {
            throw ResponseError.noConnection
        }

        return try await self.dataTaskBuilder.buildDataTask(request, allowRetry: allowRetry)
    }

    public func performRawRequest(
        makeRequest: () throws -> URLRequest
    ) async throws -> Data {
        let request: URLRequest
        do {
            request = try makeRequest()
        } catch {
            throw ResponseError.noConnection
        }
        return try await self.dataTaskBuilder.buildRawDataTask(request: request, allowRetry: true).0
    }

    public func performRawRequestWithHeaders(
        makeRequest: () throws -> URLRequest
    ) async throws -> (Data, headers: [AnyHashable : Any]) {
        let request: URLRequest
        do {
            request = try makeRequest()
        } catch {
            throw ResponseError.noConnection
        }
        return try await self.dataTaskBuilder.buildRawDataTask(request: request, allowRetry: true)
    }
}
