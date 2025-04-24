//
//  FeedSearchHelper.swift
//  NewMMAppIOS
//
//  Created by artem on 11.04.2025.
//

import Foundation

extension FeedViewModel {
    func getNextEvents(resetSearch: Bool) async {
        // Отменяем предыдущую задачу, если она есть
        fetchTask?.cancel()

        // Создаем новую задачу
        fetchTask = Task {
            var isPagination = false // Флаг для корректного сброса индикаторов в catch

            // Устанавливаем состояние загрузки на главном потоке
            // и проверяем возможность запуска
            try await MainActor.run {
                 if resetSearch {
                     // Предотвращаем запуск полного обновления, если любое обновление уже идет
                    guard !self.isLoading && !self.paginatingLoading else {
                         print("FeedViewModel: Fetch already in progress, skipping full reload start.")
                         throw CancellationError()
                    }
                    self.feedEvents = nil
                    self.isLoading = true
                 } else {
                    isPagination = true
                    // Предотвращаем запуск пагинации, если любое обновление уже идет или все загружено
                    guard !self.isLoading && !self.paginatingLoading else {
                         print("FeedViewModel: Fetch already in progress, skipping pagination start.")
                         throw CancellationError()
                    }
                    guard !self.isAll else {
                         print("FeedViewModel: All items already loaded, skipping pagination.")
                         throw CancellationError() // Не запускаем пагинацию, если все уже загружено
                    }
                    self.paginatingLoading = true
                 }
            }

            // --- Основная логика --- 
            do {
                if resetSearch {
                     self.searchResponseDTO = nil
                }

                var searchParams: [EventsQuery.QueryValue]
                // Безопасно читаем количество текущих событий
                let currentEventCount = await MainActor.run { self.feedEvents?.count ?? 0 }
                
                if currentEventCount == 0 || resetSearch {
                    searchParams = Constants.baseEventSearch
                } else {
                    // Используем DTO для параметров следующей страницы (как и раньше)
                   searchParams = getNextPaginationParams()
                   // Дополнительно проверяем isAll еще раз на всякий случай
                   if await self.isAll { throw CancellationError() }
                }
                enrichSearchParamsFromType(params: &searchParams)

                try Task.checkCancellation() // Проверяем отмену перед запросом
                let searchResponse = try await service.searchEvents(searchParams: searchParams)
                try Task.checkCancellation() // Проверяем отмену перед обновлением UI
                
                // --- Обновление состояния (при успехе) --- 
                let newEvents = (searchResponse.results) ?? []
                
                // Обновляем DTO и UI на главном потоке для потокобезопасности
                await MainActor.run { 
                     // Обновляем DTO
                     if resetSearch || self.searchResponseDTO == nil {
                         self.searchResponseDTO = searchResponse
                     } else {
                         // Убедимся, что не добавляем дубликаты (хотя сервер должен отдавать разные страницы)
                         // Просто добавляем новые
                         self.searchResponseDTO?.results?.append(contentsOf: newEvents)
                         self.searchResponseDTO?.pageNumber = searchResponse.pageNumber
                         self.searchResponseDTO?.pageSize = searchResponse.pageSize
                         self.searchResponseDTO?.totalRecords = searchResponse.totalRecords
                     }
                     
                     // Обновляем feedEvents
                     if resetSearch {
                         self.feedEvents = newEvents
                     } else if !newEvents.isEmpty {
                         // Добавляем только если есть новые события
                         self.feedEvents?.append(contentsOf: newEvents)
                     }
                     
                     // Обновляем флаг isAll
                     self.isAll = searchResponse.isAll
                     
                     // Сбрасываем флаги загрузки *после* всех обновлений
                     self.isLoading = false
                     self.paginatingLoading = false
                }
                // --- Конец обновления состояния ---

            } catch is CancellationError {
                print("FeedViewModel fetch task cancelled.")
                await MainActor.run {
                    // Корректно сбрасываем только нужный флаг
                    if isPagination {
                        self.paginatingLoading = false
                    } else {
                        self.isLoading = false
                    }
                    // Важно: Не сбрасываем другой флаг, если он был активен
                    // Например, если отменили пагинацию во время isLoading=true
                }
            } catch {
                // Обрабатываем другие ошибки
                 print("FeedViewModel fetch task failed: \(error)")
                 await MainActor.run {
                    self.isLoading = false
                    self.paginatingLoading = false
                    // Показываем тост с ошибкой
                    Task { // Запускаем отдельную задачу для тоста
                       await ToastManager.shared.show(.init(message: error.localizedDescription))
                    }
                 }
            }
            // --- Конец основной логики ---
        }
    }

    /// Получить базовые параметры поиска следующей страницы (пагинация, сортировка)
    private func getNextPaginationParams() -> [EventsQuery.QueryValue] {
        guard let nextPagination = searchResponseDTO?.nextPagination else {
            return Constants.baseEventSearch
        }
        var params = nextPagination.map {
            switch $0.key {
            case PaginationConstants.pageNumberKey:
                return EventsQuery.QueryValue.pageNumberPagination($0.value)
            case PaginationConstants.pageSizeKey:
                return EventsQuery.QueryValue.pageNumberPagination($0.value)
            default:
                return EventsQuery.QueryValue.pageNumberPagination($0.value)
            }
        }
        params.append(.sortDisplayDate())
        return params
    }

    /// Обгощяем параметры поиска типом эвентов
    private func enrichSearchParamsFromType(params: inout [EventsQuery.QueryValue]) {
        let selectedType = Array(selectedType.filter({$1}).keys)
        if !selectedType.isEmpty {
            params.append(EventsQuery.QueryValue.type(selectedType))
        }
    }
}
