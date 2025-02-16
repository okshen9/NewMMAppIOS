//
//  TargetsViewModel.swift
//  
//
//  Created by artem on 09.02.2025.
//

import Foundation
import Combine
import SwiftUI

final class TargetsViewModel: ObservableObject, SubscriptionStore {
    @State var targets: [UserTarget] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    let apiFactory = APIFactory.global
    private let networkService = ServiceBuilder()
    
    
    /// Загружает
    func loadTargets() {
        isLoading = true
        errorMessage = nil
        
        return Just(loadTargetsMock())
            .delay(for: 2, scheduler: RunLoop.main) // Имитация задержки сети
            .sink { [weak self] in
                self?.targets = $0
                self?.isLoading = false
            }
            .store(in: &subscriptions)
        
//        networkService.getData(model: TargetBodyModel, id: Int)
        
//        apiFactory.fetchTargets()
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] completion in
//                self?.isLoading = false
//                switch completion {
//                case .failure(let error):
//                    self?.errorMessage = error.localizedDescription
//                case .finished:
//                    break
//                }
//            } receiveValue: { [weak self] targets in
//                self?.targets = targets
//            }
//            .store(in: &cancellables)
    }
    
    
}

