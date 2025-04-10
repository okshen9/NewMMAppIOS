//
//  ChecksResultModel.swift
//  MMApp
//
//  Created by artem on 23.02.2025.
//

import Foundation

struct ReceiptDtoResponse: Codable {
    /// Идентификатор записи
    let id: Int?
    /// Внешний идентификатор
    let externalId: Int?
    /// Связанный объект PaymentRequestResponseDto
    let paymentRequestResponseDto: PaymentRequestResponseDto?
    /// Сумма
    let amount: Double?
    /// Тип квитанции
    let receiptType: ReceiptType?
}

// Перечисление типов квитанций
enum ReceiptType: String, Codable, UnknownCasedEnum {
    /// СБП
    case sbp = "SBP"
    /// Наличные
    case cash = "CASH"
    /// Криптовалюта
    case crypto = "CRYPTO"
    /// Карта
    case card = "CARD"
    
    case unknown = "UNKNOWN"
    
    var description: String {
        switch self {
        case .sbp:
            return "СБП"
        case .cash:
            return "Наличка"
        case .crypto:
            return "Крипта"
        case .card:
            return "Карта"
        case .unknown:
            return "Слово джентльмена"
        }
    }
}
