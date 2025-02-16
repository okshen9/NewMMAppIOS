//
//  TargetRequestHelper.swift
//  MMApp
//
//  Created by artem on 16.02.2025.
//

enum TargetRequestHelper {
    // MARK: - Кейсы
    /// получение данных
    case getData(id: Int)

    // MARK: Query
    var query: TargetQueryBuilder? {
        switch self {
        case let .getData(externalId):
            return TargetQueryBuilder.getData(id: externalId)
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
