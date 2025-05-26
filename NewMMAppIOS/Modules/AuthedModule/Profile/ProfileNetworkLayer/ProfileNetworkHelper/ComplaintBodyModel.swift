//
//  ComplaintBodyModel.swift
//  NewMMAppIOS
//
//  Created by artem on 24.05.2025.
//

import Foundation

struct ComplaintBodyModel: JSONRepresentable {
    let message: String
    let toUserExtId: Int
} 