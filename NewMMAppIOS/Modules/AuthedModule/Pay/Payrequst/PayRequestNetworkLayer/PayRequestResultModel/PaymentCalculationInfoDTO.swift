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
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        totalPaymentsQuantity = try container.decodeIfPresent(Int.self, forKey: .totalPaymentsQuantity)
        donePaymentsQuantity = try container.decodeIfPresent(Int.self, forKey: .donePaymentsQuantity)
        notDonePaymentsQuantity = try container.decodeIfPresent(Int.self, forKey: .notDonePaymentsQuantity)
        donePaymentsPercentage = container.getDoubleValue(forKey: .donePaymentsPercentage)
        expiredPaymentsPercentage = container.getDoubleValue(forKey: .expiredPaymentsPercentage)
    }
}
