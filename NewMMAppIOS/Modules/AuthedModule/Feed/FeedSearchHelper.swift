//
//  FeedSearchHelper.swift
//  NewMMAppIOS
//
//  Created by artem on 11.04.2025.
//

import Foundation

extension FeedViewModel {
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
}
