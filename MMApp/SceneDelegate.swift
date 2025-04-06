//
//  SceneDelegate.swift
//  MMApp
//
//  Created by artem on 17.12.2024.
//

import UIKit
import SwiftUI

//class SceneDelegate: UIResponder, UIWindowSceneDelegate {
//    var window: UIWindow?
//
//    private var appStateServise = AppStateServise()
//    @StateObject private var authNavigationManager: NavigationManager<AuthRoute> = .init()
//
//    func configServises() {
//        ServiceBuilder.shared.setAppStateServise(appStateServise)
//    }
//
//
//    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
//        guard let windowScene = (scene as? UIWindowScene) else { return }
//        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
//        window?.windowScene = windowScene
//
//        let newState: AppStateServise.AppState = !UserRepository.shared.jwt.isEmptyOrNil ? .authorized : .unAuthorized
//
//        appStateServise.setNewState(newState)
//
//        switch appStateServise.state {
//        case .authorized:
//            window?.rootViewController = UIHostingController(rootView: TabBarView()
//                .navigationDestination(for: AuthRoute.self) { route in
//                    switch route {
//                    case .login:
//                        AuthSUIView()
//                    case let .signup(profileModel, authModel):
//                        ProfileInfoView(viewModel: ProfileInfoViewModel(
//                            profileModel: profileModel,
//                            authModel: authModel))
//                    }
//                }
//                .environmentObject(appStateServise))
//        case .unAuthorized:
//            window?.rootViewController = UIHostingController(rootView: AuthSUIView()
//                .environmentObject(appStateServise))
////                .environmentObject(authNavigationManager))
//        default :
//            break
//        }
//
//        window?.overrideUserInterfaceStyle = .light
//        window?.makeKeyAndVisible()
//        
//    }
//
//    func sceneDidDisconnect(_ scene: UIScene) {
//        // Called as the scene is being released by the system.
//        // This occurs shortly after the scene enters the background, or when its session is discarded.
//        // Release any resources associated with this scene that can be re-created the next time the scene connects.
//        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
//    }
//
//    func sceneDidBecomeActive(_ scene: UIScene) {
//        // Called when the scene has moved from an inactive state to an active state.
//        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
//    }
//
//    func sceneWillResignActive(_ scene: UIScene) {
//        // Called when the scene will move from an active state to an inactive state.
//        // This may occur due to temporary interruptions (ex. an incoming phone call).
//    }
//
//    func sceneWillEnterForeground(_ scene: UIScene) {
//        // Called as the scene transitions from the background to the foreground.
//        // Use this method to undo the changes made on entering the background.
//    }
//
//    func sceneDidEnterBackground(_ scene: UIScene) {
//        // Called as the scene transitions from the foreground to the background.
//        // Use this method to save data, release shared resources, and store enough scene-specific state information
//        // to restore the scene back to its current state.
//    }
//
//
//}
//
//extension UIWindow {
//    open override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
//        ///  Вызов дебаг панели при тряске
//        if motion == .motionShake {
//            let debugMenu = TestScreenVC()
//            let hostingController = UIHostingController(rootView: debugMenu)
//            UIApplication.shared.topmostViewController?.present(hostingController, animated: true)
//        }
//    }
//}
//
