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
        case .target(let target):
            getTargetImage()
        case .payment(let payment):
            getPaymentImage()
        case .subTarget(let subTarget):
            AppIcons.SubTarget.coloredIcon(for: .notDone, backColor: .white)
                .frameRect(16)
        case .anyEvent:
            getDefaultEventImage()
        }
    }

    @ViewBuilder
    func getTargetImage() -> some View {
        // Используем иконки из централизованного AppIcons
        if let target = event.target, let status = target.targetStatus {
            AppIcons.Target.baseIcon(for: status)
                .renderingMode(.template)
                .foregroundStyle(AppIcons.Target.color(for: status))
                .font(font)
                .symbolRenderingMode(.hierarchical)
        } else {
            AppIcons.Target.baseIcon(for: .unknown)
                .renderingMode(.template)
                .foregroundStyle(.green)
                .font(font)
                .symbolRenderingMode(.hierarchical)
        }
    }

    @ViewBuilder
    func getPaymentImage() -> some View {
        // Используем иконки из централизованного AppIcons
            AppIcons.Payment.baseIcon(for: event.payment?.paymentRequestStatus)
                .renderingMode(.template)
                .foregroundStyle(AppIcons.Payment.color(for: event.payment?.paymentRequestStatus))
                .font(font)
                .symbolRenderingMode(.hierarchical)
    }
    
    @ViewBuilder
    func getDefaultEventImage() -> some View {
        // Используем комбинированную иконку из AppIcons
		AppIcons.General.combined
            .renderingMode(.template)
            .foregroundStyle(.blue)
            .font(font)
            .symbolRenderingMode(.hierarchical)
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
