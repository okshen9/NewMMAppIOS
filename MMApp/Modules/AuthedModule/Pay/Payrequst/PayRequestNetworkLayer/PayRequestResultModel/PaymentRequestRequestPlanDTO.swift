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
    let dueDate: Date?
    /// Массив идентификаторов связанных PaymentRequest
    let paymentRequestIds: [Int]?
}
