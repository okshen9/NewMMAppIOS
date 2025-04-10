//
//  PayRequestBodyModel.swift
//  MMApp
//
//  Created by artem on 23.02.2025.
//

import Foundation

struct PayRequestBodyModel: JSONRepresentable {
    let externalId: Int?
    let text: String?
}
