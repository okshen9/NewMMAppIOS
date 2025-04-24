import SwiftUI
import Combine

// MARK: - ViewModel
class TabBarViewModel: ObservableObject {
    private let service = ServiceBuilder.shared
    private let userRepository = UserRepository.shared
    
    @Published var user: UserProfileResultDto?
    
    // MARK: - Init
    init() {
        // Пытаемся загрузить из репозитория при инициализации
        self.user = userRepository.userProfile
        // Запускаем загрузку/обновление профиля в фоне
        fetchUserProfile()
    }

    struct Input {
        @State var title: String = Constants.title
    }

    // MARK: - Private properties
    private let apiFactory = APIFactory.global
    

    // MARK: - Public properties
    @Published private(set) var input = Input()

    // MARK: - Public Methods
    func fetchUserProfile() {
        // Проверяем, есть ли уже данные в репозитории
        if userRepository.userProfile != nil && self.user != nil {
            print("User profile already loaded from repository.")
            // Можно добавить логику обновления данных в фоне, если нужно, но для старта это не требуется
             // self.user = userRepository.userProfile // Убедимся что опубликовано актуальное значение
            return
        }
        
        print("Fetching user profile from network...")
        Task { [weak self] in
            guard let self = self else { return }
            do {
                let userProfile = try await self.service.getProfileMe()
                self.userRepository.setUserProfile(userProfile)
                // Обновляем @Published свойство на главном потоке
                await MainActor.run { 
                    self.user = userProfile
                    print("User profile fetched and updated.")
                }
            } catch {
                // Важно: Не блокируем UI, просто выводим ошибку
                print("Error fetching user profile: \(error.localizedDescription)")
                await ToastManager.shared.show(.init(message: "Не удалось загрузить профиль: \(error.localizedDescription)"))
            }
        }
    }

    // MARK: - Private Methods
}

// MARK: - Constants
extension TabBarViewModel {
    private enum Constants {
        static let title = "Выберите карту"
    }
}
