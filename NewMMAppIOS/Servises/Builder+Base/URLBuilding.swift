//
//  URLBuilding.swift
//  MMApp
//
//  Created by artem on 07.01.2025.
//

import Foundation

public protocol URLBuilding {
    /// Получение урла вида https://demo.nuum.ru/api/v2/profiles/current/events
    /// - Parameter path: путь
    /// - Returns: URL
    func buildURL(path: String) throws -> URL
    /// Получение урла без добавления 'api', вида https://demo.nuum.ru/stats/api/events
    /// - Parameter path: путь
    /// - Returns: URL
    func buildCustomURL(path: String) throws -> URL
    /// Получение урла https://int-fin-srv.nuum.ru/api/stats/api/events
    /// - Parameters:
    ///   - domain: домен
    ///   - path: путь
    /// - Returns: URL
    func buildCustomURL(customDomain: String, path: String) throws -> URL
}

public extension URLBuilding {
    /// Схема HTTPS
    var httpsScheme: String { "https://" }
    
    /// Получение URL для сервиса Контента
    /// Пример: https://content.nuum.ru/content/music/v1/tracks/
    /// - Parameters:
    ///   - domain: домен
    ///   - path: путь
    /// - Returns: URL
    func buildContentURL(domain: String, path: String) throws -> URL {
        var path = path
        
        if !path.hasPrefix("/") {
            path = "/" + path
        }
        
        let urlString = httpsScheme + domain + path
        
        guard let url = URL(string: urlString) else { throw URLError.cannotBeFormed }
        return url
    }
}

// MARK: - URLBuilding

public struct APIURLBuilder: URLBuilding {
//    #if DEBUG
    let baseUrl = RequestUrls.testBaseUrl
//    #else
//    let baseUrl = RequestUrls.prodBaseUrl
//    #endif
    
    
    public func buildURL(path: String) throws -> URL {
        var path = path

        if !path.hasPrefix("/") {
            path = "/" + path
        }

        let urlString = baseUrl + path

        guard let url = URL(string: urlString) else {
            throw URLError.cannotBeFormed
        }

        return url
    }

    public func buildCustomURL(path: String) throws -> URL {
        var path = path

        if !path.hasPrefix("/") {
            path = "/" + path
        }

        let urlString = baseUrl + path

        guard let url = URL(string: urlString) else {
            throw URLError.cannotBeFormed
        }

        return url
    }

    public func buildCustomURL(customDomain: String, path: String) throws -> URL {
        var path = path

        if !path.hasPrefix("/") {
            path = "/" + path
        }

        let urlString = customDomain + path

        guard let url = URL(string: urlString) else {
            throw URLError.cannotBeFormed
        }

        return url
    }
}
