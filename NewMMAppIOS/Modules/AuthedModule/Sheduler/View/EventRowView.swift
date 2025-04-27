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
    @State private var isExpanded = false

    var body: some View {
        let subTargets = event.target?.subTargets
        let description = event.target?.description
        
        VStack(alignment: .leading, spacing: 0) {
            // Основная информация о событии
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(alignment: .top, spacing: 8) {
                    // Иконка события
                    eventIconView
                        .padding(.top, 2)
                    
                    // Данные события
                    VStack(alignment: .leading, spacing: 4) {
                        Text(event.title)
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.primary)
                            .lineLimit(isExpanded ? nil : 3)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        // Компактная информация о событии
                        HStack {
//                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 4) {
                                    if let category = event.category {
                                        categoryLabel(category)
                                    }
                                    
                                    if let amount = event.payment?.amount,
                                        case .payment(_) = event.type
                                    {
                                        paymentLabel(amount)
                                    }
                                    
                                    if case .target(_) = event.type, let subTargets = event.target?.subTargets, !subTargets.isEmpty {
                                        subtasksLabel(subTargets)
                                    }
                                }
                                .padding(.vertical, 2)
//                            }
//                            .frame(maxWidth: .infinity, alignment: .leading)
                            .mask(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.black, Color.black, Color.black.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            
                            if case .target(_) = event.type, let target = event.target, 
                               (target.description != nil && !target.description.isEmptyOrNil) ||
                               (target.subTargets != nil && !target.subTargets!.isEmpty) {
                                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.leading, 4)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Spacer()
                    
                    // Статус события
                    dateStatusView(event.date)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.vertical, 12)
            
            // Дополнительная информация при развороте
            if isExpanded &&
                ((!subTargets.isEmptyOrNil) ||
               (!description.isEmptyOrNil))
            {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        // Описание события
                        if let description = event.target?.description, !description.isEmptyOrNil {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Описание")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(description)
                                    .font(.caption)
                                    .foregroundColor(.primary)
                                    .lineLimit(nil)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(.leading, 44)
                            .padding(.top, 4)
                        }
                        
                        // Подцели, если они есть
                        if let subTargets = event.target?.subTargets, !subTargets.isEmpty {
                            Divider()
                                .padding(.leading, 44)
                                .padding(.vertical, 4)
                            
                            HStack {
                                Text("Подзадачи")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text("\(subTargets.filter({ $0.targetStatus == .done }).count)/\(subTargets.count)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(
                                        Capsule()
                                            .fill(Color.secondary.opacity(0.1))
                                    )
                            }
                            .padding(.leading, 44)
                            .padding(.trailing, 16)
                            
                            ForEach(subTargets, id: \.id) { subTarget in
                                HStack(alignment: .top, spacing: 12) {
                                    // Иконка подцели
                                    Circle()
                                        .fill(subTarget.targetStatus == .done ? Color.green : Color.secondary.opacity(0.3))
                                        .frame(width: 18, height: 18)
                                        .overlay(
                                            Image(systemName: subTarget.targetStatus == .done ? "checkmark" : "circle")
                                                .font(.system(size: 10))
                                                .foregroundColor(subTarget.targetStatus == .done ? .white : .secondary)
                                        )
                                        .padding(.leading, 44)
                                        .padding(.top, 2)
                                    
                                    // Название подцели и описание
                                    VStack(alignment: .leading, spacing: 2) {
                                        HStack(alignment: .top) {
                                            Text(subTarget.title ?? "Подзадача")
                                                .font(.caption)
                                                .foregroundColor(.primary)
                                                .lineLimit(2)
                                                .fixedSize(horizontal: false, vertical: true)
                                            
                                            Spacer(minLength: 4)
                                            
                                            // Статус подцели - компактное отображение
                                            if let status = subTarget.targetStatus {
                                                HStack(spacing: 4) {
                                                    Circle()
                                                        .fill(subStatusColor(for: status))
                                                        .frame(width: 6, height: 6)
                                                    Text(subStatusText(for: status))
                                                        .font(.caption2)
                                                        .foregroundColor(subStatusColor(for: status))
                                                }
                                                .padding(.vertical, 2)
                                                .padding(.horizontal, 4)
                                                .background(
                                                    Capsule()
                                                        .fill(subStatusColor(for: status).opacity(0.1))
                                                )
                                            }
                                        }
                                        
                                        if let desc = subTarget.description, !desc.isEmpty {
                                            Text(desc)
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                                .lineLimit(3)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
                .padding(.bottom, 8)
            }
        }
    }
    
    // MARK: - Компоненты интерфейса
    
    @ViewBuilder
    private func categoryLabel(_ category: TargetCategory) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(category.color)
                .frame(width: 8, height: 8)
            Text(category.rawValue)
                .font(.caption)
                .foregroundColor(category.color)
                .lineLimit(1)
        }
        .padding(.vertical, 3)
        .padding(.horizontal, 6)
        .background(
            Capsule()
                .fill(category.color.opacity(0.1))
        )
    }
    
    @ViewBuilder
    private func paymentLabel(_ amount: Double) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "creditcard.fill")
                .font(.system(size: 8))
            Text("\(Int(amount)) ₽")
                .font(.caption)
        }
        .foregroundColor(.mainRed)
        .padding(.vertical, 3)
        .padding(.horizontal, 6)
        .background(
            Capsule()
                .fill(Color.mainRed.opacity(0.1))
        )
    }
    
    @ViewBuilder
    private func subtasksLabel(_ subTargets: [UserSubTargetDtoModel]) -> some View {
        let done = subTargets.filter({ $0.targetStatus == .done }).count
        let total = subTargets.count
        
        HStack(spacing: 4) {
            Image(systemName: "checklist")
                .font(.system(size: 8))
            Text("\(done)/\(total)")
                .font(.caption)
        }
        .foregroundColor(.blue)
        .padding(.vertical, 3)
        .padding(.horizontal, 6)
        .background(
            Capsule()
                .fill(Color.blue.opacity(0.1))
        )
    }
    
    // MARK: - Event Icon
    private var eventIconView: some View {
        ZStack {
            Circle()
                .fill(eventColor.opacity(0.15))
                .frame(width: 36, height: 36)
            
            ImageSheduler(event: event)
                .font(.system(size: 16))
        }
    }
    
    // MARK: - Date Status
    private func dateStatusView(_ date: Date) -> some View {
        VStack(spacing: 2) {
            Text(relativeDateString(date))
                .font(.caption)
                .foregroundColor(isOverdue(date) ? .red : .secondary)
                .lineLimit(1)
            
            Text(dateString(date))
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .frame(minWidth: 60)
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
    
    private func statusText(for status: TargetStatus) -> String {
        switch status {
        case .inProgress:
            return "В процессе"
        case .done:
            return "Выполнено"
        case .expired:
            return "Просрочено"
        default:
            return "Неизвестно"
        }
    }
    
    private func statusColor(for status: TargetStatus) -> Color {
        switch status {
        case .inProgress:
            return .blue
        case .done:
            return .green
        case .expired:
            return .orange
        default:
            return .gray
        }
    }
    
    private func subStatusText(for status: TargetSubStatus) -> String {
        switch status {
        case .done:
            return "Выполнено"
        case .notDone:
            return "В процессе"
        default:
            return "Неизвестно"
        }
    }
    
    private func subStatusColor(for status: TargetSubStatus) -> Color {
        switch status {
        case .done:
            return .green
        case .notDone:
            return .blue
        default:
            return .gray
        }
    }
    
    private func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMM"
        return formatter.string(from: date)
    }
    
    private func relativeDateString(_ date: Date) -> String {
        return date.relativeTimeString()
    }
    
    private func isOverdue(_ date: Date) -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return date < today
    }
}

extension String {
    var isEmptyOrNil: Bool {
        return self.isEmpty
    }
}

extension Optional where Wrapped == String {
    var isEmptyOrNil: Bool {
        return self == nil || self!.isEmpty
    }
}

#Preview {
    let item = CalendatItem(
        user: .getTestUser(),
        title: "Оплата курса наставничества",
        type: .payment(.init(
            id: 12,
            externalId: 11,
            amount: 100.0,
            dueDate: Date().toApiString,
            comment: "надо оплатить",
            paymentRequestStatus: PaymentRequestStatus.wait,
            userProfilePreview: UserProfileResultDto.getTestUser()
        )),
        date: Date(),
        category: nil
    )
    ScrollView {
        VStack {
            EventRowView(event: item)
                .padding()
                .background(Color.white)
                .cornerRadius(8)
            
            EventRowView(event: CalendatItem(
                user: .getTestUser(),
                title: "3.Собрал команду в корпоративной практике - подписал трудовые договоры с новыми сотрудниками (ведущий юрист, юрист, руководитель отдела) до 12.05.2025",
                type: .target(.getBaseTarget(withOutSub: true, withOutDesc: true)),
                date: Date().addingTimeInterval(86400), // Tomorrow
                category: .money
            ))
            .padding()
            .background(Color.white)
            .cornerRadius(8)
            
            EventRowView(event: CalendatItem(
                user: .getTestUser(),
                title: "Закрыть цель: Пробежать 5 км",
                type: .target(.getBaseTarget()),
                date: Date().addingTimeInterval(172800 * 10), // Day after tomorrow
                category: .health
            ))
            .padding()
            .background(Color.white)
            .cornerRadius(8)
        }
        .padding()
    }
}
