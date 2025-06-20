//
//  UserGroupsListViewModel.swift
//  NewMMAppIOS
//
//  Created by artem on 05.06.25.
//

import Foundation
import Combine
import SwiftUI

/**
 * UserGroupsListViewModel - ViewModel для отображения списка групп и стримов пользователя
 * 
 * Функциональность:
 * - Получает базовую информацию о группах из профиля пользователя
 * - Загружает детальную информацию о каждой группе через API getGroup
 * - Отображает группы и стримы в отдельных категориях  
 * - Поддерживает параллельную загрузку данных
 * - Обрабатывает ошибки и использует fallback данные
 * - Поддерживает pull-to-refresh для обновления
 */
final class UserGroupsListViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var isLoadedDetails = false
    
    // @Published свойства для UI обновлений
    @Published var groups: [GroupResultDTOModel] = []
    @Published var streams: [GroupResultDTOModel] = []
    
    private let serviceNetwork = ServiceBuilder.shared
    private var initialGroups: [GroupResultDTOModel] = []
    
    init(userGroups: [GroupResultDTOModel]) {
        self.initialGroups = userGroups
    }
    
    func onAppear() {
        Task {
            await loadDetailedGroupsInfo()
        }
    }
    
    /// Обновляет детальную информацию о группах (для pull-to-refresh)
    func refreshGroups() async {
        await loadDetailedGroupsInfo()
    }
    
    @MainActor
    private func setIsLoading(_ isLoading: Bool) {
        self.isLoading = isLoading
    }
    
    @MainActor
    private func setIsLoadedDetails(_ isLoadingDetails: Bool) {
        self.isLoadedDetails = isLoadingDetails
    }
    
    @MainActor
    private func updateDetailedGroups(groups: [GroupResultDTOModel], streams: [GroupResultDTOModel]) {
        self.groups = groups
        self.streams = streams
    }
    
    /// Загружает детальную информацию о всех группах
    private func loadDetailedGroupsInfo() async {
        guard !initialGroups.isEmpty else {
            print("UserGroupsListViewModel: Нет групп для загрузки")
            return
        }

        print("UserGroupsListViewModel: Начинаем загрузку детальной информации для \(initialGroups.count) групп")
        await setIsLoading(true)
        
        // Если важен порядок – заведём "плейсхолдер" под каждый элемент:
        var groupList = [GroupResultDTOModel]()

        // Запускаем параллельно задачи с передачей индекса
        await withTaskGroup(of: GroupResultDTOModel?.self) { taskGroup in
            for userGroup in initialGroups {
                guard let id = userGroup.id else {
                    print("UserGroupsListViewModel: пропускаем группу без id")
                    continue
                }
                taskGroup.addTask { [weak self] in
                    guard let self = self else {
                        return nil
                    }
                    // Если loadSingleGroupDetail бросает – обернём в try?
                    let detail = await self.loadSingleGroupDetail(groupId: id)
                    return detail
                }
            }

            for await maybeDetail in taskGroup {
                if let detail = maybeDetail {
                    groupList.append(detail)
                } else {
                    print("UserGroupsListViewModel: Не удалось загрузить подробности для одной из групп")
                }
            }
        }

        // Оставляем только те, что не nil
        let detailedGroupsList = groupList.compactMap { $0 }

        // Фильтрация по типу. Предположим, что usersGroupType – это String?:
        let groups = detailedGroupsList.filter { $0.usersGroupType == .group }
        let streams = detailedGroupsList.filter { $0.usersGroupType == .stream }

        await updateDetailedGroups(groups: groups, streams: streams)
        await setIsLoading(false)
        await setIsLoadedDetails(true)
        print("Загрузли \(detailedGroupsList.count) групп")
    }
    
    /// Загружает детальную информацию об одной группе
    private func loadSingleGroupDetail(groupId: Int?) async -> GroupResultDTOModel? {
        guard let groupId = groupId else {
            print("UserGroupsListViewModel: Отсутствует ID группы")
            return nil
        }
        
        do {
            print("UserGroupsListViewModel: Загружаем детали для группы с id: \(groupId)")
            let detailedGroup = try await serviceNetwork.getGroup(idGroup: groupId)
            print("UserGroupsListViewModel: Успешно загружена группа '\(detailedGroup.title ?? "Без названия")'")
            return detailedGroup
        } catch {
            print("UserGroupsListViewModel: Ошибка загрузки группы \(groupId) - \(error.localizedDescription)")
            // Возвращаем исходную группу, если не удалось загрузить детали
            let fallbackGroup = initialGroups.first { $0.id == groupId }
            if fallbackGroup != nil {
                print("UserGroupsListViewModel: Используем резервные данные для группы \(groupId)")
            }
            return fallbackGroup
        }
    }
} 
