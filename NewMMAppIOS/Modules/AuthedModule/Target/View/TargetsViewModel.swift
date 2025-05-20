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
	@Published var firstOpen = true
    @Published var targets: [UserTargetDtoModel] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var tasksItems: [TaskProgress] = []
    @Published var pieModels: [PieModel] = []
    @Published var groupedTargets: [TargetCategory: [UserTargetDtoModel]] = [:]
	@Published var showDiscardChangesAlert = false
    
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
        var updatedPieModels: [PieModel] = []
        
        // Определяем категории, в которых есть цели
        let categoriesWithTargets = categories.filter { category in
            let targets = groupedTargets[category] ?? []
            return !targets.isEmpty
        }
        
        // Если нет категорий с целями, показываем все категории равномерно
        let equalShare = 1.0 / Double(categoriesWithTargets.isEmpty ? categories.count : categoriesWithTargets.count)
        
        // Перебираем все категории с целями
        for category in categoriesWithTargets.isEmpty ? categories : categoriesWithTargets {
            let categoryTargets = groupedTargets[category] ?? []
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
                    value: equalShare
                )
            )
            
            // Создаем PieModel для каждой категории
            updatedPieModels.append(
                PieModel(
                    totalValue: equalShare, // Используем равное значение для всех категорий
                    currentValue: progress,
                    subModel: categoryTargets.isEmpty ? nil : createSubPieModels(for: categoryTargets),
                    color: categoryColor,
                    title: category.rawValue
                )
            )
        }
        
        // Всегда обновляем данные
        tasksItems = updatedTaskItems
        pieModels = updatedPieModels
    }
    
    /// Создает подмодели для PieModel из целей конкретной категории
    /// - Parameter targets: Массив целей для конкретной категории
    /// - Returns: Массив дочерних PieModel для отображения в диаграмме
    private func createSubPieModels(for targets: [UserTargetDtoModel]) -> [PieModel] {
        let totalCount = Double(targets.count)
        let equalShare = 1.0 / totalCount // Равная доля для каждой подцели
        
        return targets.map { target in
            let isDone = target.targetStatus == .done || target.targetStatus == .doneExpired
            let progress = isDone ? 1.0 : calculateTargetProgress(target)
            
            return PieModel(
                totalValue: equalShare,
                currentValue: progress,
                color: target.category?.color ?? .gray,
                title: target.title ?? "Без названия"
            )
        }
    }
    
    /// Вычисляет прогресс выполнения для конкретной цели на основе ее подцелей
    /// - Parameter target: Модель цели
    /// - Returns: Значение прогресса от 0.0 до 1.0
    private func calculateTargetProgress(_ target: UserTargetDtoModel) -> Double {
        guard let subTargets = target.subTargets, !subTargets.isEmpty else {
            return target.percentage.map { $0 / 100.0 } ?? 0.0
        }
        
        let completedCount = subTargets.filter { $0.targetStatus == .done }.count
        return Double(completedCount) / Double(subTargets.count)
    }
    
    // MARK: - Network Request Methods
    /// Загружает цели пользователя с сервера
    @MainActor
    func loadTargets() {
		firstOpen = false
		guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        
        Task { [weak self] in
            do {
                guard let self = self, let userExternalId = UserRepository.shared.userProfile?.externalId else {
                    await ToastManager.shared.show(.baseError)
                    return
                }
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
	private func handleError(_ error: Error) async {
        isLoading = false
        errorMessage = "Ошибка: \(error.localizedDescription)"
		await ToastManager.shared.show(.baseError)
        print("Ошибка Target: \(error.localizedDescription)")
    }
    
	/// Сохраняет изменения или создает новый таргет
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
    
	/// Сохраняет изменения таргета
    private func editTarget(_ target: UserTargetDtoModel) async -> UserTargetDtoModel? {
        do {
			var minModel: UserTargetDtoModel
			if let oldTarget = targets.first(where: {$0.id == target.id}) {
				minModel = target.minimalChangeModel(oldModel: oldTarget)
			} else {
				minModel = target
			}
			let updatedTarget = try await networkService.updateTargetAll(model: minModel)
            await refreshTargetsData()
            return updatedTarget
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
	/// Создает таргет
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
            guard let userExternalId = UserRepository.shared.userProfile?.externalId else {
                await ToastManager.shared.show(.baseError)
                return
            }
            let result = try await networkService.getUserTargets(externalId: userExternalId)
            
            if let targets = result.userTargets {
                withAnimation {
                    self.targets = targets.sorted { ($0.id ?? 0 < $1.id  ?? 1) }
                }
            }
        } catch {
            await ToastManager.shared.show(.baseError)
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
                
                findedTarget?.subTargets?[subTargetIndex].targetStatus?.changeSelf()
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
				findedTarget?.subTargets?[subTargetIndex].targetStatus?.changeSelf()
				
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
		
		guard
			let findedTarget,
			let oldModel = targets.first(where: {$0.id == findedTarget.id})
		else { return }
		let minimalModel = findedTarget.minimalChangeModel(oldModel: oldModel)
		
		Task { [weak self] in
			do {
				// Обновляем цель с новым статусом подцели и, возможно, цели
				let updatedTarget = try await self?.networkService.updateTargetAll(model: minimalModel)
				
				//                // Если выбрано НЕ закрывать цель полностью, добавляем новую подцель
				//                if !closeParent {
				//                    self?.addNewSubtarget(
				//                        to: findedTarget,
				//                        withName: "Завершить \(findedTarget.title ?? "цель")"
				//                    )
				//                } else {
				await self?.refreshTargetsData()
				//                }
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
    
	/// Закрывает цель
    func closedTarget(target: UserTargetDtoModel) {
        isLoading = true
        var tempTarget = target
        tempTarget.changeSelf()
        errorMessage = nil
        
        Task { [weak self] in
            do {
				let updatedTarget = try await self?.networkService.updateTargetAll(model: tempTarget.minimalChangeModel(oldModel: target))
                
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

