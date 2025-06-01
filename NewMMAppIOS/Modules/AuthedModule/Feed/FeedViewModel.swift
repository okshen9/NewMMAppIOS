//
//  FeedViewModel.swift
//  MMApp
//
//  Created by artem on 13.03.2025.
//

import Foundation
import Combine
import SwiftUI

// MARK: - Navigation Routes
enum NavigationRoute: Hashable {
    case profile(Int)
    // Здесь можно добавить другие маршруты навигации в будущем
}

protocol FeedViewModelProtocol: ObservableObject {
    func onApper()
    var isLoading: Bool { get set }
    var feedEvents: [EventDTO]? { get set }
    var navigationPath: NavigationPath { get set }
    func navigateToProfile(withId externalId: Int)
}

// MARK: - ViewModel
final class FeedViewModel: ObservableObject, FeedViewModelProtocol {
    @Published var isLoading = false
    @Published var paginatingLoading = false
    @Published var isAll = false
    @Published var navigationPath = NavigationPath()

    @Published var feedEvents: [EventDTO]?
    @Published var currentEventSearch: [EventsQuery.QueryValue] = Constants.baseEventSearch
    @Published var selectedType: [EventType: Bool] = Dictionary(uniqueKeysWithValues: Constants.baseSelectedEventSearch.map { ($0, true) })

    var searchResponseDTO: SearchResponseDTO?
    let service = ServiceBuilder.shared
    private let userRepository = UserRepository.shared
    
    var fetchTask: Task<Void, Error>?

    init() {
        print("init FeedViewModel")
    }

    deinit {
        print("deinit FeedViewModel")
    }

    // MARK: - Navigation Methods
    func navigateToProfile(withId externalId: Int) {
        print("FeedViewModel: Добавляю профиль с ID \(externalId) в навигационный путь")
        navigationPath.append(NavigationRoute.profile(externalId))
    }

    // MARK: - Public Methods
    func onApper() {
        if feedEvents == nil && !isLoading && !paginatingLoading {
            Task {
                let _ = await getNextEvents(resetSearch: true)
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
    
    /// Скрыть неподходящие эвенты
    /// - Parameter externalId: id которые надо добавить к скрытию
    func hideEvent(externalId: Int) async -> Bool {
        do {
            guard var userProfile = userRepository.userProfile else {
                throw NSError(domain: "SendReportError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid type"])
            }
            var newForUserHideThisExtIdUsersEvents = Set((userProfile.forUserHideThisExtIdUsersEvents) ?? [])
            newForUserHideThisExtIdUsersEvents.insert(externalId)
            userProfile.forUserHideThisExtIdUsersEvents = Array(newForUserHideThisExtIdUsersEvents)
            let edit = EditProfileBodyDTO(userProfile)
            let newUser = try await service.patchMe(profileData: edit)
            userRepository.setUserProfile(newUser)
            return true
        }
        catch {
            await ToastManager.shared.show(.baseError)
            return false
        }
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
