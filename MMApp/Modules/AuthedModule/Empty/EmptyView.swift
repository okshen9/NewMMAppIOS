import SwiftUI

struct EmptyView: View {
    @StateObject private var viewModel = EmptyViewModel()

    var body: some View {
        VStack {
            Text("Скоро будет контент")
                .foregroundColor(.mainRed)
        }
    }
}

// MARK: - Constants
extension EmptyView {
    private enum Constants {
        static let title = "Выберите карту"
    }
}

#Preview {
    EmptyView()
}
