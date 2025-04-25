import SwiftUI

struct SchedulerView: View {
    @StateObject var viewModel = SchedulerViewModel()
    @State private var selectedDate: Date?
    @State private var hashebleDate: Int? = Date().hashValue
    @State private var isDateSelected = false
    
    // Категории для карусели
    private let categories: [TargetCategory] = [
        .money,
        .personal,
        .family,
        .health,
        .other
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    if viewModel.isLoading == false {
                        VStack(alignment: .leading) {
                            // Календарь с возможностью снятия выбора
                            ZStack {
                                CalendarViewUIKit(
                                    selectedDate: $selectedDate, 
                                    events: viewModel.calendarComponetsItems,
                                    canDeselectSameDate: true
                                )
                                    .tint(Color.red)
                                    .frame(height: 450)
                                    .padding(.horizontal, 24)
                                    .padding(.top, 24)
                            }
                            
                            // Легенда категорий
                            VStack(alignment: .leading, spacing: 18) {
                                // Типы событий и категории в одном блоке
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("События и категории")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                        .padding(.horizontal, 24)
                                    
                                    // Типы событий - компактно в одной строке
                                    HStack(spacing: 16) {
                                        HStack(spacing: 8) {
                                            Circle()
                                                .foregroundStyle(.green)
                                                .frame(width: 12, height: 12)
                                            Text("Цели")
                                                .font(.subheadline)
                                        }
                                        
                                        HStack(spacing: 8) {
                                            Circle()
                                                .foregroundStyle(Color.mainRed)
                                                .frame(width: 12, height: 12)
                                            Text("Платежи")
                                                .font(.subheadline)
                                        }
                                    }
                                    .padding(.horizontal, 24)
                                }
                                
                                // Категории целей
//                                if !viewModel.scheduleListItems.isEmpty {
//                                    ScrollView(.horizontal, showsIndicators: false) {
//                                        HStack(spacing: 8) {
//                                            ForEach(categories, id: \.self) { category in
//                                                Button(action: {
//                                                    // Здесь можно добавить действие для фильтрации по категории
//                                                }) {
//                                                    HStack(spacing: 6) {
//                                                        Circle()
//                                                            .fill(category.color)
//                                                            .frame(width: 10, height: 10)
//                                                        Text(category.rawValue)
//                                                            .font(.footnote)
//                                                            .foregroundColor(.primary)
//                                                    }
//                                                    .padding(.vertical, 8)
//                                                    .padding(.horizontal, 12)
//                                                    .background(
//                                                        RoundedRectangle(cornerRadius: 16)
//                                                            .fill(Color(UIColor.secondarySystemBackground))
//                                                    )
//                                                }
//                                                .buttonStyle(PlainButtonStyle())
//                                            }
//                                        }
//                                        .padding(.horizontal, 24)
//                                    }
//                                    .padding(.top, 4)
//                                }
                            }
                            .padding(.vertical, 12)
                        }
//                        .toolbar(content: {
//                            Button(action: {
//                                withAnimation {
//                                    selectedDate = nil
//                                    isDateSelected = false
//                                }
//                            }) {
//                                HStack(spacing: 4) {
//                                    Image(systemName: "calendar")
//                                    Text("Все события")
//                                }
//                                .foregroundStyle(Color.mainRed)
//                            }
//                            .opacity(selectedDate == nil ? 0.5 : 1)
//                            .disabled(selectedDate == nil)
//                        })
                        if !viewModel.scheduleListItems.isEmpty {
                            Text("События")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .padding(.horizontal, 24)
                                .padding(.top, 8)
                            
                            eventList2()
                                .padding()
                            Spacer()
                        } else {
                            Spacer()
                            Text("У вас нет событий")
                                .font(.headline)
                                .foregroundColor(.headerText)
                            Spacer()
                        }
                    } else {
                        ShimmeringRectangle()
                            .frame(width: .infinity, height: 450)
                            .cornerRadius(44)
                        
                        ShimmeringRectangle()
                            .frame(width: .infinity, height: 50)
                            .cornerRadius(44)
                        
                        ShimmeringRectangle()
                            .frame(width: .infinity, height: 50)
                            .cornerRadius(44)
                        
                        ShimmeringRectangle()
                            .frame(width: .infinity, height: 50)
                            .cornerRadius(44)
                        Spacer()
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle(Text("Расписание"))
            .scrollPosition(id: $hashebleDate.animation(), anchor: .top)
            .refreshable {
                Task.detached {
                    await viewModel.updateData()
                }
            }
        }
        .onChange(of: selectedDate) { oldState, newState in
            print("change eventsCalendar: \(newState)")
            hashebleDate = newState?.hashValue
            isDateSelected = newState != nil
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
                HStack(spacing: 8) {
                    Text(event.type.name)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    if let category = event.category {
                        Text("• \(category.rawValue)")
                            .font(.subheadline)
                            .foregroundColor(category.color)
                    }
                }
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
        // MARK: - Events List
        let filteredEvents = viewModel.scheduleListItems.filter { dateAndEvents in
            if selectedDate == nil {
                // Если нет выбранной даты, показываем все события
                return true
            } else {
                // Используем startOfDay для сравнения только по дате, без учета времени
                let selectedStartOfDay = Calendar.current.startOfDay(for: selectedDate!)
                let entryStartOfDay = Calendar.current.startOfDay(for: dateAndEvents.key)
                
                // Сравниваем даты
                return selectedStartOfDay == entryStartOfDay
            }
        }
        
        return Group {
            if filteredEvents.isEmpty {
                noEventsForSelectedDate
            } else {
                eventsListContent(filteredEvents)
            }
        }
    }
    
    // MARK: - No Events View
    private var noEventsForSelectedDate: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 40))
                .foregroundStyle(Color.secondary)
            
            if let date = selectedDate {
                Text("Нет событий на \(formattedDateHeader(date).lowercased())")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.secondary)
            } else {
                Text("Нет событий в календаре")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.secondary)
            }
            
            if selectedDate != nil {
                Button {
                    withAnimation {
                        selectedDate = nil
                        isDateSelected = false
                    }
                } label: {
                    Text("Показать за все время")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.mainRed)
                }
                .buttonStyle(.borderless)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    // MARK: - Events List Content
    private func eventsListContent(_ events: [Date: [CalendatItem]]) -> some View {
        LazyVStack(spacing: 16) {
            ForEach(events.sorted(by: { $0.key < $1.key }), id: \.key) { date, items in
                eventCard(date: date, events: items)
                    .id(date.hashValue)
            }
        }
        .padding(.bottom, 24)
    }
    
    // MARK: - Event Card
    private func eventCard(date: Date, events: [CalendatItem]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Заголовок с датой
            HStack {
                Text(formattedDateHeader(date))
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color.primary)
                
                Spacer()
                
                Text(dateString(date))
                    .font(.subheadline)
                    .foregroundStyle(Color.secondary)
            }
            .padding(.horizontal)
            
            Divider()
                .padding(.horizontal)
            
            // Список событий
            VStack(spacing: 4) {
                ForEach(events) { event in
                    EventRowView(event: event)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical, 8)
        }
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    // MARK: - Helper Methods
    private func formattedDateHeader(_ date: Date) -> String {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        
        if Calendar.current.isDate(date, inSameDayAs: today) {
            return "Сегодня"
        } else if Calendar.current.isDate(date, inSameDayAs: tomorrow) {
            return "Завтра"
        } else if Calendar.current.isDate(date, inSameDayAs: yesterday) {
            return "Вчера"
        } else {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ru_RU")
            formatter.dateFormat = "d MMMM"
            return formatter.string(from: date)
        }
    }
    
    private func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "E, d MMM"
        return formatter.string(from: date)
    }
}

// MARK: - Constants
extension SchedulerView {
    private enum Constants {
        static let title = "Выберите карту"
    }
}

#Preview {
    NavigationView {
        SchedulerView(viewModel: SchedulerViewModel(
            payRequest: [
                // Платежи на сегодня
                PaymentRequestResponseDto(
                    id: 1,
                    externalId: 1,
                    amount: 1500.0,
                    dueDate: Date().toApiString,
                    comment: "Оплата за консультацию",
                    paymentRequestStatus: .wait,
                    userProfilePreview: .getTestUser()
                ),
                // Платежи на завтра
                PaymentRequestResponseDto(
                    id: 2,
                    externalId: 2,
                    amount: 2000.0,
                    dueDate: Date.nowWith(plus: 1).toApiString,
                    comment: "Оплата за курс",
                    paymentRequestStatus: .wait,
                    userProfilePreview: .getTestUser()
                ),
                // Платежи на послезавтра
                PaymentRequestResponseDto(
                    id: 3,
                    externalId: 3,
                    amount: 3000.0,
                    dueDate: Date.nowWith(plus: 2).toApiString,
                    comment: "Оплата за материалы",
                    paymentRequestStatus: .canceled,
                    userProfilePreview: .getTestUser()
                )
            ],
            targets: [
                // Цели на сегодня
                UserTargetDtoModel(
                    id: 1,
                    title: "Изучить SwiftUI",
                    description: "Освоить основы SwiftUI и создать первое приложение",
                    deadLineDateTime: Date().toApiString,
                    targetStatus: .inProgress,
                    category: .personal
                ),
                // Цели на завтра
                UserTargetDtoModel(
                    id: 2,
                    title: "Прочитать книгу по архитектуре",
                    description: "Изучить паттерны проектирования",
                    deadLineDateTime: Date.nowWith(plus: 1).toApiString,
                    targetStatus: .done,
                    category: .money
                ),
                // Цели на следующую неделю
                UserTargetDtoModel(
                    id: 3,
                    title: "Подготовить презентацию",
                    description: "Создать презентацию для команды",
                    deadLineDateTime: Date.nowWith(plus: 7).toApiString,
                    targetStatus: .expired,
                    category: .health
                )
            ]
        ))
        .preferredColorScheme(.light)
    }
}

// Вспомогательное превью для тёмной темы
#Preview {
    NavigationView {
        SchedulerView(viewModel: SchedulerViewModel(
            payRequest: [
                PaymentRequestResponseDto(
                    id: 1,
                    externalId: 1,
                    amount: 1500.0,
                    dueDate: Date().toApiString,
                    comment: "Оплата за консультацию",
                    paymentRequestStatus: .wait,
                    userProfilePreview: .getTestUser()
                )
            ],
            targets: [
                UserTargetDtoModel(
                    id: 1,
                    title: "Изучить SwiftUI",
                    description: "Освоить основы SwiftUI и создать первое приложение",
                    deadLineDateTime: Date().toApiString,
                    targetStatus: .inProgress,
                    category: .personal
                )
            ]
        ))
        .preferredColorScheme(.dark)
    }
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
