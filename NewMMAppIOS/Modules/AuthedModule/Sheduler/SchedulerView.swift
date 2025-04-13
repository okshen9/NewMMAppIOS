import SwiftUI

struct SchedulerView: View {
    @StateObject var viewModel = SchedulerViewModel()
    @State private var selectedDate: Date?
    @State private var hashebleDate: Int? = Date().hashValue
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    if viewModel.isLoading == false {
                        VStack(alignment: .leading) {
                            CalendarViewUIKit(selectedDate: $selectedDate, events: viewModel.calendarComponetsItems)
                                .tint(Color.red)
                                .frame(height: 450)
                                .padding(.horizontal, 24)
                                .padding(.top, 24)



                        }
                        .toolbar(content: {
                            Button("За все время", action: {
                                selectedDate = nil
                            })
                            .foregroundStyle(Color.mainRed)
                        })
                        if !viewModel.scheduleListItems.isEmpty {
                            eventList2()
                                .padding()
                            Spacer()
                        } else {
                            Spacer()
                            Text("У вас нет событий")
                                .font(.headline)
                                .foregroundColor(.headerText)
//                                .frame(width: .infinity, alignment: .center)
                            Spacer()
                        }
                    } else {
                        ShimmeringRectangle()
                            .frame(width: 350, height: 450)
                            .cornerRadius(44)
                        
                        ShimmeringRectangle()
                            .frame(width: 350, height: 50)
                            .cornerRadius(44)
                        
                        ShimmeringRectangle()
                            .frame(width: 350, height: 50)
                            .cornerRadius(44)
                        
                        ShimmeringRectangle()
                            .frame(width: 350, height: 50)
                            .cornerRadius(44)
                        Spacer()
                    }
                }
                
            }
            .navigationTitle(Text("Рассписание"))
            .scrollPosition(id: $hashebleDate, anchor: .top)
        }
        .onChange(of: selectedDate) { oldState, newState in
            print("change eventsCalendar: \(newState)")
            hashebleDate = newState.hashValue
        }
        .onAppear {
            viewModel.onApper()
        }
    }
    
    @ViewBuilder
    func getCell2(event: CalendatItem) -> some View {
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
        // Фильтруем события по выбранной дате (дню)
        let filteredEvents = viewModel.scheduleListItems.filter { selectedDate == nil || Calendar.current.isDate($0.key, inSameDayAs: selectedDate!) }

        
        
        if filteredEvents.isEmpty {
                Text("У вас нет событий запланированных на выбранную дату")
                    .font(.headline)
                    .foregroundColor(.headerText)
                    .padding(.horizontal, 16)
                Spacer()
        } else {
            //        ScrollView {
            LazyVStack {
                // Преобразуем отфильтрованный словарь в массив кортежей и сортируем по дате
                ForEach(filteredEvents.sorted(by: { $0.key < $1.key }), id: \.key) { date, events in
                    
                    Section(header: Text("События за \(date.toDisplayString):")
                        .foregroundColor(.headerText)
                        .font(.headline)) {
                            ForEach(events) { event in
                                EventRowView(event: event)
                            }
                        }
                        .id(date.hashValue)
                }
            }
            
            .listStyle(.grouped)
            //        }
            
            
            .scrollDisabled(false)
            .padding()
        }
        
        
    }
}

// MARK: - Constants
extension SchedulerView {
    private enum Constants {
        static let title = "Выберите карту"
    }
}

#Preview {
    SchedulerView(viewModel: SchedulerViewModel(
        payRequest: [
            PaymentRequestResponseDto(dueDate: Date().toApiString),
            PaymentRequestResponseDto(dueDate: Date.nowWith(plus: 1).toApiString),
            PaymentRequestResponseDto(dueDate: Date.nowWith(plus: 2).toApiString),
            PaymentRequestResponseDto(dueDate: Date.nowWith(plus: 3).toApiString)
        ],
        targets: [
            UserTargetDtoModel(deadLineDateTime: Date.nowWith(plus: 1).toApiString),
            UserTargetDtoModel(deadLineDateTime: Date.nowWith(plus: 2).toApiString),
            UserTargetDtoModel(deadLineDateTime: Date.nowWith(plus: 3).toApiString),
            UserTargetDtoModel(deadLineDateTime: Date.nowWith(plus: 4).toApiString),
            UserTargetDtoModel(deadLineDateTime: Date.nowWith(plus: 6).toApiString)
        ]
    )
    )
}

let markedDates: [Date: [UIColor]] = [
    Calendar.current.date(from: DateComponents(year: 2025, month: 2, day: 5))!: [.red],
    Calendar.current.date(from: DateComponents(year: 2025, month: 2, day: 3))!: [.blue, .green,
                                                                                 .blue, .orange,.yellow,.darkGray,.brown]
]

let markedDates2: [DateComponents: [UIColor]] = [
    DateComponents(year: 2025, month: 3, day: 5): [.red],
    DateComponents(year: 2025, month: 3, day: 3): [.blue, .green,
                                                                                 .blue, .orange,.yellow,.darkGray,.brown]
]
