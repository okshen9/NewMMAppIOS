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
    // MARK: - Published Properties
    @Published var targets: [UserTargetDtoModel] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var tasksItems: [TaskProgress] = []
    @Published var groupedTargets: [TargetCategory: [UserTargetDtoModel]] = [:]
    
    // MARK: - Private Properties
    private let networkService = ServiceBuilder.shared
    
    // MARK: - Initialization
    init(targets: [UserTargetDtoModel] = [], isLoading: Bool = false, errorMessage: String? = nil) {
        self.targets = targets.sorted { ($0.id ?? 0 < $1.id  ?? 1) }
        self.isLoading = isLoading
        setupTargetsObserver()
        updateTaskProgressItems()
    }
    
    // MARK: - Private Methods
    private func setupTargetsObserver() {
        $targets
            .map { targets in
                Dictionary(grouping: targets, by: { $0.category ?? .unknown })
                    .mapValues { $0.sorted { ($0.id ?? 0 < $1.id  ?? 1) }}
            }
            .sink { [weak self] targetsDic in
                self?.groupedTargets = targetsDic
                self?.updateTaskProgressItems()
            }
            .store(in: &subscriptions)
    }
    
    private func updateTaskProgressItems() {
        // Вычисление процента выполнения для каждой категории
        let categories = TargetCategory.allCases
        var updatedTaskItems: [TaskProgress] = []
        
        for category in categories {
            let categoryTargets = groupedTargets[category] ?? []
            if !categoryTargets.isEmpty {
                let totalTargets = categoryTargets.count
                let completedTargets = categoryTargets.filter { 
                    $0.targetStatus == .done || $0.targetStatus == .doneExpired 
                }.count
                
                let progress = totalTargets > 0 ? Double(completedTargets) / Double(totalTargets) : 0.0
                let categoryColor: Color = category.color
                
                updatedTaskItems.append(
                    TaskProgress(
                        progress: progress,
                        color: categoryColor,
                        name: category.rawValue,
                        value: Double(totalTargets) / Double(targets.count)
                    )
                )
            }
        }
        
        // Обновляем только если есть данные
        if !updatedTaskItems.isEmpty {
            tasksItems = updatedTaskItems
        }
    }
    
    // MARK: - Network Request Methods
    /// Загружает цели пользователя с сервера
    @MainActor
    func loadTargets() {
        isLoading = true
        errorMessage = nil
        
        Task { [weak self] in
            do {
                guard let self = self else { return }
                let userExternalId = UserRepository.shared.userProfile?.externalId ?? 0
                let result = try await self.networkService.getUserTargets(externalId: userExternalId)
                
                if let targets = result.userTargets {
                    self.targets = targets.sorted { ($0.id ?? 0 < $1.id  ?? 1) }
                }
                self.isLoading = false
            } catch {
                await self?.handleError(error)
            }
        }
    }
    
    /// Обрабатывает ошибки при работе с сетевыми запросами
    @MainActor
    private func handleError(_ error: Error) {
        isLoading = false
        errorMessage = "Ошибка: \(error.localizedDescription)"
        print("Ошибка Target: \(error.localizedDescription)")
    }
    
    @MainActor
    func saveTarget(_ target: UserTargetDtoModel, isCreateTarget: Bool) async -> UserTargetDtoModel? {
        isLoading = true
        do {
            let result = isCreateTarget ? 
                await createTarget(target) : 
                await editTarget(target)
            isLoading = false
            return result
        } catch {
            await handleError(error)
            isLoading = false
            return nil
        }
    }
    
    private func editTarget(_ target: UserTargetDtoModel) async -> UserTargetDtoModel? {
        do {
            let updatedTarget = try await networkService.updateTargetAll(model: target)
            await refreshTargetsData()
            return updatedTarget
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    private func createTarget(_ target: UserTargetDtoModel) async -> UserTargetDtoModel? {
        do {
            let createSubTarget = target.subTargets?.map { CreateSubTargetBodyModel(
                title: $0.title,
                description: $0.description,
                subTargetPercentage: 100.0 / Double(target.subTargets?.count ?? 1),
                deadLineDateTime: $0.deadLineDateTime,
                targetSubStatus: $0.targetStatus)
            }
            
            let createTargetBodyModel: CreateUserTargetBodyModel = .init(
                title: target.title,
                description: target.description,
                userExternalId: target.userExternalId,
                deadLineDateTime: target.deadLineDateTime,
                streamId: target.streamId,
                subTargets: createSubTarget,
                category: target.category
            )
            
            let updatedTarget = try await networkService.createUserTarget(model: createTargetBodyModel)
            await refreshTargetsData()
            return updatedTarget
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    @MainActor
    private func refreshTargetsData() async {
        do {
            let userExternalId = UserRepository.shared.userProfile?.externalId ?? 0
            let result = try await networkService.getUserTargets(externalId: userExternalId)
            
            if let targets = result.userTargets {
                withAnimation {
                    self.targets = targets.sorted { ($0.id ?? 0 < $1.id  ?? 1) }
                }
            }
        } catch {
            print("Ошибка обновления целей: \(error.localizedDescription)")
        }
    }
    
    // MARK: - SubTarget Methods
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
                
                await self?.refreshTargetsData()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    /// Закрывает последнюю подцель и при необходимости закрывает родительскую цель или создает новую подцель
    func closedSubTargetWithParent(_ subTarget: UserSubTargetDtoModel, closeParent: Bool) {
        errorMessage = nil
        
        var findedTarget: UserTargetDtoModel? = nil
        
        // Ищем TargetModel, содержащую нужный SubTarget
        for (targetIndex, target) in targets.enumerated() {
            if let subTargets = target.subTargets,
               let subTargetIndex = subTargets.firstIndex(where: { $0.id == subTarget.id }) {
                
                findedTarget = targets[targetIndex]
                
                // Закрываем подцель
                findedTarget?.subTargets?[subTargetIndex].targetStatus?.changeSelfStatus()
                
                // Если выбрано "Цель закрыта полностью", меняем статус цели на done/doneExpired
                if closeParent {
                    // Проверяем, просрочена ли цель
                    let deadlineDate = findedTarget?.deadLineDateTime?.dateFromStringISO8601 ?? Date()
                    let now = Date()
                    
                    if deadlineDate < now {
                        findedTarget?.targetStatus = .doneExpired
                    } else {
                        findedTarget?.targetStatus = .done
                    }
                }
            }
        }
        
        guard let findedTarget else { return }
        
        Task { [weak self] in
            do {
                // Обновляем цель с новым статусом подцели и, возможно, цели
                let updatedTarget = try await self?.networkService.updateTargetAll(model: findedTarget)
                
                // Если выбрано НЕ закрывать цель полностью, добавляем новую подцель
                if !closeParent {
                    self?.addNewSubtarget(
                        to: findedTarget,
                        withName: "Завершить \(findedTarget.title ?? "цель")"
                    )
                } else {
                    await self?.refreshTargetsData()
                }
            } catch {
                print("Ошибка при закрытии последней подцели: \(error.localizedDescription)")
            }
        }
    }
    
    /// Добавляет новую подцель к указанной цели
    func addNewSubtarget(to parentTarget: UserTargetDtoModel, withName name: String) {
        var targetCopy = parentTarget
        
        // Создаем новую подцель
        let newSubtarget = UserSubTargetDtoModel(
            title: name,
            description: "Финальная подцель для завершения задачи",
            subTargetPercentage: 100.0,
            targetSubStatus: .notDone,
            rootTargetId: parentTarget.id,
            deadLineDateTime: parentTarget.deadLineDateTime
        )
        
        // Добавляем подцель к цели
        if targetCopy.subTargets == nil {
            targetCopy.subTargets = []
        }
        targetCopy.subTargets?.append(newSubtarget)
        
        // Обновляем процентное соотношение для всех подцелей
        if let subTargets = targetCopy.subTargets, !subTargets.isEmpty {
            let percentage = 100.0 / Double(subTargets.count)
            for i in 0..<subTargets.count {
                targetCopy.subTargets?[i].subTargetPercentage = percentage
            }
        }
        
        Task { [weak self] in
            do {
                // Сохраняем обновленную цель
                guard let self = self else { return }
                let updatedTarget = try await self.networkService.updateTargetAll(model: targetCopy)
                print("Добавлена новая подцель: \(name)")
                await self.refreshTargetsData()
            } catch {
                print("Ошибка при добавлении новой подцели: \(error.localizedDescription)")
            }
        }
    }
    
    func closedTarget(target: UserTargetDtoModel) {
        isLoading = true
        var tempTarget = target
        tempTarget.changeSelfStatus()
        errorMessage = nil
        
        Task { [weak self] in
            do {
                let updatedTarget = try await self?.networkService.updateTargetAll(model: tempTarget)
                
                await self?.refreshTargetsData()
                await MainActor.run {
                    self?.isLoading = false
                }
            } catch {
                await self?.handleError(error)
            }
        }
    }
    
    /// Удаляет цель
    func deleteTarget(target: UserTargetDtoModel) {
        isLoading = true
        var tempTarget = target
        tempTarget.isDeleted = true
        errorMessage = nil
        
        Task { [weak self] in
            do {
                // Обновляем статус "isDeleted" у цели
                let updatedTarget = try await self?.networkService.updateTargetAll(model: tempTarget)
                
                // Обновляем список целей
                await self?.refreshTargetsData()
                await MainActor.run {
                    self?.isLoading = false
                }
            } catch {
                await self?.handleError(error)
            }
        }
    }
}

