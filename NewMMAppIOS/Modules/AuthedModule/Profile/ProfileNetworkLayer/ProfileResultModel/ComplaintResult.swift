//
//  ComplaintResult.swift
//  NewMMAppIOS
//
//  Created by artem on 26.05.25.
//

import Foundation

struct ComplaintResult: Codable {
    let id: Int
    let message: String?
    let fromUserExtId: Int?
    let toUserExtId: Int?
    let createdAt: String?
}
