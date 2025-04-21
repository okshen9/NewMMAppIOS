//
//  ImageSheduler.swift
//  NewMMAppIOS
//
//  Created by artem on 13.04.2025.
//

import SwiftUI

struct ImageSheduler: View {
    let event: CalendatItem
    var font: Font = .system(size: 16)
    
    var body: some View {
        switch event.type {
        case .target:
            getTargetImage()
        case .payment:
            getPaymentImage()
        case .anyEvent:
            getDefaultEventImage()
        }
    }

    @ViewBuilder
    func getTargetImage() -> some View {
        if let status = event.target?.targetStatus {
            switch status {
            case .inProgress:
                Constants.targetInProgressImage
                    .renderingMode(.template)
                    .foregroundStyle(.green)
                    .font(font)
                    .symbolRenderingMode(.hierarchical)
            case .done:
                Constants.targetDoneImage
                    .renderingMode(.template)
                    .foregroundStyle(.green)
                    .font(font)
                    .symbolRenderingMode(.hierarchical)
            case .expired:
                Constants.targetExpiredImage
                    .renderingMode(.template)
                    .foregroundStyle(.orange)
                    .font(font)
                    .symbolRenderingMode(.hierarchical)
            default:
                Constants.targetDefaultImage
                    .renderingMode(.template)
                    .foregroundStyle(.green)
                    .font(font)
                    .symbolRenderingMode(.hierarchical)
            }
        } else {
            Constants.targetDefaultImage
                .renderingMode(.template)
                .foregroundStyle(.green)
                .font(font)
                .symbolRenderingMode(.hierarchical)
        }
    }

    @ViewBuilder
    func getPaymentImage() -> some View {
        if let status = event.payment?.paymentRequestStatus {
            switch status {
            case .wait:
                Constants.paymentWaitingImage
                    .renderingMode(.template)
                    .foregroundStyle(.red)
                    .font(font)
                    .symbolRenderingMode(.hierarchical)
            case .canceled:
                Constants.paymentCancelledImage
                    .renderingMode(.template)
                    .foregroundStyle(.red)
                    .font(font)
                    .symbolRenderingMode(.hierarchical)
            default:
                Constants.paymentDefaultImage
                    .renderingMode(.template)
                    .foregroundStyle(.red)
                    .font(font)
                    .symbolRenderingMode(.hierarchical)
            }
        } else {
            Constants.paymentDefaultImage
                .renderingMode(.template)
                .foregroundStyle(.red)
                .font(font)
                .symbolRenderingMode(.hierarchical)
        }
    }
    
    @ViewBuilder
    func getDefaultEventImage() -> some View {
        Constants.defaultEventImage
            .renderingMode(.template)
            .foregroundStyle(.blue)
            .font(font)
            .symbolRenderingMode(.hierarchical)
    }
}

extension ImageSheduler {
    enum Constants {
        // Целевые иконки
        static let targetDefaultImage = Image(systemName: "star.fill")
        static let targetInProgressImage = Image(systemName: "star.fill")
        static let targetDoneImage = Image(systemName: "checkmark.circle.fill")
        static let targetExpiredImage = Image(systemName: "exclamationmark.circle.fill")
        

        // Иконки платежей
        static let paymentDefaultImage = Image(systemName: "creditcard.fill")
        static let paymentWaitingImage = Image(systemName: "creditcard.fill")
        static let paymentCompletedImage = Image(systemName: "checkmark.circle.fill")
        static let paymentCancelledImage = Image(systemName: "xmark.circle.fill")
        
        // Остальные иконки
        static let defaultEventImage = Image(systemName: "calendar.badge")
        
        // Устаревшие иконки (оставлены для обратной совместимости)
        static let xmarkImage = Image(systemName: "xmark.circle.fill")
        static let checkmarkImageEmpty = Image(systemName: "circle")
        static let checkmarkImage = Image(systemName: "checkmark.circle.fill")
        static let expaiderImage = Image(systemName: "clock.fill")
        static let waitImage = Image(systemName: "hourglass")
        static let moneyImage = Image(systemName: "dollarsign.circle.fill")
        static let refreshImage = Image(systemName: "arrow.clockwise.circle.fill")
        static let dollarsignImage = Image(systemName: "dollarsign")
    }
}

#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 30) {
            // Цели
            VStack {
                Text("Цели").font(.caption)
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.15))
                        .frame(width: 40, height: 40)
                    ImageSheduler(
                        event: CalendatItem(
                            payment: nil,
                            target: UserTargetDtoModel(targetStatus: .inProgress),
                            user: .getTestUser(),
                            title: "Цель в процессе",
                            type: .target,
                            date: Date(),
                            category: .family
                        ),
                        font: .system(size: 18)
                    )
                }
            }
            
            // Платежи
            VStack {
                Text("Платежи").font(.caption)
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.15))
                        .frame(width: 40, height: 40)
                    ImageSheduler(
                        event: CalendatItem(
                            payment: PaymentRequestResponseDto(paymentRequestStatus: .wait),
                            target: nil,
                            user: .getTestUser(),
                            title: "Платеж ожидает",
                            type: .payment,
                            date: Date(),
                            category: nil
                        ),
                        font: .system(size: 18)
                    )
                }
            }
        }
    }
    .padding()
}
