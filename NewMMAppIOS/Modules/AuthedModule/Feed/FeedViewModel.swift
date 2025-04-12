//
//  FeedViewModel.swift
//  MMApp
//
//  Created by artem on 13.03.2025.
//

import Foundation
import Combine
import SwiftUI

protocol FeedViewModelProtocol: ObservableObject {
    func onApper()
    var isLoading: Bool { get set }
    var feedEvents: [EventDTO]? { get set }
}

// MARK: - ViewModel
final class FeedViewModel: ObservableObject, FeedViewModelProtocol {
    @Published var isLoading = false
    @Published var myUpcomingEvent: UpcomingEvent?
    @Published var feedEvents: [EventDTO]?
    @Published var selectetTypeEvent: [EventType] = []//[.TARGET_DONE, .TARGET_EXPIRED, .TARGET_DONE_EXPIRED]

    var searchResponseDTO: SearchResponseDTO?
    let service = ServiceBuilder.shared
    let userRepository = UserRepository.shared
    var pagination = Pagination()

    // MARK: - Public Methods
    func onApper() {
        Task {
//            if let profileDto = userRepository.userProfile {
//                await updateUI(profile: profileDto)
//            } else {
                await updateFeed()
//            }
        }
    }
    
    func updateFeed() async {
        do {
            await setIsLoading(true)
            
            let searchEnets: [EventsQuery.QueryValue] = [.type([.TARGET_DONE, .TARGET_EXPIRED, .TARGET_DONE_EXPIRED])]
            let events = try await service.searchEvents(searchParams: searchEnets)//(searchParams: searchEnets)

            await updateUI(events: events.results, myUpcomingEvent: nil)
        } catch {
            print("Neshko Feed \(error) - Ошибка загрзуки ")
        }
    }
    
    @MainActor
    private func updateUI(events: [EventDTO]?, myUpcomingEvent: UpcomingEvent?, isLoading: Bool = false) {
        self.feedEvents = events ?? []
        self.isLoading = isLoading
    }
    
    @MainActor
    private func setIsLoading(_ isLoading: Bool) {
        self.isLoading = isLoading
    }
    
    // MARK: - Private methods
    private func getNextEvnts() async {
//        SearchResponseDTO
        do {
            let searchResponseDTO = try await service.searchEvents(searchParams: [.type([.TARGET_DONE, .TARGET_EXPIRED, .TARGET_DONE_EXPIRED])])
        } catch {
            print("Neshko searchEvents error")
        }
    }
    
    
    private func fetchInitData() async throws -> (events: [EventDTO]?, targets: [UserTargetDtoModel]?, payment: [PaymentRequestResponseDto]?) {
        let searchEnets: [EventsQuery.QueryValue] = [.type([.TARGET_DONE, .TARGET_EXPIRED, .TARGET_DONE_EXPIRED])]
        let externalId = userRepository.externalId ?? -1
        
        return try await withThrowingTaskGroup(of: (String, Any).self) { [weak self] group in
            // Запускаем все запросы параллельно
            group.addTask { [weak self] in
                let events = try await self?.service.searchEvents(searchParams: searchEnets)
                return ("events", events)
            }
            
            group.addTask { [weak self] in
                let targets = try await self?.service.getUserTargets(externalId: externalId).userTargets
                return ("targets", targets as Any)
            }
            
            group.addTask { [weak self] in
                let payment = try await self?.service.getPaymentPlan(id: externalId)
                return ("payment", payment as Any)
            }

            // Собираем результаты
            var events: [EventDTO]?
            var targets: [UserTargetDtoModel]?
            var payment: [PaymentRequestResponseDto]?

            for try await (key, value) in group {
                switch key {
                case "events":
                    events = value as? [EventDTO]
                case "targets":
                    targets = value as? [UserTargetDtoModel]
                case "payment":
                    payment = value as? [PaymentRequestResponseDto]
                default:
                    break
                }
            }

            // Проверяем, что все данные получены
            guard let events = events,
                  let targets = targets,
                  let payment = payment else {
                throw NSError(domain: "DataError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch all data"])
            }

            return (events, targets, payment)
        }
    }

    func configureCurrentEventParams(reset: Bool) {
//        self.pagination
        var params: [String: String] = [:]
        params.merge(pagination.nextPagination, uniquingKeysWith: {(_, new) in new})
        params[Constants.sort_creationDateTime] = Constants.sort_DEC
    }

    struct Pagination {
        init(_ serachEvents: SearchResponseDTO? = nil) {
            totalRecords = serachEvents?.totalRecords ?? 0
            pageNumber = serachEvents?.pageNumber ?? -1
            pageSize = serachEvents?.pageSize ?? 20
        }
        var totalRecords: Int
        var pageNumber: Int
        var pageSize: Int

        var nextPagination: [String: String] {
            [
                "pageNumber": String(pageNumber + 1),
                "pageSize": String(pageSize)
            ]
        }

        var isAll: Bool {
            totalRecords <= pageSize * (pageNumber + 1)
        }
    }
}


extension FeedViewModel {
    enum Constants {
        static let targetEventType = ["TARGER_EXPIRED", "TARGER_EXPIRED_DONE", "TARGER_DONE"]
        static let sort_creationDateTime = "sort_creationDateTime"
        // по уменбшению
        static let sort_DEC = "DEC"
    }
}
