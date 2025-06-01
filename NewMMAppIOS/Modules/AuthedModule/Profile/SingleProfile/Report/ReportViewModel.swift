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
        defer { isLoad = false }
        
        do {
            guard let profileId = profile.id else {
                throw NSError(domain: "SendReportError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid profile ID"])
            }

            try await serviceNetwork.sendReport(reportText, userId: profileId)
            return true
        } catch {
            await ToastManager.shared.show(.baseError)
            return false
        }
    }
}
