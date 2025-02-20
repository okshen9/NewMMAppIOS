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
    
    static let shared = TargetsViewModel()
    
    @Published var targets: [UserTargetDtoModel] = []
    @Published var clusedSubTarget: UserSubTargetDtoModel?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let networkService = ServiceBuilder()
    
    init(targets: [UserTargetDtoModel] = [], clusedSubTarget: UserSubTargetDtoModel? = nil, isLoading: Bool = false, errorMessage: String? = nil) {
        self.targets = targets
        self.clusedSubTarget = clusedSubTarget
        self.isLoading = isLoading
        $clusedSubTarget
            .sink { [weak self] subTarget in
                guard var targets = self?.targets,
                      let subTarget
                else { return }

                // Ищем TargetModel, содержащую нужный SubTarget
                for (targetIndex, target) in targets.enumerated() {
                    if let subTargets = target.subTargets,
                       let subTargetIndex = subTargets.firstIndex(where: { $0.id == subTarget.id }) {
                        // Обновляем статус SubTarget
                        targets[targetIndex].subTargets?[subTargetIndex].targetStatus = .done
                        self?.closedSubTarget(subTarget: targets[targetIndex])
                    }
                }
            }.store(in: &subscriptions)
    }
    
    /// Загружает
    @MainActor
    func loadTargets() {
        isLoading = true
        errorMessage = nil
        Task { [weak self] in
            do {
                let targets = try await self?.networkService.getUserTargets(externalId: (UserRepository.shared.userProfile?.externalId) ?? 0).userTargets
                guard let self, !targets.isNil else { return }
                self.targets = targets ?? []
                self.isLoading = false
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func closedSubTarget(subTarget: UserTargetDtoModel) {
        isLoading = true
        errorMessage = nil
        Task { [weak self] in
            do {
                guard let self else { return }
                let updatedTarget = try await self.networkService.updateTargetAll(model: subTarget)
                var newTargets = self.targets
                guard newTargets.contains(where: {$0.id == updatedTarget.id}) else {
                    self.targets.append(updatedTarget)
                    self.isLoading = false
                    return
                }
                
                for (targetIndex, target) in newTargets.enumerated() {
                    if target.id == updatedTarget.id {
                        // Обновляем статус SubTarget
                        newTargets[targetIndex] = updatedTarget
                    }
                }
                self.targets.append(updatedTarget)
                self.isLoading = false

            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

