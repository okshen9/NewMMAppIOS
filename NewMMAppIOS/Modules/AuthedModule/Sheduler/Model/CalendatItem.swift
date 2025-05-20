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

    var payment: PaymentRequestResponseDto? {
        if case let .payment(payment) = type {
            return payment
        } else { return nil }
    }
    var target: UserTargetDtoModel? {
        if case let .target(target) = type {
            return target
        } else { return nil }
    }

    let user: UserProfileResultDto
    let title: String
    let type: CalendatItemType
    let date: Date
    let category: TargetCategory?
    
    enum CalendatItemType: Equatable {
        case payment(PaymentRequestResponseDto)
        case target(UserTargetDtoModel)
        case subTarget(UserSubTargetDtoModel)
        case anyEvent(String?)
        
        var name: String {
            switch self {
            case .payment:
                return "Оплата"
            case .target:
                return "Закрытие цели"
            case .subTarget:
                return "Закрытие подцели"
            case .anyEvent(let title):
                return title.orEmpty

            }
        }
        
        var uiColor: UIColor {
            switch self {
            case .payment(let payment):
                return UIColor(AppIcons.Payment.color(for: payment.paymentRequestStatus ?? .unknown))
            case .target(let target):
                return UIColor(AppIcons.Target.color(for: target.targetStatus ?? .unknown))
            case .subTarget(let subTarget):
                return UIColor(AppIcons.SubTarget.color(for: subTarget.targetStatus ?? .unknown))
            case .anyEvent:
                return UIColor.systemIndigo
            }
        }
        
        var color: Color {
            switch self {
            case .payment(let payment):
                return AppIcons.Payment.color(for: payment.paymentRequestStatus ?? .unknown)
            case .target(let target):
                return AppIcons.Target.color(for: target.targetStatus ?? .unknown)
            case .subTarget(let subTarget):
                return AppIcons.SubTarget.color(for: subTarget.targetStatus ?? .unknown)
            case .anyEvent:
                return Color.indigo
            }
        }
        
        func image(backColor: Color) -> some View {
            switch self {
            case .payment(let payment):
                return AppIcons.Payment.coloredIcon(for: payment.paymentRequestStatus ?? .unknown)
                    .eraseToAnyView()
            case .target(let target):
                return AppIcons.Target.coloredIcon(for: target.targetStatus ?? .unknown)
                    .eraseToAnyView()
            case .subTarget(let subTarget):
                return AppIcons.SubTarget.coloredIcon(for: subTarget.targetStatus ?? .unknown, backColor: .white)
                    .frameRect(16)
                    .eraseToAnyView()
            case .anyEvent:
                return Image(systemName: "lightbulb.min.fill")
                    .eraseToAnyView()
                
            }
        }
    }
}
