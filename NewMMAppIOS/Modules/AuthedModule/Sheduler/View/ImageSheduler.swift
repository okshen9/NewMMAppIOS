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
    
    var isSubTarget: Bool {
        if case let .target(target) = event.type,
           let subTargets = target.subTargets,
           subTargets.count == 1 && event.title.hasPrefix("Подцель:") {
            return true
        }
        return false
    }
    
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
        // Используем иконки из централизованного AppIcons
        if isSubTarget {
            // Специальная иконка для подцелей
            Image(systemName: "checkmark.circle")
                .renderingMode(.template)
                .foregroundStyle(Color.blue)
                .font(font)
                .symbolRenderingMode(.hierarchical)
        } else if let target = event.target, let status = target.targetStatus {
            AppIcons.Target.icon(for: status)
                .renderingMode(.template)
                .foregroundStyle(AppIcons.Target.color(for: status))
                .font(font)
                .symbolRenderingMode(.hierarchical)
        } else {
            AppIcons.Target.defaultIcon
                .renderingMode(.template)
                .foregroundStyle(.green)
                .font(font)
                .symbolRenderingMode(.hierarchical)
        }
    }

    @ViewBuilder
    func getPaymentImage() -> some View {
        // Используем иконки из централизованного AppIcons
        if let status = event.payment?.paymentRequestStatus {
            AppIcons.Payment.icon(for: status)
                .renderingMode(.template)
                .foregroundStyle(AppIcons.Payment.color(for: status))
                .font(font)
                .symbolRenderingMode(.hierarchical)
        } else {
            AppIcons.Payment.defaultIcon
                .renderingMode(.template)
                .foregroundStyle(Color.mainRed)
                .font(font)
                .symbolRenderingMode(.hierarchical)
        }
    }
    
    @ViewBuilder
    func getDefaultEventImage() -> some View {
        // Используем комбинированную иконку из AppIcons
        AppIcons.combined
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
        static let targetDoneImage = Image(systemName: "star.fill")
        static let targetExpiredImage = Image(systemName: "star.fill")
        

        // Иконки платежей
        static let paymentDefaultImage = Image(systemName: "creditcard.fill")
        static let paymentWaitingImage = Image(systemName: "creditcard.fill")
        static let paymentCompletedImage = Image(systemName: "creditcard.fill")
        static let paymentCancelledImage = Image(systemName: "creditcard.fill")
        
        // Остальные иконки
        static let defaultEventImage = Image(systemName: "calendar.badge.exclamationmark")
        
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
                Text("Цели").font(MMFonts.caption)
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.15))
                        .frame(width: 40, height: 40)
                    ImageSheduler(
                        event: CalendatItem(
                            user: .getTestUser(),
                            title: "Цель в процессе",
							type: .target(UserTargetDtoModel(id: 0, targetStatus: .inProgress)),
                            date: Date(),
                            category: .family
                        ),
                        font: .system(size: 18)
                    )
                }
            }
            
            // Платежи
            VStack {
                Text("Платежи").font(MMFonts.caption)
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.15))
                        .frame(width: 40, height: 40)
                    ImageSheduler(
                        event: CalendatItem(
                            user: .getTestUser(),
                            title: "Платеж ожидает",
                            type: .payment(PaymentRequestResponseDto(paymentRequestStatus: .wait)),
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
