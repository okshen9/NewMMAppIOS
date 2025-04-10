//
//  PayRequestRequestHelper.swift
//  MMApp
//
//  Created by artem on 23.02.2025.
//

enum PayRequestRequestHelper {
    // MARK: - Кейсы
    /// получение данных
    case getData(id: Int)
    
    case getPaymentPlan(id: Int)

    // MARK: Query
    var query: PayRequestQueryBuilder? {
        switch self {
        case let .getData(externalId):
            return PayRequestQueryBuilder.getData(id: externalId)
        default:
            return nil
        }
    }
    
    // MARK: Путь
    var path: String {
        switch self {
        case let .getData(externalId):
            return RequestUrls.tgCallBack + "/test/" + externalId.toString
        case .getPaymentPlan(let id):
            return RequestUrls.paymentPlanForExternalId //+ "/" + id.toString
        }
    }
    
    // MARK: Метод
    var method: HTTPMethod {
        switch self {
        case .getData, .getPaymentPlan:
            return .get
        }
    }
}
