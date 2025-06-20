//
//  NewMMAppIOSApp.swift
//  NewMMAppIOS
//
//  Created by artem on 07.04.2025.
//

import SwiftUI

@main
struct NewMMAppIOSApp: App {
    // StateObject должны инициализироваться здесь
    @StateObject private var appStateService = AppNavigationStateService()
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
                        .withToast()

                case let .unAuthorized(isReset):
                    NavigationStack(path: $authNavigationManager.path) {
                        AuthSUIView()
                            .navigationDestination(for: AuthRoute.self) { route in
                                switch route {
                                case .login:
                                    AuthSUIView()
                                case let .signup(profileModel, authModel):
                                    ProfileInfoView(viewModel: ProfileInfoViewModel(
                                        profileModel: profileModel,
                                        authModel: authModel,
                                        isEditProfile: false))
                                    .environmentObject(authNavigationManager)
                                }
                            }
                            .environmentObject(authNavigationManager)
                    }
                    .withToast()
                }
            }
            .onChange(of: appStateService.state) { oldVal, newVal in
                if case let .unAuthorized(isReset) = newVal,
                   newVal != oldVal,
                   isReset {
                    authNavigationManager.popToRoot()
                }
            }
            .preferredColorScheme(.light)
            .onAppear {
                // Настройка ServiceBuilder после инициализации StateObject
                ServiceBuilder.shared.setAppStateServise(appStateService)

                // Установка начального состояния
                Task {
                    let repository = UserRepository.shared
                    let roles = await repository.roles
                    let jwt = await repository.jwt
                    let refreshJWT = await repository.refreshJWT

                    let newState: AppNavigationStateService.AppState =
                    ((roles?.contains(Roles.user.rawValue)).orFalse ||
                    (roles?.contains(Roles.admin.rawValue)).orFalse) &&
                    !jwt.isEmptyOrNil && !refreshJWT.isEmptyOrNil
                    ? .authorized : .unAuthorized(true)
                    appStateService.setNewState(newState)
                }
            }
            .onShakeGesture {
#if DEBUG
                print("Device has been shaken")
                showDebugPanel = true
#endif
            }
            .sheet(isPresented: $showDebugPanel) {
				TestScreenVC(appStateService: appStateService)
            }
            .environmentObject(appStateService)
        }
    }
}
