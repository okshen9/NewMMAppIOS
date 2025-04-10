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
    @Published var payRequest: [PaymentRequestResponseDto]?
    private let serviceNetwork = ServiceBuilder.shared
    private let userRepository = UserRepository.shared
    
    // MARK: - Public Methods
    func onApper() {
        Task {

                await updateProfile()
        }
    }
    
    func updateProfile() async {
        do {
            let externalId = userRepository.externalId ?? -1
            await setIsLoading(true)
            guard let updatetedProfile = try await serviceNetwork.getPaymentPlan(id: externalId) else { return }
            await updateUI(profile: updatetedProfile)
        } catch {
            print("Neshko PayRequest \(error) - Ошибка загрзуки ")
        }
    }
    
    @MainActor
    private func updateUI(profile: [PaymentRequestResponseDto]?, isLoading: Bool = false) {
        self.payRequest = profile
        self.isLoading = isLoading
        let testPay = payRequest?.map({$0.amount})
            .compactMap{$0}
        

        print("payRequest:" + "\(testPay)")
    }
    
    @MainActor
    private func setIsLoading(_ isLoading: Bool) {
        self.isLoading = isLoading
    }
}
