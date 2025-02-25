//
//  PayRequestResultModel.swift
//  MMApp
//
//  Created by artem on 23.02.2025.
//

import Foundation


// Результативная модель PaymentRequestRequestPlanDTO
struct PaymentRequestRequestPlanDTO: Codable {
    /// Идентификатор записи
    let id: Int?
    /// Внешний идентификатор
    let externalId: Int?
    /// Дата оплаты
    let dueDate: String?
    /// Массив идентификаторов связанных PaymentRequest
    let paymentRequestIds: [PaymentRequestResponseDto]?
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(Int.self, forKey: .id)
        self.externalId = try container.decodeIfPresent(Int.self, forKey: .externalId)
        self.dueDate = try container.decodeIfPresent(String.self, forKey: .dueDate)
        self.paymentRequestIds = try container.decodeIfPresent([PaymentRequestResponseDto].self, forKey: .paymentRequestIds)
    }
}
