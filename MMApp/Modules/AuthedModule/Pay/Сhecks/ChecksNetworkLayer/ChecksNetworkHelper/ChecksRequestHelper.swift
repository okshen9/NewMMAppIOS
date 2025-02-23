//
//  ChecksRequestHelper.swift
//  MMApp
//
//  Created by artem on 23.02.2025.
//

enum ChecksRequestHelper {
    // MARK: - Кейсы
    /// получение данных
    case getData(id: Int)

    // MARK: Query
    var query: ChecksQueryBuilder? {
        switch self {
        case let .getData(externalId):
            return ChecksQueryBuilder.getData(id: externalId)
        default:
            return nil
        }
    }
    
    // MARK: Путь
    var path: String {
        switch self {
        case let .getData(externalId):
            return RequestUrls.tgCallBack + "/test/" + externalId.toString
        }
    }
    
    // MARK: Метод
    var method: HTTPMethod {
        switch self {
        case .getData:
            return .get
        }
    }
}
