import SwiftUI
import Combine

// MARK: - ViewModel
class TabBarViewModel: ObservableObject {
    private let service = ServiceBuilder.shared
    private let userRepository = UserRepository.shared
    
    @Published var user: UserProfileResultDto?
    
    struct Input {
        @State var title: String = Constants.title
    }

    // MARK: - Private properties
    private let apiFactory = APIFactory.global
    

    // MARK: - Public properties
    @Published private(set) var input = Input()

    // MARK: - Public Methods
    func fetchUserProfile() {
        Task { [weak self] in
            guard let userProfile = try? await self?.service.getProfileMe() else {
                return print("Error fetching user profile Neshko")
                
            }
            self?.userRepository.setUserProfile(userProfile)
            DispatchQueue.main.async { [weak self] in
                self?.user = userProfile
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
