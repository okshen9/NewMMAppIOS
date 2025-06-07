//
//  UserGroupsListView.swift
//  NewMMAppIOS
//
//  Created by artem on 05.06.25.
//

import SwiftUI

struct UserGroupsListView: View {
    @StateObject private var viewModel: UserGroupsListViewModel
    
    init(userGroups: [GroupResultDTOModel]) {
        _viewModel = StateObject(wrappedValue: UserGroupsListViewModel(userGroups: userGroups))
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if viewModel.isLoading {
                    shimmerState()
                } else if (viewModel.groups.count + viewModel.streams.count) == 0 {
                    emptyState()
                } else {
                    // Секция стримов
                    if !viewModel.streams.isEmpty {
                        groupSection(
                            title: "Потоки",
                            groups: viewModel.streams,
                            icon: "person.2.wave.2.fill",
                            color: .orange
                        )
                    }
                    
                    // Секция групп
                    if !viewModel.groups.isEmpty {
                        groupSection(
                            title: "Группы",
                            groups: viewModel.groups,
                            icon: "person.2.fill",
                            color: .blue
                        )
                    }
                    

                }
            }
            .padding(.horizontal, 16)
        }
        .navigationTitle("Группы и стримы")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await viewModel.refreshGroups()
        }
        .onAppear {
            if !viewModel.isLoadedDetails {
                viewModel.onAppear()
            }
        }
    }
    
    @ViewBuilder
    private func groupSection(
        title: String,
        groups: [GroupResultDTOModel],
        icon: String,
        color: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Заголовок секции
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                
                Text(title)
                    .font(MMFonts.title)
                    .foregroundColor(.headerText)
                
                Spacer()
                
                Text("\(groups.count)")
                    .font(MMFonts.subTitle)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
            // Список групп в секции
            LazyVStack(spacing: 12) {
                ForEach(groups, id: \.id) { group in
                    GroupCardCell(group: group)
                }
            }
        }
    }
    
    @ViewBuilder
    private func shimmerState() -> some View {
        VStack(spacing: 16) {
            ForEach(0..<3, id: \.self) { _ in
                ShimmeringRectangle()
                    .frame(height: 80)
                    .cornerRadius(12)
            }
        }
    }
    
    @ViewBuilder
    private func emptyState() -> some View {
        VStack(spacing: 16) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
                .padding(.top, 100)
            
            Text("Пользователь не состоит в группах")
                .font(MMFonts.title)
                .foregroundColor(.headerText)
            
            Text("Здесь будут отображаться группы и стримы")
                .font(MMFonts.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
    }
}



// MARK: - Preview
#Preview {
    NavigationStack {
        UserGroupsListView(userGroups: [
            // Группы
            GroupResultDTOModel(
                id: 1,
                title: "Основная группа разработчиков",
                userOwners: [],
                userMembers: [],
                description: "Группа для изучения основ программирования",
                tgChatReference: "dev_group",
                isDeleted: false,
                creationDateTime: "2025-01-01T00:00:00Z",
                lastUpdatingDateTime: "2025-01-15T00:00:00Z",
                tgChatId: "123456",
                usersGroupType: .group,
                dateFrom: "2025-01-01T00:00:00Z",
                dateTo: "2025-12-31T23:59:59Z"
            ),
            GroupResultDTOModel(
                id: 2,
                title: "Группа изучения UI/UX",
                userOwners: [],
                userMembers: [],
                description: "Группа для изучения дизайна интерфейсов",
                tgChatReference: "design_group",
                isDeleted: false,
                creationDateTime: "2025-02-01T00:00:00Z",
                lastUpdatingDateTime: "2025-02-15T00:00:00Z",
                tgChatId: "234567",
                usersGroupType: .group,
                dateFrom: "2025-02-01T00:00:00Z",
                dateTo: "2025-08-31T23:59:59Z"
            ),
            // Стримы
            GroupResultDTOModel(
                id: 3,
                title: "Swift продвинутый курс",
                userOwners: [],
                userMembers: [],
                description: "Углубленное изучение Swift с практическими заданиями",
                tgChatReference: "swift_advanced_stream",
                isDeleted: false,
                creationDateTime: "2025-01-01T00:00:00Z",
                lastUpdatingDateTime: "2025-01-15T00:00:00Z",
                tgChatId: "345678",
                usersGroupType: .stream,
                dateFrom: "2025-01-01T00:00:00Z",
                dateTo: "2025-06-30T23:59:59Z"
            ),
            GroupResultDTOModel(
                id: 4,
                title: "iOS разработка для начинающих",
                userOwners: [],
                userMembers: [],
                description: nil,
                tgChatReference: "ios_beginners",
                isDeleted: false,
                creationDateTime: "2024-01-01T00:00:00Z",
                lastUpdatingDateTime: "2024-06-01T00:00:00Z",
                tgChatId: "456789",
                usersGroupType: .stream,
                dateFrom: "2024-01-01T00:00:00Z",
                dateTo: "2024-06-01T00:00:00Z"
            )
        ])
    }
} 
