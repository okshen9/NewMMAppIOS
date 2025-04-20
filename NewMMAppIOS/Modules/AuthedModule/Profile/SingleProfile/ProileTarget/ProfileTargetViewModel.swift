//
//  ProfileTargetViewModel.swift
//  NewMMAppIOS
//
//  Created by artem on 20.04.2025.
//

import Foundation
import Combine
import SwiftUI

// MARK: - ViewModel
final class ProfileTargetViewModel: ObservableObject {
    private let serviceNetwork = ServiceBuilder.shared

    private let externalId: Int
    @Published var isLoading = true
    // Сгруппированные цели: ключ — категория, значение — массив целей
    @Published private(set) var targetsByCategory: [TargetCategory: [UserTargetDtoModel]] = [:]
    // Отдельный упорядоченный список категорий для последовательного отображения
    @Published private(set) var categories: [TargetCategory] = []


    init(externalId: Int) {
        self.externalId = externalId
    }

    // MARK: - Public Methods
    func onApper() {
        Task {
            await fetchTargets(externalId: externalId)
        }
    }
    
    /// Асинхронный метод получения целей и группировки их по категориям
    @MainActor
    func fetchTargets(externalId: Int) async {
        do {
            isLoading = true
            let userTargetsList = try await serviceNetwork.getUserTargets(externalId: externalId)
            let allTargets = userTargetsList.userTargets ?? []
            // Отфильтровать удалённые цели
            let activeTargets = allTargets.filter { target in
                !(target.isDeleted ?? false)
            }
            // Сгруппировать по категории (если категория отсутствует — назначить .money по умолчанию)
            let grouped = Dictionary(grouping: activeTargets) { target in
                target.category ?? .money
            }
            // Обновить published свойства
            self.targetsByCategory = grouped
            // Отсортировать категории по сырому значению или по пользовательскому порядку
            self.categories = grouped.keys.sorted(by: { $0.rawValue < $1.rawValue })
            isLoading = false
        } catch {
            // Обработать ошибку (например, логирование или показать Alert)
            print("Error fetching targets: \(error)")
        }
    }
}
