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
    @Published private(set) var state: AppState = .unAuthorized(false)

    
    func setNewState(_ newState: AppState) {
        Task.detached {
            await MainActor.run {
                withAnimation {
                    self.state = newState
                }
            }
        }
    }

    enum AppState: Equatable {
        case unAuthorized(Bool)
        case authorized
    }
}
