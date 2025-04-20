//
//  EventRowView.swift
//  MMApp
//
//  Created by artem on 26.02.2025.
//

import SwiftUI

struct EventRowView: View {
    let event: CalendatItem

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                    .foregroundColor(.headerText)
                Text(event.type.name)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            ImageSheduler(event: event)
                .frame(width: 16, height: 16)
//            Circle()
//                .fill(Color(event.type.color))
//                .frame(width: 16, height: 16)
        }
        .padding(.vertical, 8)
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
    EventRowView(event: item)
}
