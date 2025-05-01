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
        VStack(alignment: .leading, spacing: 8) {
            // Сумма и статус
            HStack {
                Text("Сумма: \(payment.amount ?? 0, specifier: "%.2f") ₽")
                    .font(.headline)
                    .foregroundColor(.headerText)
                Spacer()
                Text(payment.paymentRequestStatus?.description ?? "Нет информации")
                    .font(.subheadline)
                    .foregroundColor(statusColor(for: payment.paymentRequestStatus))
            }

            // Дата
            if let dueDate = payment.dueDate?.dateFromStringISO8601 {
                Text("Срок оплаты: \(dueDate.toDisplayString)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            // Комментарий
            if let comment = payment.comment, !comment.isEmpty {
                Text("Комментарий: \(comment)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            // Профиль пользователя
            if let userProfile = payment.userProfilePreview {
                Text("Пользователь: \(userProfile.fullName ?? "Неизвестно")")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
    }

    // Цвет текста в зависимости от статуса
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
	PaymentRowView(payment: PaymentRequestResponseDto())
}
