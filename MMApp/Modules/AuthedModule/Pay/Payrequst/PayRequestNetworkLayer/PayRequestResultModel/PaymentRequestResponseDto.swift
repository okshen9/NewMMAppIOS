//
//  PayRequestResultModel.swift
//  MMApp
//
//  Created by artem on 23.02.2025.
//

import Foundation

struct PaymentRequestResponseDto: Codable {
    let id: Int?
    let externalId: Int?
    let amount: Double?
    let dueDate: Date?
    let comment: String?
    let paymentRequestStatus: PaymentRequestStatus?
    let userProfilePreview: UserProfileResultDto?
}

enum PaymentRequestStatus: String, Codable, UnknownCasedEnum {
    case unknown = "UNKNOWN"
    
    case fullPaid = "FULL_PAID"
    case wait = "WAIT"
    case canceled = "CANCELED"
    case overdue = "OVERDUE"
    
    var description: String {
        switch self {
        case .fullPaid:
            return "Оплачено"
        case .wait:
            return "Ожидает оплаты"
        case .canceled:
            return "Запрос отменен"
        case .overdue:
            return "Частично оплачен."
        case .unknown:
            return "Нет информации"
        }
    }
}
