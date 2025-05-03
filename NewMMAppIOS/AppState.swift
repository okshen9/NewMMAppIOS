//
//  AppState.swift
//  MMApp
//
//  Created by artem on 26.03.2025.
//

import Foundation
import SwiftUI

@MainActor
class AppNavigationStateService: ObservableObject {
    @Published private(set) var state: AppState = .unAuthorized

    func setNewState(_ newState: AppState) {
        withAnimation {
            self.state = newState
        }
    }

    enum AppState {
        case unAuthorized
        case authorized
    }
}
