//
//  PayRequestView.swift
//  MMApp
//
//  Created by artem on 23.02.2025.
//

import SwiftUI

struct PayRequestView: View {
    @StateObject private var viewModel = PayRequestViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if let payRequest = viewModel.payRequest, !viewModel.isLoading {
                    List(payRequest, id: \.id) { payment in
                        PaymentRowView(payment: payment)
                    }
                    .listStyle(.plain)
                    .navigationTitle("Платежи")
                } else {
                    shimerState()
                }
            }
            .onAppear {
                viewModel.onApper()
            }
            .navigationTitle("Платежи")
        }
    }
    
    // MARK: - ViewBuilder
    @ViewBuilder
    func shimerState() -> some View {
        VStack(spacing: 20) {
            ShimmeringRectangle()
                .frame(width: 88, height: 88)
                .cornerRadius(44)
            
            ShimmeringRectangle()
                .frame(height: 20)
                .cornerRadius(8)
            
            ShimmeringRectangle()
                .frame(height: 20)
                .cornerRadius(8)
                .padding(.horizontal, 40)
            
            ShimmeringRectangle()
                .frame(height: 40)
                .cornerRadius(8)
                .padding(.top, 20)
            Spacer()
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    PayRequestView()
}

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
