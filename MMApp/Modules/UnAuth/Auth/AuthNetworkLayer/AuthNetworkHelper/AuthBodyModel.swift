//
//  AuthBodyModel.swift
//  MMApp
//
//  Created by artem on 18.02.2025.
//

import Foundation

struct AuthBodyModel: JSONRepresentable {
    let externalId: Int?
    let text: String?
}
