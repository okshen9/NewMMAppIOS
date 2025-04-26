//
//  FeedView.swift
//  MMApp
//
//  Created by artem on 13.03.2025.
//

import SwiftUI
import SwiftUICore

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    @State private var showEventTypeMenu = false
    
    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            ScrollView {
                LazyVStack(spacing: 8) {
                    if viewModel.isLoading {
                        shimerState()
                    } else {
                        if let feedEvents = viewModel.feedEvents, !feedEvents.isEmpty {
                            ForEach(Array(feedEvents.enumerated()), id: \.element.id) { index, event in
                                NewFeedCell(
                                    onHeaderTap: {
                                        if let externalId = Int(event.creatorExternalId.orEmpty) {
                                            print("Navigating to profile with externalId: \(externalId)")
                                            viewModel.navigateToProfile(withId: externalId)
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
            .navigationDestination(for: NavigationRoute.self) { route in
                switch route {
                case .profile(let externalId):
                    ProfileView(externalId: externalId)
//                        .navigationTitle("Профиль")
                }
            }
            .navigationTitle("События")
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                toolBarMenu()
                }
            })
            .refreshable {
                await viewModel.getNextEvents(resetSearch: true)
            }
            .onAppear {
                print("onAppear FeedView ===")
                viewModel.onApper()
            }

        }
    }

    @ViewBuilder
    func toolBarMenu() -> some View {
        
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
