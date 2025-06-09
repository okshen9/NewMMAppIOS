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
                                    onHideUser: { externalId in
                                        let hideResult = await viewModel.hideEvent(externalId: externalId)
                                        if hideResult {
                                            let updateResult = await viewModel.getNextEvents(resetSearch: true)
                                            return updateResult
                                        } else {
                                            return false
                                        }
                                    },
                                    event: event)
                                .onAppear {
                                    let thresholdIndex = feedEvents.count - 1
                                    if index == thresholdIndex && !viewModel.paginatingLoading && !viewModel.isAll {
                                        Task {
                                            let _ = await viewModel.getNextEvents(resetSearch: false)
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
                let _ = await viewModel.getNextEvents(resetSearch: true)
            }
            .onAppear {
                print("onAppear FeedView ===")
                viewModel.onApper()
            }
//            .alert("Скрыть пользователя", isPresented: $showHideUserAlert) {
//                Button("Отмена", role: .cancel) { }
//                Button("Скрыть", role: .destructive) {
//                    if let userToHide = userToHide {
//                        Task {
//                            await viewModel.hideEvent(externalId: userToHide.externalId)
//                            // Обновляем список после скрытия
//                            await viewModel.getNextEvents(resetSearch: true)
//                        }
//                    }
//                }
//            } message: {
//                if let userToHide = userToHide {
//                    Text("Вы уверены, что хотите скрыть все новости от пользователя \(userToHide.name)?")
//                }
//            }
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
                    let _ = await viewModel.getNextEvents(resetSearch: true)
                }
            }
            .presentationCompactAdaptation(.popover)
        }
    }

    // MARK: - ViewBuilder
    @ViewBuilder
    func shimerState() -> some View {
        VStack(spacing: 8) {
			ShimmeringRectangle()
				.frame(height: 100)
				.cornerRadius(26)
			
			ShimmeringRectangle()
				.frame(height: 100)
				.cornerRadius(26)
			
			ShimmeringRectangle()
				.frame(height: 100)
				.cornerRadius(26)
			
			ShimmeringRectangle()
				.frame(height: 100)
				.cornerRadius(26)
            
            ShimmeringRectangle()
                .frame(height: 100)
                .cornerRadius(26)
            Spacer()
        }
    }
}

