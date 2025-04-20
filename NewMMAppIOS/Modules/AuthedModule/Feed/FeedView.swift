//
//  FeedView.swift
//  MMApp
//
//  Created by artem on 13.03.2025.
//

import SwiftUI

enum FeedViewRoute: Hashable {
    case profile(UserProfileResultDto)
//    case settings
}

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                LazyVStack(spacing: 8) {
                    if viewModel.isLoading {
                        shimerState()
                    } else {
                        if let feedEvents = viewModel.feedEvents, !feedEvents.isEmpty {

                            ForEach(feedEvents) { event in

                                NavigationLink(destination: {
                                    if let profileId = event.userProfile?.externalId {
                                        ProfileView(viewModel: .init(externalId: profileId))
                                    }
                                }, label: {
                                    NewFeedCell(event: event)
                                })

                            }
                            if !viewModel.isAll {
                                ActivityCell()
                                    .onAppear {
                                        Task.detached {
                                            await viewModel.getNextEvents(resetSearch: false)
                                        }
                                    }
                            }
                        } else {
                            Text("У вас пока нет новостей")
                        }

                    }
                }
                .padding(.horizontal, 8)
                .padding(.top, 8)
            }
            .navigationTitle("События")
            .toolbar(content: {

            })
            .refreshable {
                await viewModel.getNextEvents(resetSearch: true)
            }
            .onAppear {
                viewModel.onApper()
            }
            .navigationDestination(for: FeedViewRoute.self) { route in
                switch route {
                case .profile(let profile):
                    ProfileView(viewModel: .init(externalId: profile.id ?? 1))

                }
            }

        }
    }

    @ViewBuilder
    func getMenu() -> some View {

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
    FeedView()
}
