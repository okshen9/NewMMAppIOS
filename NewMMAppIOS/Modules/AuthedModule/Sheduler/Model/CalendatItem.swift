//
//  CalendatItem.swift
//  MMApp
//
//  Created by artem on 19.03.2025.
//

import Foundation
import UIKit
import SwiftUICore

struct CalendatItem: Identifiable, Equatable {
    static func == (lhs: CalendatItem, rhs: CalendatItem) -> Bool {
        lhs.id == rhs.id
    }
    
    var id = UUID()

    let payment: PaymentRequestResponseDto?
    let target: UserTargetDtoModel?

    let user: UserProfileResultDto
    let title: String
    let type: CalendatItemType
    let date: Date
    
    enum CalendatItemType {
        case payment
        case target
        case anyEvent(String?)
        
        var name: String {
            switch self {
            case .payment:
                return "Оплата"
            case .target:
                return "Закрытие цели"
            case .anyEvent(let title):
                return title.orEmpty
            }
        }
        
        var color: UIColor {
            switch self {
            case .payment:
                return .systemBlue
            case .target:
                return .green
            case .anyEvent:
                return .systemIndigo
            }
        }
        
        var image: Image {
            switch self {
            case .payment:
                return Image(systemName: "creditcard")
            case .target:
                return Image(systemName: "star.fill")
            case .anyEvent:
                return Image(systemName: "lightbulb.min.fill")
                
            }
        }
    }
}
