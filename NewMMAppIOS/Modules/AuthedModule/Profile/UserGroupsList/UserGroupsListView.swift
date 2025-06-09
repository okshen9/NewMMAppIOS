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
