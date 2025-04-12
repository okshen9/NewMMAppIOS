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

                VStack {
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
                                    FeedCell(
                                        type: .task,
                                        title: event.title.orEmpty,
                                        subtitle: event.description.orEmpty,
                                        date: event.displayDate ?? Date().toApiString,
                                        userProfile: event.userProfile,
                                        eventType: event.type)
                                    .padding(.horizontal, 16)
                                })

                            }

                        } else {
                            Text("У вас пока нет новостей")
                        }

                    }
                }


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
            .navigationTitle("Новости")
        }
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
