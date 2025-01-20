//
//  URL+.swift
//  MMApp
//
//  Created by artem on 07.01.2025.
//

import Foundation

extension URL {
    func appendedURL(queryItems appendQueryItems: [URLQueryItem]) throws -> URL {
        if appendQueryItems.isEmpty {
            return self
        }

        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            throw URLError.cannotBeFormed
        }

        var newQueryItemsList = components.queryItems

        if newQueryItemsList == nil {
            newQueryItemsList = [URLQueryItem]()
        }

        newQueryItemsList?.append(contentsOf: appendQueryItems)

        components.queryItems = newQueryItemsList

        guard let appendedURL = components.url else {
            throw URLError.cannotBeFormed
        }

        return appendedURL
    }
    
    func queryItem(_ name: String) -> String? {
        return URLComponents(url: self, resolvingAgainstBaseURL: false)?.queryItems?.first(where: { $0.name == name })?.value
    }
}
