//
//  ProfileRequestHelper.swift
//  MMApp
//
//  Created by artem on 24.02.2025.
//

enum ProfileRequestHelper {
    // MARK: - Кейсы
    /// получение данных
    case getData(id: Int)
    /// отправка жалобы
    case sendComplaint

    // MARK: Query
    var query: ProfileQueryBuilder? {
        switch self {
        case let .getData(externalId):
            return ProfileQueryBuilder.getData(id: externalId)
        case .sendComplaint:
            return nil
        }
    }
    
    // MARK: Путь
    var path: String {
        switch self {
        case let .getData(externalId):
            return RequestUrls.tgCallBack + "/test/" + externalId.toString
        case .sendComplaint:
            return RequestUrls.complaint
        }
    }
    
    // MARK: Метод
    var method: HTTPMethod {
        switch self {
        case .getData:
            return .get
        case .sendComplaint:
            return .post
        }
    }
}
