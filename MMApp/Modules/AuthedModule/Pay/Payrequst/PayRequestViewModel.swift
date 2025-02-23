//
//  PayRequestViewModel.swift
//  MMApp
//
//  Created by artem on 23.02.2025.
//

import Foundation
import Combine
import SwiftUI

// MARK: - ViewModel
final class PayRequestViewModel: ObservableObject {
    
    @Published var isLoading = true
    //    @Published var PayRequest: PayRequestResultDto?
    
    // MARK: - Public Methods
    func onApper() {
        Task {
//            if let profileDto = userRepository.userProfile {
//                await updateUI(profile: profileDto)
//            } else {
//                await updateProfile()
//            }
        }
    }
    
    func updateProfile() async {
        do {
            await setIsLoading(true)
//            guard let updatetedProfile = try await serviceNetwork.getPayRequest() else { return }
//            await updateUI(profile: updatetedProfile)
        } catch {
            print("Neshko PayRequest \(error) - Ошибка загрзуки ")
        }
    }
    
//    @MainActor
//    private func updateUI(profile: UserProfileResultDto?, isLoading: Bool = false) {
//        self.profile = profile
//        self.isLoading = isLoading
//    }
    
    @MainActor
    private func setIsLoading(_ isLoading: Bool) {
        self.isLoading = isLoading
    }
}
