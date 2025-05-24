//
//  ReportViewModel.swift
//  NewMMAppIOS
//
//  Created by artem on 24.05.2025.
//

import Foundation
import Combine
import SwiftUI

class ReportViewModel: ObservableObject, SubscriptionStore {
    /// профиль накого жалоба
    let profile: UserProfileResultDto
    
    /// - Parameter profile: профиль на кого жалоба
    init(profile: UserProfileResultDto) {
        self.profile = profile
    }
    
    func sendReport(_ reportText: String) async -> Bool {
        return true
    }
}
