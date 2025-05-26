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
    private let serviceNetwork = ServiceBuilder.shared
    /// профиль накого жалоба
    let profile: UserProfileResultDto
    @Published var isLoad = false
    
    /// - Parameter profile: профиль на кого жалоба
    init(profile: UserProfileResultDto) {
        self.profile = profile
    }
    
    func sendReport(_ reportText: String) async -> Bool {
        isLoad = true
        do {
            let _ = try await serviceNetwork.sendReport(reportText, userId: profile.id ?? 0)
            isLoad = false
            return true
        } catch {
            isLoad = false
            return false
        }
    }
}
