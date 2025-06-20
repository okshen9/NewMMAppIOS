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
                                noEventsForSelectedDate
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
					await viewModel.updateData()
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
				if let selectedDate {
					let selectedStartOfDay = Calendar.current.startOfDay(for: selectedDate)
					let entryStartOfDay = Calendar.current.startOfDay(for: dateAndEvents.key)
					return selectedStartOfDay == entryStartOfDay
				} else {
					// Если нет выбранной даты, показываем все события
					return true
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

                HStack{
                    // Платежи
                    HStack(spacing: 2) {
                        AppIcons.Payment.coloredIcon(for: .wait)
                            .font(.system(size: 12))
						Text("Платежи")
							.font(MMFonts.body)
					}
					
                    // Цели
                    HStack(spacing: 2) {
                        AppIcons.Target.coloredIcon(for: .done, resizeble: true)
                            .frameRect(18)
						Text("Цели")
							.font(MMFonts.body)
					}
                    
                    // Подцели
                    HStack(spacing: 2) {
                        AppIcons.SubTarget.coloredIcon(for: .done, backColor: Color.white)
                            .frameRect(18)
                        Text("Подцели")
                            .font(MMFonts.body)
                    }
				}
			}
            .padding()
			.presentationCompactAdaptation(.popover)
		})
	}
    
    // MARK: - Events List Content
    @ViewBuilder
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
    @ViewBuilder
    private func eventCard(date: Date, events: [CalendatItem]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Заголовок с датой
            HStack {
                Text(formattedDateHeader(date))
                    .font(MMFonts.title)
                    .foregroundStyle(Color.primary)
                
                Spacer()
                
                dateStatusView(date)
            }
            .padding(.horizontal)
            
            Divider()
                .padding(.horizontal)
            
            // Список событий
            VStack(spacing: 12) {
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
    
    private func dateStatusView(_ date: Date) -> some View {
        VStack(spacing: 2) {
            Text(date.relativeTimeString())
                .font(MMFonts.caption)
                .foregroundColor(date.isOverdue ? .red : .secondary)
                .lineLimit(1)
            
            Text(dateString(date))
                .font(MMFonts.subCaption)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .frame(minWidth: 60)
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
            return Constants.headerDateFormatter.string(from: date)
        }
    }
    
    private func dateString(_ date: Date) -> String {
        Constants.subtitleDateFormatter.string(from: date)
    }
}

// MARK: - Constants
extension SchedulerView {
    private enum Constants {
        static let title = "Выберите карту"
        static let headerDateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ru_RU")
            formatter.dateFormat = "d MMMM"
            return formatter
        }()
        static let subtitleDateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ru_RU")
            formatter.dateFormat = "E, d MMM"
            return formatter
        }()
    }
}
