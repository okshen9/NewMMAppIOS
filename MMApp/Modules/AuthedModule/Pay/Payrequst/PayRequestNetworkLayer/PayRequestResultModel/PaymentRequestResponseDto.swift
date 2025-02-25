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
    let dueDate: String?
    let comment: String?
    let paymentRequestStatus: PaymentRequestStatus?
    let userProfilePreview: UserProfileResultDto?
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(Int.self, forKey: .id)
        self.externalId = try container.decodeIfPresent(Int.self, forKey: .externalId)
        self.amount = try container.decodeIfPresent(Double.self, forKey: .amount)
        self.dueDate = try container.decodeIfPresent(String.self, forKey: .dueDate)
        self.comment = try container.decodeIfPresent(String.self, forKey: .comment)
        self.paymentRequestStatus = try container.decodeIfPresent(PaymentRequestStatus.self, forKey: .paymentRequestStatus)
        self.userProfilePreview = try container.decodeIfPresent(UserProfileResultDto.self, forKey: .userProfilePreview)
    }
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
            return "Просрочено"
        case .unknown:
            return "Нет информации"
        }
    }
}
