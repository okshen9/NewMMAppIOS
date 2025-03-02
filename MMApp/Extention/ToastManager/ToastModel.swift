//
//  ToastModel.swift
//  MMApp
//
//  Created by artem on 02.03.2025.
//

import Foundation


struct ToastModel: Equatable {
    let message: String
    let icon: String?
    let duration: TimeInterval
    
    static func == (lhs: ToastModel, rhs: ToastModel) -> Bool {
        lhs.message == rhs.message && lhs.icon == rhs.icon
    }
}
