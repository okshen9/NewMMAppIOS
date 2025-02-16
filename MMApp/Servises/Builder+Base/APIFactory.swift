//
//  APIFactory.swift
//  MMApp
//
//  Created by artem on 07.01.2025.
//

import Foundation

public struct APIFactory  {
    public var urlBuilder: URLBuilding = APIURLBuilder()
    public var requestBuilder: APIURLRequestsBuilder = APIURLRequestsBuilder(requestDecorators: [])
    
    // requered - нужно удалить
    public var dataTaskBuilder: APIDataTasksBuilder = APIDataTasksBuilder()

    
    static let global = APIFactory()
//    public init() {}
//    
//    public init(
//        urlBuilder: URLBuilding,
//        requestBuilder: APIURLRequestsBuilder
//    ) {
//        self.urlBuilder = urlBuilder
//        self.requestBuilder = requestBuilder
//    }
}
