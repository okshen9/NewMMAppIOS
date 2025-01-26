import SwiftUI
import Combine

// MARK: - ViewModel
class EmptyViewModel: ObservableObject {
    struct Input {
        @State var title: String = Constants.title
    }

    // MARK: - Private properties
    private let apiFactory = APIFactory.global
    

    // MARK: - Public properties
    @Published private(set) var input = Input()

    // MARK: - Public Methods
    func updateTitle() {
        input.title = "Updated Title"
    }

    // MARK: - Private Methods
}

// MARK: - Constants
extension EmptyViewModel {
    private enum Constants {
        static let title = "Выберите карту"
    }
}
