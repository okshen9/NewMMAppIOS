//
//  ImageSheduler.swift
//  NewMMAppIOS
//
//  Created by artem on 13.04.2025.
//

import SwiftUI

struct ImageSheduler: View {
    let event: CalendatItem
    var body: some View {
        switch event.type {
        case .target:
            getTargetImage()
        case .payment:
            getPaymentImage()
        case .anyEvent(_):
            Constants.checkmarkImageEmpty
                .renderingMode(.template)
                .foregroundStyle(.gray)
        }
    }

    @ViewBuilder
    func getTargetImage() -> some View {
        if let status = event.target?.targetStatus {
            switch status {
            case .inProgress:
                Constants.checkmarkImage
                    .renderingMode(.template)
                    .foregroundStyle(.green)
            default:
                Constants.checkmarkImage
                    .renderingMode(.template)
                    .foregroundStyle(.green)
            }
        }
    }

    @ViewBuilder
    func getPaymentImage() -> some View {
        if let status = event.payment?.paymentRequestStatus {
            switch status {
            case .wait:
                Constants.moneyImage
                    .renderingMode(.template)
                    .foregroundStyle(.red)
            default:
                Constants.moneyImage
                    .renderingMode(.template)
                    .foregroundStyle(.red)
            }
        } else {
            Image(systemName: "")
        }
    }
}

extension ImageSheduler {
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

#Preview {
    let item = CalendatItem(
        payment: .init(
            id: 12,
            externalId: 11,
            amount: 100.0,
            dueDate: Date().toApiString,
            comment: "надо оплатить",
            paymentRequestStatus: PaymentRequestStatus.wait,
            userProfilePreview: UserProfileResultDto.getTestUser()
        ),
        target: .getBaseTarget(),
        user: .getTestUser(),
        title: "Что-то",
        type: .target,
        date: Date()
    )
    ImageSheduler(event: item)
}
