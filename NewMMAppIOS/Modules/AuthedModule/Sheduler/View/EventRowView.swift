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
    
    var isSubTarget: Bool {
        if case let .target(target) = event.type,
           let subTargets = target.subTargets,
           subTargets.count == 1 && event.title.hasPrefix("Подцель:") {
            return true
        }
        return false
    }

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
                        HStack(spacing: 4) {
                            if isSubTarget {
                                AppIcons.General.arrowTurnDownRight
                                    .font(MMFonts.subCaption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Text(event.title)
                                .font(MMFonts.subTitle)
                                .foregroundColor(.primary)
                                .lineLimit(isExpanded ? nil : 3)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
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
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Spacer()
                    
                    // Статус события
                    if case .target(_) = event.type, let target = event.target,
                       (target.description != nil && !target.description.isEmptyOrNil) ||
                       (target.subTargets != nil && !target.subTargets!.isEmpty) {
                        (isExpanded ? AppIcons.General.collapse : AppIcons.General.expand)
                            .font(MMFonts.caption)
                            .foregroundColor(.secondary)
                            .padding()
                    }
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
                                    .font(MMFonts.caption)
                                    .foregroundColor(.secondary)
                                Text(description)
                                    .font(MMFonts.caption)
                                    .foregroundColor(.primary)
                                    .lineLimit(nil)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(.top, 4)
                        }
                        
                        // Подцели, если они есть
                        if let subTargets = event.target?.subTargets, !subTargets.isEmpty {
                            Divider()
                                .padding(.vertical, 4)
                            
                            HStack {
                                Text("Подзадачи")
                                    .font(MMFonts.caption)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text("\(subTargets.filter({ $0.targetStatus == .done }).count)/\(subTargets.count)")
                                    .font(MMFonts.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(
                                        Capsule()
                                            .fill(Color.secondary.opacity(0.1))
                                    )
                            }
                            ForEach(subTargets) { subTarget in
                                HStack(alignment: .top, spacing: 12) {
                                    // Иконка подцели
                                    AppIcons.SubTarget.coloredIcon(for: subTarget.targetStatus ?? .notDone, backColor: .white)
                                        .frameRect(18)
                                    
                                    // Название подцели и описание
                                    VStack(alignment: .leading, spacing: 2) {
                                        HStack(alignment: .top) {
                                            Text(subTarget.title ?? "Подзадача")
                                                .font(MMFonts.caption)
                                                .foregroundColor(.primary)
                                                .fixedSize(horizontal: false, vertical: true)
                                            
                                            Spacer(minLength: 4)
                                            
                                            // Статус подцели - компактное отображение
                                            if let status = subTarget.targetStatus {
                                                HStack(spacing: 4) {
                                                    Circle()
                                                        .fill(subStatusColor(for: status))
                                                        .frame(width: 6, height: 6)
                                                    Text(subStatusText(for: status))
                                                        .font(MMFonts.subCaption)
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
                                                .font(MMFonts.subCaption)
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
                .font(MMFonts.caption)
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
            AppIcons.Payment.baseIcon(for: nil)
                .font(MMFonts.subCaption)
            Text("\(Int(amount)) ₽")
                .font(MMFonts.caption)
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
                .font(MMFonts.subCaption)
            Text("\(done)/\(total)")
                .font(MMFonts.caption)
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

            switch event.type {
            case .payment(let payment):
                let status = payment.paymentRequestStatus ?? .wait
                Circle()
                    .fill(AppIcons.Payment.color(for: status).opacity(0.15))
                    .frameRect(36)
                AppIcons.Payment.coloredIcon(for: status)
            case .target(let target):
                StatusTargetIndicatorView(target)
            case .subTarget(let subTarget):
                AppIcons.SubTarget.coloredIcon(for: subTarget.targetStatus ?? .notDone, backColor: Color(UIColor.secondarySystemBackground))
                    .frameRect(24)
            case .anyEvent(_):
                Circle()
                    .fill(event.type.color.opacity(0.15))
                    .frameRect(24)
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(event.type.color)
            }
//            if isSubTarget {
//                ImageSheduler(event: event)
//            } else {
//                ImageSheduler(event: event)
//                    .font(MMFonts.body)
//            }
            
        }
    }
    
    // MARK: - Helper Methods
    
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

