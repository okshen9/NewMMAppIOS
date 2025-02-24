import SwiftUI

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    @State var selectedDate: Date = Date()
    


    var body: some View {
        VStack {
            CalendarViewUIKit(selectedDate: $selectedDate, events: markedDates)
                .tint(Color.red)
                .frame(height: 400)
            Text("Выбранная дата: \(selectedDate.formatted(.dateTime.day().month().year()))")
            Spacer()
            
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

let markedDates: [Date: [UIColor]] = [
    Calendar.current.date(from: DateComponents(year: 2025, month: 2, day: 5))!: [.red],
    Calendar.current.date(from: DateComponents(year: 2025, month: 2, day: 3))!: [.blue, .green,
                                                                                 .blue, .orange,.yellow,.darkGray,.brown]
]
