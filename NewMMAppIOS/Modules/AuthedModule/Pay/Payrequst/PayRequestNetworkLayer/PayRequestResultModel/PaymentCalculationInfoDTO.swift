//
//  PaymentCalculationInfoDTO.swift
//  NewMMAppIOS
//
//  Created by artem on 12.04.2025.
//

import Foundation

struct PaymentCalculationInfoDto: Codable, Hashable {
    let totalPaymentsQuantity: Int?
    let donePaymentsQuantity: Int?
    let notDonePaymentsQuantity: Int?
    let donePaymentsPercentage: Double?
    let expiredPaymentsPercentage: Double?
}
