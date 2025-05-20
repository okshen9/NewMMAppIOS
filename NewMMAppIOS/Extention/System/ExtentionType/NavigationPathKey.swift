//
//  NavigationPathKey.swift
//  NewMMAppIOS
//
//  Created by artem on 20.05.2025.
//

import SwiftUI


struct NavigationPathKey: EnvironmentKey {
    static let defaultValue: NavigationPath = .init()
}

extension EnvironmentValues {
    var navigationPath: NavigationPath {
        get { self[NavigationPathKey.self] }
        set { self[NavigationPathKey.self] = newValue }
    }
}
