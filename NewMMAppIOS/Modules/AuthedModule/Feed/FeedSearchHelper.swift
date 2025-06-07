//
//  FeedSearchHelper.swift
//  NewMMAppIOS
//
//  Created by artem on 11.04.2025.
//

import Foundation

extension FeedViewModel {
    func getNextEvents(resetSearch: Bool, newEvents: [EventDTO]? = nil) async -> Bool {
        // Отменяем предыдущую задачу
        fetchTask?.cancel()
        
        fetchTask = Task {
            try await performFetchWithRetry(resetSearch: resetSearch, accumulatedEvents: newEvents ?? [])
        }
        
        do {
            try await fetchTask?.value
            return true
        } catch is CancellationError {
            return false
        } catch {
            print("FeedViewModel fetch failed: \(error)")
            return false
        }
    }
    
    /// Выполняет попытки загрузки с автоматической дозагрузкой скрытых событий
    private func performFetchWithRetry(resetSearch: Bool, accumulatedEvents: [EventDTO], maxRetries: Int = 10) async throws {
        var isPagination = false
        
        // Проверяем возможность запуска и устанавливаем флаги загрузки
        try await MainActor.run {
            if resetSearch {
                guard !self.isLoading && !self.paginatingLoading else {
                    print("FeedViewModel: Fetch already in progress, skipping reload")
                    throw CancellationError()
                }
                self.feedEvents = nil
                self.isLoading = true
            } else {
                isPagination = true
                guard !self.isLoading && !self.paginatingLoading else {
                    print("FeedViewModel: Fetch already in progress, skipping pagination")
                    throw CancellationError()
                }
                guard !self.isAll else {
                    print("FeedViewModel: All items loaded, skipping pagination")
                    throw CancellationError()
                }
                self.paginatingLoading = true
            }
        }
        
        do {
            var currentAccumulatedEvents = accumulatedEvents
            var retryCount = 0
            
            // Сбрасываем searchResponseDTO при полном обновлении
            if resetSearch {
                self.searchResponseDTO = nil
            }
            
            // Загружаем события с автоматической дозагрузкой
            while retryCount < maxRetries {
                try Task.checkCancellation()
                
                // Получаем параметры для запроса
                let searchParams = try await buildSearchParams(resetSearch: resetSearch  && retryCount == 0)
                
                // Выполняем запрос
                let searchResponse = try await service.searchEvents(searchParams: searchParams)
                try Task.checkCancellation()
                
                // Фильтруем скрытые события
                let visibleEvents = searchResponse.results?.filter { $0.hidden != true } ?? []
                currentAccumulatedEvents.append(contentsOf: visibleEvents)
                
                // Обновляем searchResponseDTO
                updateSearchResponse(searchResponse, isFirstRequest: resetSearch && retryCount == 0)
                
                print("FeedViewModel: загружено \(visibleEvents.count) видимых из \(searchResponse.results?.count ?? 0) событий, попытка \(retryCount + 1)")
                
                // Проверяем условия завершения
                let shouldFinish = shouldFinishLoading(
                    visibleEventsCount: currentAccumulatedEvents.count,
                    isAllFromServer: searchResponse.isAll,
                    retryCount: retryCount,
                    maxRetries: maxRetries
                )
                
                if shouldFinish {
                    // Обновляем UI и завершаем
                    await updateUIWithResults(
                        events: currentAccumulatedEvents,
                        isAllFromServer: searchResponse.isAll,
                        resetSearch: resetSearch
                    )
                    return
                }
                
                retryCount += 1
            }
            
            // Если достигли максимального количества попыток
            await updateUIWithResults(
                events: currentAccumulatedEvents,
                isAllFromServer: self.searchResponseDTO?.isAll ?? false,
                resetSearch: resetSearch
            )
            
        } catch is CancellationError {
            await MainActor.run {
                if isPagination {
                    self.paginatingLoading = false
                } else {
                    self.isLoading = false
                }
            }
            throw CancellationError()
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.paginatingLoading = false
                Task {
                    await ToastManager.shared.show(.baseError)
                }
            }
            throw error
        }
    }
    
    /// Строит параметры поиска
    private func buildSearchParams(resetSearch: Bool) async throws -> [EventsQuery.QueryValue] {
        var searchParams: [EventsQuery.QueryValue]
        
        if resetSearch {
            print("FeedViewModel3 resetSearch")
            searchParams = Constants.baseEventSearch
        } else {
            print("FeedViewModel3 resetSearch NO")
            // Дополнительная проверка isAll перед получением параметров пагинации
            if await MainActor.run { self.isAll } {
                throw CancellationError()
            }
            searchParams = getNextPaginationParams()
        }
        
        
        var searchParams2 = searchParams.filter {
            if case .pageNumberPagination = $0 {
                return true
            } else {
                return false
            }
        }
        print("FeedViewModel32 buildSearchParams: \(searchParams2)")
        
        enrichSearchParamsFromType(params: &searchParams)
        let searchParams3 = searchParams.filter {
            if case .pageNumberPagination = $0 {
                return true
            } else {
                return false
            }
        }
        print("FeedViewModel33 buildSearchParams: \(searchParams3)")
        return searchParams
    }
    
    /// Обновляет searchResponseDTO
    private func updateSearchResponse(_ response: SearchResponseDTO, isFirstRequest: Bool) {
        print("FeedViewModel3 pageNumber: \(response.pageNumber), isFirstRequest: \(isFirstRequest), self.searchResponseDTO?.pageNumber: \(self.searchResponseDTO?.pageNumber)")
        if isFirstRequest {
            self.searchResponseDTO = response
        } else {
            // Обновляем параметры пагинации, НЕ изменяем results
            self.searchResponseDTO?.pageNumber = response.pageNumber
            self.searchResponseDTO?.pageSize = response.pageSize
            self.searchResponseDTO?.totalPages = response.totalPages
            // НЕ добавляем results - они уже отфильтрованы и накоплены отдельно
        }
    }
    
    /// Определяет, нужно ли завершить загрузку
    private func shouldFinishLoading(
        visibleEventsCount: Int,
        isAllFromServer: Bool,
        retryCount: Int,
        maxRetries: Int
    ) -> Bool {
        // Завершаем, если:
        // 1. Достигли нужного количества событий (минимум 10 для первой загрузки, 1+ для пагинации)
        // 2. ИЛИ сервер сообщил, что данных больше нет
        // 3. ИЛИ достигли максимального количества попыток
        
        let targetEventCount = (self.feedEvents?.isEmpty ?? true) ? 10 : 1
        
        return visibleEventsCount >= targetEventCount ||
        isAllFromServer ||
        retryCount >= maxRetries - 1
    }
    
    /// Обновляет UI с результатами
    @MainActor
    private func updateUIWithResults(
        events: [EventDTO],
        isAllFromServer: Bool,
        resetSearch: Bool
    ) {
        // Обновляем состояние
        self.isAll = isAllFromServer
        
        // Обновляем события
        if resetSearch {
            self.feedEvents = events
        } else if !events.isEmpty {
            self.feedEvents?.append(contentsOf: events)
        }
        
        // Сбрасываем флаги загрузки
        self.isLoading = false
        self.paginatingLoading = false
        
        print("FeedViewModel: UI обновлен, всего событий: \(self.feedEvents?.count ?? 0), isAll: \(self.isAll)")
    }
    
    /// Получить базовые параметры поиска следующей страницы (пагинация, сортировка)
    private func getNextPaginationParams() -> [EventsQuery.QueryValue] {
        guard let nextPagination = searchResponseDTO?.nextPagination else {
            return Constants.baseEventSearch
        }
        print("FeedViewModel4 getNextPaginationParams: \(searchResponseDTO?.pageNumber)")
        var params = nextPagination.map {
            switch $0.key {
            case PaginationConstants.pageNumberKey:
                return EventsQuery.QueryValue.pageNumberPagination($0.value)
            case PaginationConstants.pageSizeKey:
                return EventsQuery.QueryValue.pageSizePagination($0.value)
            default:
                return nil
            }
        }.compactMap({$0})
        params.append(.sortDisplayDate())
        return params
    }
    
    /// Обогащяем параметры поиска типом эвентов
    private func enrichSearchParamsFromType(params: inout [EventsQuery.QueryValue]) {
        let selectedTypeKeys = selectedType.filter { $0.value }.map { $0.key }
        let params2 = params.filter {
            if case .pageNumberPagination = $0 {
                return true
            } else {
                return false
            }
        }
        
        print("FeedViewModel6 enrichSearchParamsFromType: \(params2)")
        
        if !selectedTypeKeys.isEmpty {
            params.append(.type(selectedTypeKeys))
        }
    }
}


