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

    init(message: String, icon: String? = nil, duration: TimeInterval = 2) {
        self.message = message
        self.icon = icon
        self.duration = duration
    }

    static var baseError: ToastModel {
        .init(message: "Что-то полшло не так", icon: "xmark.app", duration: 2)
    }

    static func == (lhs: ToastModel, rhs: ToastModel) -> Bool {
        lhs.message == rhs.message && lhs.icon == rhs.icon
    }
}
