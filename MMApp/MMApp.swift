//
//  TestMMSUIApp.swift
//  MMApp
//
//  Created by artem on 30.03.2025.
//


import SwiftUI

@main
struct MMApp: App {
    // StateObject должны инициализироваться здесь
    @StateObject private var appStateService = AppStateService()
    @StateObject private var authNavigationManager: NavigationManager<AuthRoute> = .init()
    @State private var showDebugPanel: Bool = false

    init() {
        // Не используйте StateObject в init(), вместо этого настройте ServiceBuilder позже
        // ServiceBuilder.shared.setAppStateServise(appStateService) <- Уберите это отсюда
    }

    var body: some Scene {
        WindowGroup {
            Group {
                switch appStateService.state {
                case .authorized:
                    TabBarView()
                        .environmentObject(authNavigationManager)
                case .unAuthorized:
                    AuthSUIView()
                        .navigationDestination(for: AuthRoute.self) { route in
                            switch route {
                            case .login:
                                AuthSUIView()
                            case let .signup(profileModel, authModel):
                                ProfileInfoView(viewModel: ProfileInfoViewModel(
                                    profileModel: profileModel,
                                    authModel: authModel))
                            }
                        }
                }
            }
            .onAppear {
                // Настройка ServiceBuilder после инициализации StateObject
                ServiceBuilder.shared.setAppStateServise(appStateService)

                // Установка начального состояния
                let newState: AppStateService.AppState = !UserRepository.shared.jwt.isEmptyOrNil ? .authorized : .unAuthorized
                appStateService.setNewState(newState)
            }
            .onShakeGesture {
                print("Device has been shaken")
                showDebugPanel = true
            }
            .sheet(isPresented: $showDebugPanel) {
                TestScreenVC()
            }
            .environmentObject(appStateService)
        }
    }
}
