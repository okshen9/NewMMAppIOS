//
//  CreateUserTargetBodyModel.swift
//  MMApp
//
//  Created by artem on 16.02.2025.
//

import Foundation

struct CreateUserTargetBodyModel: JSONRepresentable {
    let title: String?
    let description: String?
    let userExternalId: Int?
    let deadLineDateTime: Date?
    let streamId: Int?
    let subTargets: [CreateSubTargetBodyModel]?
    let category: TargetCategory?
}

