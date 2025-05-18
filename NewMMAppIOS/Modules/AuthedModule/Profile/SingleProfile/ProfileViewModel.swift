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

	private var profileBaseEventSearch: [EventsQuery.QueryValue] = Constants.baseEventSearch
    var searchResponseDTO: SearchResponseDTO?
    @Published var selectedType: [EventType: Bool] = Dictionary(uniqueKeysWithValues: Constants.baseSelectedEventSearch.map { ($0, false) })


    var isMyProfile: Bool {
		externalId == userRepository.userProfile?.externalId
    }

    // MARK: - Private properties
    let serviceNetwork = ServiceBuilder.shared
    private let userRepository = UserRepository.shared
    private(set) var externalId: Int?

    init() {
        print("init ProfileViewModel() без параметров")
		let profileId = userRepository.externalId
        self.externalId = profileId
		self.initBaseSearch(profileId)
    }

    convenience init(externalId: Int? = nil) {
        self.init()
        print("init ProfileViewModel(externalId: \(externalId ?? -1))")
        if let externalId = externalId {
            self.externalId = externalId
			initBaseSearch(externalId)
        }
    }
    
    /// Only Debug
    convenience init(profile: UserProfileResultDto) {
        self.init()
        self.externalId = profile.externalId
        self.profile = profile
        self.groupedTargets = groupedTargets(profile)
		initBaseSearch(externalId)
    }
    
    deinit {
        print("deinit ProfileViewModel === externalId: \(externalId ?? -1)")
    }
	
	func initBaseSearch(_ profileId: Int?) {
		var baseEvent = Constants.baseEventSearch
		guard let profileId  else { return }
			baseEvent.append(.assigneeExternalIds([String(profileId)]))
		profileBaseEventSearch = baseEvent
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
            if profile == nil || externalId == nil || onReset {
				await updateProfile()
				await getNextEvents(resetSearch: onReset)
            }
        }
    }
    
    func updateProfile(externalId: Int? = nil) async {
        do {
            await setIsLoading(true)
            let targetExternalId = externalId ?? self.externalId
            print("updateProfile с externalId: \(targetExternalId ?? -1)")

            if let targetExternalId = targetExternalId {
                guard let updatetedProfile = try await serviceNetwork.getUserProfile(externalId: targetExternalId) else { 
                    print("Не удалось получить профиль с externalId: \(targetExternalId)")
                    await setIsLoading(false)
                    return 
                }
                print("Успешно получен профиль с externalId: \(targetExternalId)")
                await updateUI(profile: updatetedProfile)
            } else {
                guard let updatetedProfile = try await serviceNetwork.getProfileMe() else { 
                    print("Не удалось получить свой профиль")
                    await setIsLoading(false)
                    return 
                }
                print("Успешно получен свой профиль")
                await updateUI(profile: updatetedProfile)
            }
        } catch {
            await ToastManager.shared.show(.baseError)
            await updateUI(profile: nil)
            print("Ошибка updateProfile \(error) - Ошибка загрзуки профиля на странице профиля")
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
