//
//  HidenProfile.swift
//  NewMMAppIOS
//
//  Created by artem on 01.06.25.
//

import SwiftUI

struct HidenProfile: View {
    @ObservedObject var viewModel: HidenProfileViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    loadingState()
                } else if viewModel.profiles.isEmpty {
                    emptyState()
                } else {
                    profilesList()
                }
            }
            .navigationTitle("Игнорируемые пользователи")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                    .foregroundColor(.mainRed)
                }
            }
        }
    }
    
    @ViewBuilder
    private func profilesList() -> some View {
        List {
            ForEach(viewModel.profiles, id: \.externalId) { profile in
                HiddenProfileCell(
                    profile: profile,
                    onUnhide: {
                        unhideProfile(profile)
                    }, openTelegramChat: { username in
                        viewModel.openTelegramChat(username: username)
                    }
                )
                .buttonStyle(PlainButtonStyle())
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
        }
        .listStyle(.plain)
        .refreshable {
            viewModel.loadHiddenProfiles()
        }
    }
    
    @ViewBuilder
    private func loadingState() -> some View {
        VStack(spacing: 16) {
            ForEach(0..<3, id: \.self) { _ in
                HStack(spacing: 12) {
                    ShimmeringRectangle()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        ShimmeringRectangle()
                            .frame(height: 16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        ShimmeringRectangle()
                            .frame(height: 12)
                            .frame(width: 120, alignment: .leading)
                    }
                    
                    Spacer()
                    
                    ShimmeringRectangle()
                        .frame(width: 80, height: 32)
                        .cornerRadius(16)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            Spacer()
        }
        .padding(.top, 20)
    }
    
    @ViewBuilder
    func emptyState() -> some View {
        VStack {
            VStack(spacing: 16) {
                Image(systemName: "eye.slash.circle")
                    .font(.system(size: 60))
                    .foregroundColor(.gray)
                
                Text("Нет игнорируемых пользователей")
                    .font(MMFonts.title)
                    .foregroundColor(.headerText)
                
                Text("Здесь будут отображаться пользователи, которых вы добавили в игнорируемые")
                    .font(MMFonts.subTitle)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.white))
            .padding(.top, 40)
            Spacer()
        }
    }
    
    private func loadProfiles() {
        viewModel.loadHiddenProfiles()
    }
    
    private func unhideProfile(_ profile: UserProfileResultDto) {
//        guard let externalId = profile.externalId else { return }
        
        Task {
            let _ = await viewModel.unhideProfile(externalId: profile.externalId)
        }
    }
}

#Preview {
    HidenProfile(viewModel: .init(hidenIds: [0])).emptyState()
}
