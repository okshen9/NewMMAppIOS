//
//  FeedViewModel.swift
//  MMApp
//
//  Created by artem on 13.03.2025.
//

import Foundation
import Combine
import SwiftUI

// MARK: - ViewModel
final class FeedViewModel: ObservableObject {
    let service = ServiceBuilder()
    
    @Published var isLoading = false
    
    //    @Published var Feed: FeedResultDto?
    
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
            let serachParams = ["type": ""]
            let test = EventsTypeEnum.unknown
//            guard let e/*vents = try await serviceNetwork.searchEvents(searchParams: <#T##[String : String]#>*/, ) else { return }
//            await updateUI(profile: updatetedProfile)
        } catch {
            print("Neshko Feed \(error) - Ошибка загрзуки ")
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
    
    // MARK: - Private methods
    private func getEvnts() async {
//        SearchResponseDTO
        do {
            let searchResponseDTO = try await service.searchEvents(searchParams: [.type([.targetDone, .targetExpiredDone, .targetExpired])])
        } catch {
            print("Neshko searchEvents error")
        }
    }
}


extension FeedViewModel {
    enum Constants {
        static let targetEventType = ["TARGER_EXPIRED", "TARGER_EXPIRED_DONE", "TARGER_DONE"]
    }
}
