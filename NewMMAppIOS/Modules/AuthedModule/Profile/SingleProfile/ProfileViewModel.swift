import SwiftUI
import Combine
import CoreLocation

enum Destination: Hashable {
    case userDetail(userId: Int)
    case goToUserTarget(userId: Int)
}

// MARK: - ViewModel
final class ProfileViewModel: ObservableObject, SubscriptionStore {
    @Published var navigationPath = ProfileViewModelPath.toMain

    @Published var isLoading = false
    @Published var isFeedLoading = false
    @Published var profile: UserProfileResultDto?


    @Published var groupedTargets: [TargetCategory: [UserTargetDtoModel]] = [:]

    @Published var feedEvents: [EventDTO]? = []
    @Published var paginatingLoading = false
    @Published var isAll = false


    var searchResponseDTO: SearchResponseDTO?
    @Published var selectedType: [EventType: Bool] = Dictionary(uniqueKeysWithValues: Constants.baseSelectedEventSearch.map { ($0, false) })


    var isMyProfile: Bool {
        profile == userRepository.userProfile
    }

    // MARK: - Private properties
    let serviceNetwork = ServiceBuilder.shared
    private let userRepository = UserRepository.shared
    private(set) var externalId: Int?

    init() {
        self.externalId = userRepository.externalId
    }

    convenience init(externalId: Int? = nil) {
        self.init()
        self.externalId = externalId

    }
    
    /// Only Debug
    convenience init(profile: UserProfileResultDto) {
        self.init()
        self.externalId = profile.externalId
        self.profile = profile
        self.groupedTargets = groupedTargets(profile)
    }

    func groupedTargets(_ profile: UserProfileResultDto?) -> [TargetCategory: [UserTargetDtoModel]] {
        let test = profile?.userTargets
            .flatMap({$0})
        .map { targets in
            Dictionary(grouping: targets, by: { $0.category ?? .unknown })
                .mapValues { $0.sorted { ($0.id ?? 0 < $1.id  ?? 1) }}
        }

        return test ?? [:]
    }


    // MARK: - Public Methods
    func onApper(onReset: Bool = false) {
        Task {
            if let profileDto = userRepository.userProfile, externalId == nil, !onReset {
                await updateUI(profile: profileDto)
            } else {
                await updateProfile()
                await getNextEvents(resetSearch: onReset)
            }
        }
    }
    
    func updateProfile(externalId: Int? = nil) async {
        do {
            await setIsLoading(true)
//            guard let updatetedProfile = try await serviceNetwork.getUserProfile(externalId: 10) else { return }
//            await updateUI(profile: updatetedProfile)

            if let externalId = self.externalId {
                guard let updatetedProfile = try await serviceNetwork.getUserProfile(externalId: externalId) else { return }
                await updateUI(profile: updatetedProfile)
            } else {
                guard let updatetedProfile = try await serviceNetwork.getProfileMe() else { return }
                await updateUI(profile: updatetedProfile)
            }
        } catch {
            await ToastManager.shared.show(.baseError)
            await updateUI(profile: nil)
            print("Neshko updateProfile \(error) - Ошибка загрзуки профиля на странице профиля")
        }
    }
    
    @MainActor
    func updateUI(profile: UserProfileResultDto?, isLoading: Bool = false) {
        self.profile = profile
        self.groupedTargets = groupedTargets(profile)
        self.isLoading = isLoading
    }

    @MainActor
    func updatefeed(events: [EventDTO]) {
        self.feedEvents = events
    }

    @MainActor
    func setIsLoading(_ isLoading: Bool) {
        self.isLoading = isLoading
    }

    @MainActor
    func setIsFeedLoading(_ setIsFeedLoading: Bool) {
        self.isFeedLoading = setIsFeedLoading
    }

    func openTelegramChat(username: String) {
        // Формируем ссылку для приложения Telegram
        let telegramURL = URL(string: "tg://resolve?domain=\(username)")!
        
        // Проверяем, установлен ли Telegram
        if UIApplication.shared.canOpenURL(telegramURL) {
            // Открываем Telegram
            UIApplication.shared.open(telegramURL, options: [:], completionHandler: nil)
        } else {
            // Если Telegram не установлен, открываем веб-версию
            let webURL = URL(string: "https://t.me/\(username)")!
            UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
        }
    }

    func logout() {
        userRepository.clearAll()
    }

    // MARK: - Navigation
//    func goToStream() {
//        navigationPath.append(Destination.userDetail(userId: 1))
//    }

//    func goToTarget() {
//        navigationPath.append(Destination.userDetail(userId: 1))
//    }


    @MainActor
    func setIsPaginationLoding(_ isPaginationLoding: Bool) {
        self.paginatingLoading = isPaginationLoding
    }
}

// MARK: - Constants
extension ProfileViewModel {
    enum Constants {
        static let title = "Выберите карту"

        static let baseEventSearch: [EventsQuery.QueryValue] = [
            .sortDisplayDate(.DESC),
            .pageNumberPagination("0"),
            .pageSizePagination("20")
        ]

        static let baseSelectedEventSearch: [EventType] = {
            var type = EventType.allPaymentType
//            type.append(.PAYMENT_FULL_PAID)
            return type
        }()
    }

    enum ProfileViewModelPath {
        case toMain
        case toTarget
        case toStream
        case toGroup
        case dismiss
    }
    
}
