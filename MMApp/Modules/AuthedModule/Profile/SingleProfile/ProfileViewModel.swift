import SwiftUI
import Combine
import CoreLocation

enum Destination: Hashable {
    case userDetail(userId: Int)
}

// MARK: - ViewModel
final class ProfileViewModel: ObservableObject {
    @Published var navigationPath = NavigationPath()
    
    @Published var isLoading = false
    @Published var profile: UserProfileResultDto?
    
    // MARK: - Private properties
    private let serviceNetwork = ServiceBuilder()
    private let userRepository = UserRepository.shared
    private let externalId: Int?

    init(externalId: Int? = nil) {
        self.externalId = externalId
    }
    
    /// Only Debug
    convenience init(profile: UserProfileResultDto) {
        self.init()
        self.profile = profile
    }
    
    // MARK: - Public properties
//    @Published private(set) var input = Input()

    // MARK: - Public Methods
    func onApper() {
        Task {
            if let profileDto = userRepository.userProfile, externalId == nil {
                await updateUI(profile: profileDto)
            } else {
                await updateProfile()
            }
        }
    }
    
    func updateProfile(externalId: Int? = nil) async {
        do {
            await setIsLoading(true)
            if let externalId = self.externalId {
                guard let updatetedProfile = try await serviceNetwork.getUserProfile(externalId: externalId) else { return }
                await updateUI(profile: updatetedProfile)
            } else {
                guard let updatetedProfile = try await serviceNetwork.getProfileMe() else { return }
                await updateUI(profile: updatetedProfile)
            }
        } catch {
            print("Neshko updateProfile \(error) - Ошибка загрзуки профиля на странице профиля")
        }
    }
    
    @MainActor
    private func updateUI(profile: UserProfileResultDto?, isLoading: Bool = false) {
        self.profile = profile
        self.isLoading = isLoading
    }
    
    @MainActor
    private func setIsLoading(_ isLoading: Bool) {
        self.isLoading = isLoading
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
    
    // MARK: - Navigation
    func goToStream() {
        navigationPath.append(Destination.userDetail(userId: 1))
    }
}

// MARK: - Constants
extension ProfileViewModel {
    private enum Constants {
        static let title = "Выберите карту"
    }
}
