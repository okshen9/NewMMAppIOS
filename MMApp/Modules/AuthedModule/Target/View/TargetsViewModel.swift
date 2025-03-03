//
//  TargetsViewModel.swift
//  
//
//  Created by artem on 09.02.2025.
//

import Foundation
import Combine
import SwiftUI

/// Протокол функционала вьюшек
protocol SubViewScopeProtocol: TargetRowViewModelProtocol, SubTargetRowViewModelProtocol, TargetEditViewProtocol {}

final class TargetsViewModel: ObservableObject, SubscriptionStore, SubViewScopeProtocol {
    
    @Published var targets: [UserTargetDtoModel] = []
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let networkService = ServiceBuilder()
    
    
    @Published var groupedTargets: [TargetCategory: [UserTargetDtoModel]] = [:]
    
    
    init(targets: [UserTargetDtoModel] = [], isLoading: Bool = false, errorMessage: String? = nil) {
        self.targets = targets.sorted { ($0.id ?? 0 < $1.id  ?? 1) }
        self.isLoading = isLoading
        
        $targets
            .map { targets in
                Dictionary(grouping: targets, by: { $0.category ?? .unknown })
                    .mapValues { $0.sorted { ($0.id ?? 0 < $1.id  ?? 1) }}
            }
            .sink { [weak self] targetsDic in
                self?.groupedTargets = targetsDic
            }
            .store(in: &subscriptions)
    }
    
    func editTarget(_ target: UserTargetDtoModel) async -> UserTargetDtoModel? {
            do {
                let updatedTarget = try await networkService.updateTargetAll(model: target)
                
                let targets = try await networkService.getUserTargets(externalId: (UserRepository.shared.userProfile?.externalId) ?? 0).userTargets
                guard !targets.isNil else { return nil }
                DispatchQueue.main.async { [weak self] in
                    withAnimation {
                        self?.targets = targets ?? []
                    }
                }
                return updatedTarget
            } catch {
                print(error.localizedDescription)
                return nil
            }
    }
    
    /// Загружает
    @MainActor
    func loadTargets() {
        isLoading = true
        errorMessage = nil
        Task { [weak self] in
            do {
                let targets = try await self?.networkService.getUserTargets(externalId: (UserRepository.shared.userProfile?.externalId) ?? 0).userTargets
                guard !targets.isNil else { return }
                self?.targets = targets ?? []
                self?.isLoading = false
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func closedSubTarget(_ subTarget: UserSubTargetDtoModel) {
        errorMessage = nil
        
        var findedTarget: UserTargetDtoModel? = nil
        
        // Ищем TargetModel, содержащую нужный SubTarget
        for (targetIndex, target) in targets.enumerated() {
            if let subTargets = target.subTargets,
               let subTargetIndex = subTargets.firstIndex(where: { $0.id == subTarget.id }) {
                // Обновляем статус SubTarget
                let status = subTarget.targetStatus ?? .notDone
                
                findedTarget = targets[targetIndex]
                
                findedTarget?.subTargets?[subTargetIndex].targetStatus?.changeSelfStatus()
            }
        }
        guard let findedTarget else { return }
        
        Task { [weak self] in
            do {
                let updatedTarget = try await self?.networkService.updateTargetAll(model: findedTarget)
                let externalId = (UserRepository.shared.userProfile?.externalId) ?? 0
                
                let newTargets = try await self?.networkService.getUserTargets(externalId: externalId).userTargets
                guard !newTargets.isNil else { return }
                DispatchQueue.main.async { [weak self] in
                    withAnimation {
                        self?.targets = newTargets?.sorted(by: { ($0.id ?? 0 < $1.id  ?? 1) }) ?? []
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func closedTarget(target: UserTargetDtoModel) {
        var tempTarget = target
        tempTarget.changeSelfStatus()
        errorMessage = nil
        Task { [weak self] in
            do {
                let updatedTarget = try await self?.networkService.updateTargetAll(model: tempTarget)
                
                let targets = try await self?.networkService.getUserTargets(externalId: (UserRepository.shared.userProfile?.externalId) ?? 0).userTargets
                guard !targets.isNil else { return }
                DispatchQueue.main.async { [weak self] in
                    withAnimation {
                        self?.targets = targets ?? []
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
}

