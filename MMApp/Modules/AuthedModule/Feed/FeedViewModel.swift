//
//  FeedViewModel.swift
//  MMApp
//
//  Created by artem on 13.03.2025.
//

import Foundation
import Combine
import SwiftUI

// MARK: - ViewModel
final class FeedViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var myUpcomingEvent: UpcomingEvent?
    @Published var feedEvents: [EventDTO]?
    
    
    private var searchResponseDTO: SearchResponseDTO?
    private let service = ServiceBuilder.shared
    private let userRepository = UserRepository.shared
    
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
            
            
//            let searchEnets: [EventsQuery.QueryValue] = [.type([.targetDone, .targetExpired, .targetExpiredDone])]
//            let externalId = userRepository.externalId ?? -1
//            
//            let events = try await service.searchEvents(searchParams: searchEnets)
//            guard let targets = try await service.getUserTargets(externalId: externalId).userTargets,
//                  let paymant = try await service.getPaymentPlan(id: externalId)
//            else { return }
//            let models = try await fetchInitData()
//            let firstPayment = models.payment?
//                .sorted(by: {($0.dueDate?.dateFromString).orNow < ($1.dueDate?.dateFromString).orNow.dayAfter})
//                .first(where: { ($0.dueDate?.dateFromString ?? Date()).toDay >= Date()})
//            let firstTask = models.targets?
//                .sorted(by: {($0.deadLineDateTime?.dateFromString).orNow < ($1.deadLineDateTime?.dateFromString).orNow.dayAfter})
//                .first(where: { ($0.deadLineDateTime?.dateFromString ?? Date()).dayBefore >= Date()})
//            
//            let firstSubTask = models.targets?
//                .compactMap{$0}
//                .flatMap({$0.subTargets ?? []})
//                .sorted(by: {($0.deadLineDateTime?.dateFromString).orNow < ($1.deadLineDateTime?.dateFromString).orNow.dayAfter})
//                .first(where: { ($0.deadLineDateTime?.dateFromString ?? Date()).dayBefore >= Date()})
            
//            let myUpcomingEventTmp = min(of: firstPayment.?.dueDate?.dateFromString ?? Date(), firstTask, firstSubTask)
            
            let searchEnets: [EventsQuery.QueryValue] = [.type([.targetDone, .targetExpired, .targetExpiredDone])]
            let events = try await service.searchEvents(searchParams: [])//(searchParams: searchEnets)
            
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
    private func getEvnts() async {
//        SearchResponseDTO
        do {
            let searchResponseDTO = try await service.searchEvents(searchParams: [.type([.targetDone, .targetExpiredDone, .targetExpired])])
        } catch {
            print("Neshko searchEvents error")
        }
    }
    
    
    private func fetchInitData() async throws -> (events: [EventDTO]?, targets: [UserTargetDtoModel]?, payment: [PaymentRequestResponseDto]?) {
        let searchEnets: [EventsQuery.QueryValue] = [.type([.targetDone, .targetExpired, .targetExpiredDone])]
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


//    private func generateDisplayEventModel(from eventModel: [EventDTO]) -> EventDisplayModel {
//        isLoading = true
//        eventModel.map({ event in
//            Task{
//                do {
//                    if let targetIdStr = event.assigneeExternalIds?.first,
//                       let targetId = Int(targetIdStr) {
////                        let target = await try service.getTarget(targetId: targetId)
////                        let user  =
//                    }
//
//
//                }
//                catch {
//
//                }
//            }
//        })
//    }
}


extension FeedViewModel {
    enum Constants {
        static let targetEventType = ["TARGER_EXPIRED", "TARGER_EXPIRED_DONE", "TARGER_DONE"]
    }
}
