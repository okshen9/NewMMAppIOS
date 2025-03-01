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
    
    @Published var targets: [UserTargetDtoModel] = []
    @Published var clusedSubTarget: UserSubTargetDtoModel?
    @Published var clusedTarget: UserTargetDtoModel?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let networkService = ServiceBuilder()
    
    
    @Published var groupedTargets: [TargetCategory: [UserTargetDtoModel]] = [:]
    
    
    init(targets: [UserTargetDtoModel] = [], clusedSubTarget: UserSubTargetDtoModel? = nil, isLoading: Bool = false, errorMessage: String? = nil) {
        self.targets = targets.sorted { ($0.id ?? 0 < $1.id  ?? 1) }
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
                        let status = subTarget.targetStatus ?? .notDone
                        targets[targetIndex].subTargets?[subTargetIndex].targetStatus = status == .done ? TargetSubStatus.notDone : .done
                        self?.closedSubTarget(subTarget: targets[targetIndex])
                    }
                }
            }.store(in: &subscriptions)
        
        $clusedTarget
            .sink { [weak self] target in
                guard var target = target else { return }
                target.targetStatus?.changeSelf()
                self?.closedSubTarget(subTarget: target)
            }.store(in: &subscriptions)
        
        $targets
            .map { targets in
                Dictionary(grouping: targets, by: { $0.category ?? .unknown })
            }
            .sink { [weak self] targetsDic in
                self?.groupedTargets = targetsDic
            }
            .store(in: &subscriptions)
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
                let updatedTarget = try await self?.networkService.updateTargetAll(model: subTarget)
                
                let targets = try await self?.networkService.getUserTargets(externalId: (UserRepository.shared.userProfile?.externalId) ?? 0).userTargets
                guard !targets.isNil else { return }
                DispatchQueue.main.async { [weak self] in
                    withAnimation {
                        self?.targets = targets?.sorted(by: { ($0.id ?? 0 < $1.id  ?? 1) }) ?? []
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    //    func closedTarget(target: UserTargetDtoModel) {
    //        isLoading = true
    //        errorMessage = nil
    //        Task { [weak self] in
    //            do {
    ////                guard let self else { return }
    //                let updatedTarget = try await self?.networkService.updateTargetAll(model: target)
    //
    //                let targets = try await self?.networkService.getUserTargets(externalId: (UserRepository.shared.userProfile?.externalId) ?? 0).userTargets
    //                guard !targets.isNil else { return }
    //                DispatchQueue.main.async { [weak self] in
    //                    withAnimation {
    //                        self?.targets = targets ?? []
    //                    }
    //                }
    //            } catch {
    //                print(error.localizedDescription)
    //            }
    //        }
    //    }
    
}

