import SwiftUI

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()

    var body: some View {
        VStack {
            Text("Новости и события")
                .font(.title)
            List {
                getCell(title: "Витяля закрыл цель", subtitle: "Полетел на самолете")
            }
            .cornerRadius(16)
            .background(Color.clear)
            .padding(.horizontal)
            
        }
        .padding(.top, 24)
        .frame(alignment: .leading)
        .background(Color.secondbackGraund)
        .cornerRadius(16)
    }
    
    @ViewBuilder
    func getCell(title: String, subtitle: String) -> some View {
        HStack {
            ZStack {
                Circle()
                    .frame(width: 44, height: 44)
                    .foregroundColor(Color.mainRed)
                Text("24\ndec")
                    
                    .multilineTextAlignment(.center)
                    .font(.caption)
                    .foregroundColor(.white)
            }
            VStack (alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.headerText)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.subtitleText)
            }
        }
    }
}

// MARK: - Constants
extension FeedView {
    private enum Constants {
        static let title = "Выберите карту"
    }
}

#Preview {
    FeedView()
}
