//
//  NavigationManager.swift
//  MMApp
//
//  Created by artem on 29.03.2025.
//
import SwiftUI

class NavigationManager<Route: AnyRoute>: ObservableObject {
    @Published var path = NavigationPath()

    func navigate(to route: Route) {
        path.append(route)
        print("Navigated to: \(route), Path: \(path)")
    }

    func pop() {
        if !path.isEmpty {
            path.removeLast()
            print("Popped, Path: \(path)")
        }
    }

    func popToRoot() {
        path = NavigationPath()
        print("Popped to root, Path: \(path)")
    }

    func replace(with route: Route) {
        path = NavigationPath([route])
        print("Replaced with: \(route), Path: \(path)")
    }
}

protocol AnyRoute: Hashable {
}

enum AuthRoute: Hashable, AnyRoute {
    case login
    case signup(profileModel: UserProfileResultDto?, authModel: AuthUserDtoResult?)
}

enum MainRoute: Hashable, AnyRoute {
    case home
}
