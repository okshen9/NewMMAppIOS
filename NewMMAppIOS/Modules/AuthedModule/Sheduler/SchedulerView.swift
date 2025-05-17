import SwiftUI

struct SchedulerView: View {
    @StateObject var viewModel = SchedulerViewModel()
    @State private var selectedDate: Date?
    @State private var hashebleDate: Int? = Date().hashValue
    @State private var isDateSelected = false
	
	@State private var showCalendar: Bool = false
    
    // Категории для карусели
    private let categories: [TargetCategory] = [
        .money,
        .personal,
        .family,
        .health,
        .other
    ]
	
	var body: some View {
		NavigationStack {
			ScrollView(.vertical, showsIndicators: false) {
				VStack(alignment: .leading) {
					if viewModel.isLoading == false {
						VStack(alignment: .leading) {
							if !viewModel.scheduleListItems.isEmpty {
								eventList2()
									.padding()
								Spacer()
							} else {
								Spacer()
								Text("У вас нет событий")
									.font(MMFonts.title)
									.foregroundColor(.headerText)
								Spacer()
							}
						}
					} else {
						VStack {
							ShimmeringRectangle()
								.frame(height: 450)
								.cornerRadius(44)
							
							ShimmeringRectangle()
								.frame(height: 50)
								.cornerRadius(44)
							
							ShimmeringRectangle()
								.frame(height: 50)
								.cornerRadius(44)
							
							ShimmeringRectangle()
								.frame(height: 50)
								.cornerRadius(44)
							Spacer()
						}
						.padding(.horizontal, 16)
					}
				}
				
			}
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .principal) {
					HStack {
						Text("Расписание")
							.font(.largeTitle.bold())
							.foregroundStyle(Color.headerText)
						Spacer()
						hederCalendar()
					}
					.offset(y: -4)
				}
			}
			
			
			.scrollPosition(id: $hashebleDate.animation(.easeIn(duration: 0.3)), anchor: .top)
			.refreshable {
				for family in UIFont.familyNames.sorted() {
					let _ = print("Family: \(family)")
					let names = UIFont.fontNames(forFamilyName: family)
					for name in names {
						let _ = print("   Font: \(name)")
					}
				}
				Task.detached {
					await viewModel.updateData()
				}
			}
		}
		.onChange(of: selectedDate) { oldState, newState in
			hashebleDate = newState?.hashValue
			showCalendar = false
			isDateSelected = newState != nil
		}
		.onAppear {
			viewModel.onApper()
		}
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
		
		//        Group {
		if filteredEvents.isEmpty {
			noEventsForSelectedDate
		} else {
			eventsListContent(filteredEvents)
		}
	}
    
    // MARK: - No Events View
    private var noEventsForSelectedDate: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(MMFonts.title)
                .foregroundStyle(Color.secondary)
            
            if let date = selectedDate {
                Text("Нет событий на \(formattedDateHeader(date).lowercased())")
                    .font(MMFonts.title)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.secondary)
            } else {
                Text("Нет событий в календаре")
                    .font(MMFonts.title)
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
                        .font(MMFonts.subTitle)
                        .foregroundStyle(Color.mainRed)
                }
                .buttonStyle(.borderless)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
	
	@ViewBuilder
	fileprivate func hederLine() -> some View {
		HStack {
			Text("События")
				.font(MMFonts.title)
				.foregroundColor(.primary)
				.padding(.horizontal, 24)
				.padding(.top, 8)
			Spacer()
			hederCalendar()
		}
		.padding(.horizontal, 16)
	}
	
	@ViewBuilder
	fileprivate func hederCalendar() -> some View {
		ZStack {
			Color.mainRed
				.frame(width: 46, height: 46)
				.cornerRadius(12)
				.shadow(color: .mainRed, radius: 4)
			if let selectedDate {
				let date = MMDateFormatter.string(from: selectedDate, format: .dayD)
				let month = MMDateFormatter.string(from: selectedDate, format: .monthMMM)
				VStack {
					Text(date)
						.font(MMFonts.caption)
						.foregroundStyle(.white)
					Text(month)
						.font(MMFonts.caption)
						.foregroundStyle(.white)
				}
			} else {
				Image(systemName: "calendar")
					.foregroundStyle(.white)
					.font(.system(size: 18))
			}
		}
		.onTapGesture {
			showCalendar.toggle()
		}
		.popover(isPresented: $showCalendar, content: {
			VStack(spacing: 4) {
				CalendarViewUIKit(
					selectedDate: $selectedDate,
					events: viewModel.calendarComponetsItems,
					canDeselectSameDate: true
				)
				.tint(Color.red)
				Divider()
					.offset(x: 0, y: -10)
				
				// Типы событий - компактно в одной строке
				HStack(spacing: 16) {
					HStack(spacing: 8) {
						Circle()
							.foregroundStyle(Color.green)
							.frame(width: 12, height: 12)
						Text("Цели")
							.font(MMFonts.body)
					}
					
					HStack(spacing: 8) {
						Circle()
							.foregroundStyle(Color.mainRed)
							.frame(width: 12, height: 12)
						Text("Платежи")
							.font(MMFonts.body)
					}
				}
				.padding(.horizontal, 24)
			}
			.padding()
			.presentationCompactAdaptation(.popover)
		})
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
                    .font(MMFonts.title)
                    .foregroundStyle(Color.primary)
                
                Spacer()
                
                Text(dateString(date))
                    .font(MMFonts.subTitle)
                    .foregroundStyle(Color.secondary)
            }
            .padding(.horizontal)
            
            Divider()
                .padding(.horizontal)
            
            // Список событий с оптимизированным лейаутом
            VStack(spacing: 8) {
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

#Preview("1") {
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
                    dueDate: Date.nowWith(plus: 10).toApiString,
                    comment: "Оплата за материалы",
                    paymentRequestStatus: .canceled,
                    userProfilePreview: .getTestUser()
                )
            ],
			            targets: [
							UserTargetDtoModel.getBaseTarget(),
//							UserTargetDtoModel.getBaseTarget()
							]
//            targets: [
//				
//                // Цели на сегодня
//                UserTargetDtoModel(
//                    id: 1,
//                    title: "Изучить SwiftUI",
//                    description: "Освоить основы SwiftUI и создать первое приложение",
//                    deadLineDateTime: Date().toApiString,
//                    targetStatus: .inProgress,
//                    category: .personal
//                ),
//                // Цели на завтра
//                UserTargetDtoModel(
//                    id: 2,
//                    title: "Прочитать книгу по архитектуре",
//                    description: "Изучить паттерны проектирования",
//                    deadLineDateTime: Date.nowWith(plus: 1).toApiString,
//                    targetStatus: .done,
//                    category: .money
//                ),
//                // Цели на следующую неделю
//                UserTargetDtoModel(
//                    id: 3,
//                    title: "Подготовить презентацию",
//                    description: "Создать презентацию для команды",
//                    deadLineDateTime: Date.nowWith(plus: 7).toApiString,
//                    targetStatus: .expired,
//                    category: .health
//                )
//            ]
        ))
        .preferredColorScheme(.light)
    }
}

// Вспомогательное превью для тёмной темы
#Preview("2") {
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
