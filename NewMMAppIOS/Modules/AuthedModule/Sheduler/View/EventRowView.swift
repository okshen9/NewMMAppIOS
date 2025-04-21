//
//  EventRowView.swift
//  MMApp
//
//  Created by artem on 26.02.2025.
//

import SwiftUI

struct EventRowView: View {
    let event: CalendatItem
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: 12) {
            // Иконка события
            eventIconView
            
            // Данные события
            VStack(alignment: .leading, spacing: 6) {
                Text(event.title)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                HStack(spacing: 8) {
                    Text(event.type.name)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if let amount = event.payment?.amount, event.type == .payment {
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(Int(amount)) ₽")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(Color.mainRed)
                    }
                    
                    if let category = event.category {
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(category.rawValue)
                            .font(.caption)
                            .foregroundColor(category.color)
                    }
                }
            }
            
            Spacer()
            
            // Статус события
//            if let date = event.date {
                dateStatusView(event.date)
//            }
        }
        .padding(.vertical, 12)
    }
    
    // MARK: - Event Icon
    private var eventIconView: some View {
        ZStack {
            Circle()
                .fill(eventColor.opacity(0.15))
                .frame(width: 40, height: 40)
            
            ImageSheduler(event: event)
                .font(.system(size: 18))
        }
    }
    
    // MARK: - Date Status
    private func dateStatusView(_ date: Date) -> some View {
        VStack(spacing: 2) {
            Text(relativeDateString(date))
                .font(.caption)
                .foregroundColor(isOverdue(date) ? .red : .secondary)
            
            Text(dateString(date))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Helper Methods
    private var eventColor: Color {
        switch event.type {
        case .payment:
            return Color.mainRed
        case .target:
            return Color.green
        case .anyEvent:
            return Color.blue
        }
    }
    
    private func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMM"
        return formatter.string(from: date)
    }
    
    private func relativeDateString(_ date: Date) -> String {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        
        if Calendar.current.isDate(date, inSameDayAs: today) {
            return "Сегодня"
        } else if Calendar.current.isDate(date, inSameDayAs: tomorrow) {
            return "Завтра"
        } else if Calendar.current.isDate(date, inSameDayAs: yesterday) {
            return "Вчера"
        } else {
            return "\(daysDifference(from: today, to: date)) дн."
        }
    }
    
    private func isOverdue(_ date: Date) -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return date < today
    }
    
    private func daysDifference(from date1: Date, to date2: Date) -> Int {
        let days = Calendar.current.dateComponents([.day], from: date1, to: date2).day ?? 0
        if days < 0 {
            return days
        } else {
            return days + 1 // +1 because we count inclusively (tomorrow = 2 days)
        }
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
        title: "Оплата курса наставничества",
        type: .payment,
        date: Date(),
        category: nil
    )
    
    VStack {
        EventRowView(event: item)
            .padding()
            .background(Color.white)
            .cornerRadius(8)
        
        EventRowView(event: CalendatItem(
            payment: nil,
            target: .getBaseTarget(),
            user: .getTestUser(),
            title: "Закрыть цель: Прочитать книгу по SwiftUI",
            type: .target,
            date: Date().addingTimeInterval(86400), // Tomorrow
            category: .money
        ))
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        
        EventRowView(event: CalendatItem(
            payment: nil,
            target: .getBaseTarget(),
            user: .getTestUser(),
            title: "Закрыть цель: Пробежать 5 км",
            type: .target,
            date: Date().addingTimeInterval(172800), // Day after tomorrow
            category: .health
        ))
        .padding()
        .background(Color.white)
        .cornerRadius(8)
    }
    .padding()
}
