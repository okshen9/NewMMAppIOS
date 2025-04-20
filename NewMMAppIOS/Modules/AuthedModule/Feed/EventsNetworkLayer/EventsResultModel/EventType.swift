//
//  EventType.swift
//  MMApp
//
//  Created by artem on 06.04.2025.
//

import SwiftUICore


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

    static var allTargetsType: [EventType] {
        return [ .TARGET_DRAFT, .TARGET_IN_PROGRESS, .TARGET_DONE, .TARGET_DONE_EXPIRED, .TARGET_CANCELLED, .TARGET_FAILED, .TARGET_EXPIRED]
    }

    static var allPaymentType: [EventType] {
        return [ .PAYMENT_FULL_PAID, .PAYMENT_WAIT, .PAYMENT_CANCELED, .PAYMENT_OVERDUE]
    }

    var name: String {
        switch self {
        case .PAYMENT_FULL_PAID: return "Полностью оплачено"
        case .PAYMENT_WAIT: return "Ожидается оплата"
        case .PAYMENT_CANCELED: return "Оплата отменена"
        case .PAYMENT_OVERDUE: return "Оплата просрочена"
        case .unknown:return "Не известно"
        case .RECEIPT_SBP: return "Оплата по SBP"
        case .RECEIPT_CASH: return "Оплата наличными"
        case .RECEIPT_CRYPTO: return "Оплата криптой"
        case .RECEIPT_CARD: return "Оплата картой"
        case .TARGET_DRAFT: return "Цель на рассмотрении"
        case .TARGET_IN_PROGRESS: return "Цель открыта"
        case .TARGET_DONE: return "Цель завершена"
        case .TARGET_DONE_EXPIRED: return "Цель завершена с просрочкой"
        case .TARGET_CANCELLED: return "Цель отменена"
        case .TARGET_FAILED: return "Цель провалена"
        case .TARGET_EXPIRED: return "Цель просрочена"
        }
    }

    var feedActionName: String {
        switch self {
        case .PAYMENT_FULL_PAID: return "Закрыл все оплаты"
        case .PAYMENT_WAIT: return "Ожидает оплаты"
        case .PAYMENT_CANCELED: return "Отменил оплату"
        case .PAYMENT_OVERDUE: return "Оплатил просрочена"
        case .unknown:return "Не известно"
        case .RECEIPT_SBP: return "Оплатил по SBP"
        case .RECEIPT_CASH: return "Оплатил наличными"
        case .RECEIPT_CRYPTO: return "Оплатил криптой"
        case .RECEIPT_CARD: return "Оплатил по карте"
        case .TARGET_DRAFT: return "Отправил цель на рассмотрение"
        case .TARGET_IN_PROGRESS: return "Врывается в цель 🚀"
        case .TARGET_DONE: return "Закрыл цель 🎯"
        case .TARGET_DONE_EXPIRED: return "Закрыл цель с просрочкой 🎯"
        case .TARGET_CANCELLED: return "Отменил цель"
        case .TARGET_FAILED: return "Провалил цель"
        case .TARGET_EXPIRED: return "Просрочил цель"
        }
    }


}

//done:
//Image("checkmark")
//    .foregroundStyle(.green)
//
//
//doneExpaired:
//Image("checkmark")
//    .foregroundStyle(.yelow)
//
//failed:
//Image("x-mark")
//    .foregroundStyle(.red)
//
//inProgress:
//Image("arrow.clockwise")
//    .foregroundStyle(.gray)
