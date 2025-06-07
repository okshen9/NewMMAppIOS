//
//  GroupCard.swift
//  NewMMAppIOS
//
//  Created by artem on 07.06.25.
//

import SwiftUI

struct GroupCardCell: View {
    let group: GroupResultDTOModel
    
    private var groupType: GroupTypeResultDTOModel {
        group.usersGroupType ?? .unknown
    }
    
    private var status: GroupStatus {
        guard let dateTo = group.dateTo?.dateFromStringISO8601 else { return .unknown }
        return dateTo > Date() ? .active : .ended
    }
    
    var body: some View {
        NavigationLink(destination: GroupDetailView(group: group)) {
            VStack(alignment: .leading, spacing: 12) {
                // Заголовок и статус
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(group.title ?? "Без названия")
                            .font(MMFonts.title)
                            .foregroundColor(.headerText)
                            .lineLimit(2)
                        
                        Text(groupType.displayName)
                            .font(MMFonts.body)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    StatusBadge(status: status)
                }
                
                // Даты
                if !group.dateRange.isEmpty {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.gray)
                            .font(.caption)
                        
                        Text(group.dateRange)
                            .font(MMFonts.body)
                            .foregroundColor(.gray)
                    }
                }
                
                // Участники
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "person.2.fill")
                            .foregroundColor(.gray)
                            .font(.caption)
                        
                        Text("Менторы: \((group.userOwners?.count ?? 0))")
                            .font(MMFonts.body)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "person.3.fill")
                            .foregroundColor(.gray)
                            .font(.caption)
                        
                        Text("Участники: \((group.userMembers?.count ?? 0))")
                            .font(MMFonts.body)
                            .foregroundColor(.gray)
                    }
                }
                
                // Описание (если есть)
                if let description = group.description, !description.isEmpty {
                    Text(description)
                        .font(MMFonts.body)
                        .foregroundColor(.headerText)
                        .lineLimit(3)
                        .padding(.top, 4)
                }
                
                // Telegram чат (если есть)
                if let tgReference = group.tgChatReference, !tgReference.isEmpty {
                    HStack(spacing: 6) {
                        Image(.tg)
                            .resizable()
                            .frame(width: 16, height: 16)
                        
                        Text("Чат группы")
                            .font(MMFonts.subTitle)
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 4)
                    .onTapGesture {
                        openTelegramChat(tgReference: tgReference)
                    }
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func openTelegramChat(tgReference: String) {
        let telegramURL = URL(string: "tg://resolve?domain=\(tgReference)")!
        
        if UIApplication.shared.canOpenURL(telegramURL) {
            UIApplication.shared.open(telegramURL, options: [:], completionHandler: nil)
        } else {
            let webURL = URL(string: "https://t.me/\(tgReference)")!
            UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
        }
    }
}

struct StatusBadge: View {
    let status: GroupStatus
    
    var body: some View {
        if status != .unknown {
            Text(status.displayName)
                .font(MMFonts.subTitle)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(status.color)
                .cornerRadius(12)
        }
    }
    
    func test() -> Bool {
        if status == .unknown  {
            return true
        }
        return false
    }
}

enum GroupStatus {
    case active
    case ended
    case unknown
    
    var displayName: String {
        switch self {
        case .active: return "Активная"
        case .ended: return "Завершена"
        case .unknown: return "Неизвестно"
        }
    }
    
    var color: Color {
        switch self {
        case .active: return .green
        case .ended: return .red
        case .unknown: return .gray
        }
    }
}
