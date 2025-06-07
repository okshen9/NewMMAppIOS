//
//  GroupDetailView.swift
//  NewMMAppIOS
//
//  Created by artem on 05.06.25.
//

import SwiftUI

struct GroupDetailView: View {
    let group: GroupResultDTOModel
    
    private var groupType: GroupTypeResultDTOModel {
        group.usersGroupType ?? .unknown
    }
    
    private var status: GroupStatus {
        guard let dateTo = group.dateTo?.dateFromStringISO8601 else { return .unknown }
        return dateTo > Date() ? .active : .ended
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Заголовок группы
                groupHeader()
                
                // Информация о группе
                groupInfo()
                
                // Участники и менторы
                participantsList()
                
                // Telegram чат
                if let tgReference = group.tgChatReference, !tgReference.isEmpty {
                    telegramSection(tgReference: tgReference)
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 8)
        .navigationTitle(group.title ?? "Группа")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    private func groupHeader() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(group.title ?? "Без названия")
                        .font(MMFonts.title)
                        .foregroundColor(.headerText)
                    
                    Text(groupType.displayName)
                        .font(MMFonts.title)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                StatusBadge(status: status)
            }
            
            if !group.dateRange.isEmpty {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.gray)
                    
                    Text(group.dateRange)
                        .font(MMFonts.body)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    @ViewBuilder
    private func groupInfo() -> some View {
        if let description = group.description, !description.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Описание")
                    .font(MMFonts.title)
                    .foregroundColor(.headerText)
                
                Text(description)
                    .font(MMFonts.body)
                    .foregroundColor(.headerText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
    
    @ViewBuilder
    private func participantsList() -> some View {
        VStack(spacing: 16) {
            // Менторы
            if let owners = group.userOwners, !owners.isEmpty {
                participantsSection(
                    title: "Менторы",
                    icon: "person.2.fill",
                    participants: owners,
                    color: .orange
                )
            }
            
            // Участники
            if let members = group.userMembers, !members.isEmpty {
                participantsSection(
                    title: "Участники",
                    icon: "person.3.fill",
                    participants: members,
                    color: .blue
                )
            }
        }
    }
    
    @ViewBuilder
    private func participantsSection(
        title: String,
        icon: String,
        participants: [UserProfileResultDto],
        color: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                
                Text(title)
                    .font(MMFonts.title)
                    .foregroundColor(.headerText)
                
                Spacer()
                
                Text("\(participants.count)")
                    .font(MMFonts.subTitle)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
            
            LazyVStack(spacing: 8) {
                ForEach(participants, id: \.id) { participant in
                    GroupUserRow(user: participant)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    @ViewBuilder
    private func telegramSection(tgReference: String) -> some View {
        Button(action: {
            openTelegramChat(tgReference: tgReference)
        }) {
            HStack {
                Image(.tg)
                    .resizable()
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Чат группы")
                        .font(MMFonts.title)
                        .foregroundColor(.blue)
                    
                    Text("Перейти в Telegram")
                        .font(MMFonts.body)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(16)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(16)
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



// MARK: - Preview
#Preview {
    NavigationStack {
        GroupDetailView(group: GroupResultDTOModel(
            id: 1,
            title: "Продвинутый Swift стрим",
            userOwners: [
                UserProfileResultDto(
                    id: 1,
                    externalId: 1,
                    username: "mentor1",
                    fullName: "Ментор Один",
                    userProfileStatus: nil,
                    userPaymentStatus: nil,
                    isDeleted: false,
                    creationDateTime: nil,
                    lastUpdatingDateTime: nil,
                    userGroups: nil,
                    comment: nil,
                    photoUrl: nil,
                    userTargets: nil,
                    targetCalculationInfo: TargetCalculationInfoDto(
                        categoryToInfoMapping: [:],
                        allCategoriesDonePercentage: 85.0
                    ),
                    location: "Москва",
                    phoneNumber: nil,
                    activitySphere: nil,
                    paymentCalculationInfo: nil,
                    biography: nil,
                    forUserHideThisExtIdUsersEvents: nil
                )
            ],
            userMembers: [
                UserProfileResultDto(
                    id: 2,
                    externalId: 2,
                    username: "student1",
                    fullName: "Студент Первый",
                    userProfileStatus: nil,
                    userPaymentStatus: nil,
                    isDeleted: false,
                    creationDateTime: nil,
                    lastUpdatingDateTime: nil,
                    userGroups: nil,
                    comment: nil,
                    photoUrl: nil,
                    userTargets: nil,
                    targetCalculationInfo: TargetCalculationInfoDto(
                        categoryToInfoMapping: [:],
                        allCategoriesDonePercentage: 65.0
                    ),
                    location: "Санкт-Петербург",
                    phoneNumber: nil,
                    activitySphere: nil,
                    paymentCalculationInfo: nil,
                    biography: nil,
                    forUserHideThisExtIdUsersEvents: nil
                )
            ],
            description: "Углубленное изучение Swift с практическими заданиями и проектами",
            tgChatReference: "swift_advanced_stream",
            isDeleted: false,
            creationDateTime: "2025-01-01T00:00:00Z",
            lastUpdatingDateTime: "2025-01-15T00:00:00Z",
            tgChatId: "123456",
            usersGroupType: .stream,
            dateFrom: "2025-01-01T00:00:00Z",
            dateTo: "2025-06-30T23:59:59Z"
        ))
    }
} 
