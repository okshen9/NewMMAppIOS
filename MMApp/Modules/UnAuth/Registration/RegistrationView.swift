import SwiftUI

struct RegistrationViewView: View {
    @StateObject private var viewModel = RegistrationViewModel()

    var body: some View {
        VStack {
            Text(viewModel.input.title)
            Button("Update") {
                viewModel.updateTitle()
            }
        }
    }
}

// MARK: - Constants
extension RegistrationViewView {
    private enum Constants {
        static let title = "Выберите карту"
    }
}

#Preview {
    RegistrationViewView()
}
