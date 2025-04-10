//
//  EventType.swift
//  MMApp
//
//  Created by artem on 06.04.2025.
//


enum EventType: String, Codable, JSONRepresentable, UnknownCasedEnum {
    case unknown = "Статус не распознан"

    case PAYMENT_FULL_PAID = "PAYMENT_FULL_PAID"
    case PAYMENT_WAIT = "PAYMENT_WAIT"
    case PAYMENT_CANCELED = "PAYMENT_CANCELED"
    case PAYMENT_OVERDUE = "PAYMENT_OVERDUE"
    case RECEIPT_SBP = "RECEIPT_SBP"
    case RECEIPT_CASH = "RECEIPT_CASH"
    case RECEIPT_CRYPTO = "RECEIPT_CRYPTO"
    case RECEIPT_CARD = "RECEIPT_CARD"
    case TARGET_DRAFT = "TARGET_DRAFT"
    case TARGET_IN_PROGRESS = "TARGET_IN_PROGRESS"
    case TARGET_DONE = "TARGET_DONE"
    case TARGET_DONE_EXPIRED = "TARGET_DONE_EXPIRED"
    case TARGET_CANCELLED = "TARGET_CANCELLED"
    case TARGET_FAILED = "TARGET_FAILED"
    case TARGET_EXPIRED = "TARGET_EXPIRED"

    var name: String {
        switch self {
        case .PAYMENT_FULL_PAID: return "Платеж полностью оплачен"
        case .PAYMENT_WAIT: return "Ожидается оплата"
        case .PAYMENT_CANCELED: return "Оплата отменена"
        case .PAYMENT_OVERDUE: return .empty
        case .unknown:return .empty
        case .RECEIPT_SBP: return .empty
        case .RECEIPT_CASH: return .empty
        case .RECEIPT_CRYPTO: return .empty
        case .RECEIPT_CARD: return .empty
        case .TARGET_DRAFT: return "Цель на рассмотрении"
        case .TARGET_IN_PROGRESS: return "Цель начата"
        case .TARGET_DONE: return "Цель завершена"
        case .TARGET_DONE_EXPIRED: return "Цель завершена с просрочкой"
        case .TARGET_CANCELLED: return "Цель отменена"
        case .TARGET_FAILED: return "Цель провалена"
        case .TARGET_EXPIRED: return "Цель просрочена"
        }
    }
}