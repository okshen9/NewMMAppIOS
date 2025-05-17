//
//  PaymentRowView.swift
//  NewMMAppIOS
//
//  Created by artem on 01.05.2025.
//
import SwiftUI

struct PaymentRowView: View {
    let payment: PaymentRequestResponseDto

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Сумма и статус
            HStack {
                Text("\(payment.amount ?? 0, specifier: "%.2f") ₽")
                    .font(MMFonts.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                paymentStatusBadge(payment.paymentRequestStatus)
            }
            
            // Информационный блок
            VStack(alignment: .leading, spacing: 8) {
                // Дата платежа
                if let dueDate = payment.dueDate?.dateFromStringISO8601 {
                    infoRow(icon: "calendar", text: "Срок оплаты: \(dueDate.toDisplayString)")
                }
                
                // Комментарий, если есть
                if let comment = payment.comment, !comment.isEmpty {
                    infoRow(icon: "text.bubble", text: comment)
                }
                
                // Информация о пользователе
                if let userProfile = payment.userProfilePreview {
                    infoRow(icon: "person", text: userProfile.fullName ?? "Неизвестно")
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
		)
	}
    
    // MARK: - Компоненты интерфейса
    
    // Отображение статуса платежа
    @ViewBuilder
    private func paymentStatusBadge(_ status: PaymentRequestStatus?) -> some View {
        Text(status?.description ?? "Нет информации")
            .font(MMFonts.subCaption)
            .foregroundColor(.white)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(
                Capsule()
                    .fill(statusColor(for: status))
            )
    }
    
    // Строка с информацией
    @ViewBuilder
    private func infoRow(icon: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(MMFonts.subCaption)
                .foregroundColor(.secondary)
                .frame(width: 16)
            
            Text(text)
                .font(MMFonts.caption)
				.foregroundColor(.headerText)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    // Цвет статуса платежа
    private func statusColor(for status: PaymentRequestStatus?) -> Color {
        guard let status = status else { return .gray }
        switch status {
        case .fullPaid:
            return .green
        case .wait:
            return .orange
        case .canceled:
            return .red
        case .overdue:
            return .mainRed
        case .unknown:
            return .gray
        }
    }
}

#Preview {
	PaymentRowView(payment: PaymentRequestResponseDto(paymentRequestStatus: .wait))
}
