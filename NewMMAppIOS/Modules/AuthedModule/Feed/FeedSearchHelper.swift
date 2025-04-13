//
//  FeedSearchHelper.swift
//  NewMMAppIOS
//
//  Created by artem on 11.04.2025.
//

import Foundation

extension FeedViewModel {
    func getNextEvents(resetSearch: Bool) async {
        do {
            guard !isLoading else { return }
            // Включает в себя пагинацию и сортровку в базовой версии
            var searchParams: [EventsQuery.QueryValue]
            // если поиск пустой или с нуля
            if feedEvents.isEmptyOrNil || resetSearch {
                await self.setIsLoading(true)

                await self.updateUI(events: nil, isLoading: true)
                self.searchResponseDTO = nil

                searchParams = Constants.baseEventSearch
            } else {
                await self.setIsPaginationLoding(true)
                searchParams = getNextPaginationParams()
            }

            // насыщение парметров типами поиска
            enrichSearchParamsFromType(params: &searchParams)
            let searchResponse = try await service.searchEvents(searchParams: searchParams)
            await updateCurrentEvents(with: searchResponse)
        } catch {
            await setIsPaginationLoding(false)
            await setIsLoading(false)
            await ToastManager.shared.show(.baseError)
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
        if !selectedType.isEmpty {
            params.append(EventsQuery.QueryValue.type(selectedType))
        }
    }

    /// Обновить текущие значения новыми эвентами
    private func updateCurrentEvents(with searchResponseDTO: SearchResponseDTO) async {
        let newEvents = (searchResponseDTO.results) ?? []
        self.searchResponseDTO?.results?.append(contentsOf: newEvents)
        self.searchResponseDTO?.pageNumber = searchResponseDTO.pageNumber
        self.searchResponseDTO?.pageSize = searchResponseDTO.pageSize
        self.searchResponseDTO?.totalRecords = searchResponseDTO.totalRecords

        await MainActor.run {
            self.feedEvents?.append(contentsOf: newEvents)
            self.isAll = searchResponseDTO.isAll
            // отменяем шимеры загрузки
        }
        await self.setIsLoading(false)
        await self.setIsPaginationLoding(false)
    }
}
