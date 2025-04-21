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
    @Published var paginatingLoading = false
    @Published var isAll = false


    @Published var feedEvents: [EventDTO]?
    @Published var currentEventSearch: [EventsQuery.QueryValue] = Constants.baseEventSearch
    @Published var selectedType: [EventType: Bool] = Dictionary(uniqueKeysWithValues: Constants.baseSelectedEventSearch.map { ($0, false) })

    var searchResponseDTO: SearchResponseDTO?
    let service = ServiceBuilder.shared
    let userRepository = UserRepository.shared

    init() {
        print("init FeedViewModel")
    }

    deinit {
        print("deinit FeedViewModel")
    }


    // MARK: - Public Methods
    func onApper() {
        Task {
            if let feedEvents = feedEvents,
               !feedEvents.isEmpty {
                return
            } else {
                await getNextEvents(resetSearch: true)
            }
        }
    }
    
    @MainActor
    func updateUI(events: [EventDTO]?, isLoading: Bool = false) {
        self.feedEvents = events ?? []
        self.isLoading = isLoading
    }
    
    @MainActor
    func setIsLoading(_ isLoading: Bool) {
        self.isLoading = isLoading
    }
    @MainActor
    func setIsPaginationLoding(_ isPaginationLoding: Bool) {
        self.paginatingLoading = isPaginationLoding
    }
}


extension FeedViewModel {
    enum Constants {
        static let baseEventSearch: [EventsQuery.QueryValue] = [
            .sortDisplayDate(.DESC),
            .pageNumberPagination("0"),
            .pageSizePagination("10")
        ]

        static let baseSelectedEventSearch: [EventType] = {
            var type = EventType.allTargetsType
//            type.append(.PAYMENT_FULL_PAID)
            return type
        }()
    }
}
