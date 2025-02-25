import SwiftUI

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    @State var selectedDate: Date?
    


    var body: some View {
        
            NavigationView {
                ScrollView {
                VStack {
                    if !viewModel.payRequest.isEmptyOrNil && !viewModel.targets.isEmptyOrNil {
                        VStack(alignment: .leading) {
                            CalendarViewUIKit(selectedDate: $selectedDate, events: markedDates) //$viewModel.eventsCalendar)
                                .tint(Color.red)
                                .frame(height: 450)
                            .padding(.horizontal, 24)
                            .padding(.top, 24)
                            eventList2()
                                .padding()
                            Spacer()
                            
                        }
                        .navigationTitle(Text("Рассписание"))
                    }
                    
                    else {
                        ShimmeringRectangle()
                            .frame(width: 88, height: 88)
                            .cornerRadius(44)
                        Spacer()
                    }
                    //        .padding(.top, 24)
                    //        .frame(alignment: .leading)
                    //        .background(Color.secondbackGraund)
                    //        .cornerRadius(16)
                }
            }
        }
        .onChange(of: viewModel.eventsCalendar) {
            print("change eventsCalendar: \($0)")
            
        }
        .onAppear {
            viewModel.onApper()
        }
        
    }
    
    @ViewBuilder
    func getCell2(event: EventMM) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                Text(event.type.name)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Circle()
                .fill(Color(event.type.color))
                .frame(width: 10, height: 10)
        }
        .padding(.vertical, 8)
    }
    
    
    @ViewBuilder
    private func eventList2() -> some View {
        // Фильтруем события по выбранной дате
        let filteredEvents = viewModel.events.filter { selectedDate == nil || Calendar.current.isDate($0.key, inSameDayAs: selectedDate!) }

        LazyVStack {
            // Преобразуем отфильтрованный словарь в массив кортежей и сортируем по дате
            ForEach(filteredEvents.sorted(by: { $0.key < $1.key }), id: \.key) { date, events in
                Section(header:
                            Text("События за \(date.toDisplayString):")
                    .foregroundColor(.headerText)
                    .font(.headline)
                ) {
                    ForEach(events) { event in
                        EventRowView(event: event)
                    }
                }
            }
        }
        .listStyle(.grouped)
        .padding()
        
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
