//
//  FeedView.swift
//  MMApp
//
//  Created by artem on 13.03.2025.
//

import SwiftUI
import SwiftUICore

enum FeedViewRoute: Hashable {
    case profile(UserProfileResultDto)
//    case settings
}

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    @State private var path = NavigationPath()
    @State private var showEventTypeMenu = false
    
    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                LazyVStack(spacing: 8) {
                    if viewModel.isLoading {
                        shimerState()
                    } else {
                        if let feedEvents = viewModel.feedEvents, !feedEvents.isEmpty {
                            ForEach(Array(feedEvents.enumerated()), id: \.element.id) { index, event in
                                NewFeedCell(
                                    onHeaderTap: {
                                        if let profileId = event.userProfile?.externalId {
                                            ProfileView(viewModel: .init(externalId: profileId))
                                        }
                                    },
                                    event: event)
                                .onAppear {
                                    let thresholdIndex = feedEvents.count - 1
                                    if index == thresholdIndex && !viewModel.paginatingLoading && !viewModel.isAll {
                                        Task {
                                            await viewModel.getNextEvents(resetSearch: false)
                                        }
                                    }
                                }
                            }
                            if viewModel.paginatingLoading {
                                ActivityCell()
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.vertical)
                            }
                        } else {
                            Text("У вас пока нет новостей")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            .navigationTitle("События")
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showEventTypeMenu = true
                    }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundColor(.accentColor)
                    }
                    .popover(isPresented: $showEventTypeMenu) {
                        MultiSelectMenu(
                            isPresented: $showEventTypeMenu,
                            options: EventType.allTargetsType.map { $0.name },
                            originalSelection: Binding(
                                get: { 
                                    Set(viewModel.selectedType.filter { $0.value }.keys.map { $0.name })
                                },
                                set: { newSelection in
                                    // Обновляем выбранные типы
                                    for type in EventType.allTargetsType {
                                        viewModel.selectedType[type] = newSelection.contains(type.name)
                                    }
                                }
                            )
                        ) {
                            // Перезапрашиваем данные
                            Task {
                                await viewModel.getNextEvents(resetSearch: true)
                            }
                        }
                        .presentationCompactAdaptation(.popover)
                    }
                }
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
