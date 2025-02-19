//
//  TargetRequestHelper.swift
//  MMApp
//
//  Created by artem on 16.02.2025.
//

enum TargetRequestHelper {
    // MARK: - Кейсы
    
    /// Создание цели пользователя
    /// POST /user-target
    case createUserTarget
    
    /// получение цели id цели
    /// GET /user-target
    case getTarget(targetId: Int)
    
    /// получение всех целей пользователя по externalId пользователя
    /// GET /user-target/user-profile/{externalUserId}
    case getUserTargets(externalId: Int)
    
    /// Обновление цели и подцели
    /// /PATCH /user-target/all
    case updateTargetAll
    
    /// POST /user-report
    /// Создать отчёт по цели
//    case createUserReport
    
    /// GET /user-report/user-target/{targetId}
    /// Получение списка отчётов по цели
//    case getUserReports(targetId: Int)

    // MARK: Query
    var query: TargetQueryBuilder? {
        switch self {
//        case let .getData(externalId):
//            return TargetQueryBuilder.getData(id: externalId)
        default:
            return nil
        }
    }
    
    // MARK: Путь
    var path: String {
        switch self {
        case .createUserTarget:
            return RequestUrls.userTarget
        case let .getTarget(targetId):
            return RequestUrls.userTarget + "/" + targetId.toString
        case let .getUserTargets(externalId):
            return RequestUrls.userTargetForUser + "/" + externalId.toString
        case .updateTargetAll:
            return RequestUrls.userTargetAllUpdate
        }
    }
    
    // MARK: Метод
    var method: HTTPMethod {
        switch self {
        case .createUserTarget:
            return .post
        case .getTarget(targetId: let targetId):
            return .get
        case .getUserTargets:
            return .get
        case .updateTargetAll:
            return .patch
        }
    }
}
