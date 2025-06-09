//
//  IconActionFeedView.swift
//  NewMMAppIOS
//
//  Created by artem on 12.04.2025.
//

import SwiftUI

struct IconActionFeedView: View {
    let type: EventType
    var body: some View {
        icon()
            .frame(width: 24, height: 24)
    }

    @ViewBuilder
    func icon() -> some View {
        switch self.type {
        case .PAYMENT_FULL_PAID:
            HStack(spacing: -8) {
                Constants.moneyImage
                    .renderingMode(.template)
                    .foregroundStyle(.green)
                Constants.moneyImage
                    .renderingMode(.template)
                    .foregroundStyle(.green)
                Constants.moneyImage
                    .renderingMode(.template)
                    .foregroundStyle(.green)
            }

            /// done:
        case .TARGET_DONE:
            Constants.checkmarkImage
                .renderingMode(.template)
                .foregroundStyle(.green)
        case .TARGET_DRAFT:
            Constants.refreshImage
                .renderingMode(.template)
                .foregroundStyle(.gray)
            /// inProgress:
        case .TARGET_IN_PROGRESS:
            Constants.checkmarkImageEmpty
                .renderingMode(.template)
                .foregroundStyle(.gray)
            /// failed:
        case .TARGET_FAILED:
            Constants.xmarkImage
                .renderingMode(.template)
                .foregroundStyle(.red)
        case .TARGET_EXPIRED:
            Constants.expaiderImage
                .renderingMode(.template)
                .foregroundStyle(.red)
        case .PAYMENT_OVERDUE:
            Constants.moneyImage
                .renderingMode(.template)
                .foregroundStyle(.red)
            /// doneExpaired:
        case .TARGET_DONE_EXPIRED:
            Constants.expaiderImage
                .renderingMode(.template)
                .foregroundStyle(.yellow)
        case .PAYMENT_WAIT:
            Constants.moneyImage
                .renderingMode(.template)
                .foregroundStyle(.yellow)
        case .unknown,
                .RECEIPT_SBP,
                .RECEIPT_CASH,
                .RECEIPT_CRYPTO,
                .RECEIPT_CARD:
            Constants.moneyImage
                .renderingMode(.template)
                .foregroundStyle(.green)
        case .TARGET_CANCELLED, .PAYMENT_CANCELED:
            Constants.moneyImage
                .renderingMode(.template)
                .foregroundStyle(.gray)
        }
    }
}

extension IconActionFeedView {
    enum Constants {
        static let xmarkImage = Image(systemName: "xmark.seal.fill")
        static let checkmarkImageEmpty = Image(systemName: "checkmark.seal")
        static let checkmarkImage = Image(systemName: "checkmark.seal.fill")
        static let expaiderImage = Image(systemName: "clock.badge.checkmark.fill")
        static let waitImage = Image(systemName: "airplane.departure")
        static let moneyImage = Image(systemName: "dollarsign.circle.fill")
        static let refreshImage = Image(systemName: "arrow.clockwise.circle.fill")
        static let dollarsignImage = Image(systemName: "dollarsign")

    }
}

private struct IaconWithName: View {
    let type: EventType
    var body: some View {

        HStack{
            Text("\(type.name)")
            IconActionFeedView(type: type)
        }
    }

}


