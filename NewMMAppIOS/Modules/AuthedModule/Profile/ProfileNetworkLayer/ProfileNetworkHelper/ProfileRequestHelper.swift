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
    /// получение группы
    case getGroup(groupId: Int)

    // MARK: Query
    var query: ProfileQueryBuilder? {
        switch self {
        case let .getData(externalId):
            return ProfileQueryBuilder.getData(id: externalId)
        case .sendComplaint, .getGroup:
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
        case let .getGroup(groupId):
            return RequestUrls.userGroup + "/" + groupId.toString
        }
    }
    
    // MARK: Метод
    var method: HTTPMethod {
        switch self {
        case .getData:
            return .get
        case .sendComplaint:
            return .post
        case .getGroup(groupId: let groupId):
            return .get
        }
    }
}
