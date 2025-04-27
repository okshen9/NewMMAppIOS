import SwiftUI
import Combine

// MARK: - ViewModel
class SchedulerViewModel: ObservableObject, SubscriptionStore {

    /// только для превью
    var userPreview: UserProfileResultDto?

    private var payRequest: [PaymentRequestResponseDto]?
    private var targets: [UserTargetDtoModel]?
    @Published var isLoading: Bool = false
    
    private let serviceNetwork = ServiceBuilder.shared
    private let userRepository = UserRepository.shared
    
    @Published var scheduleListItems = [Date: [CalendatItem]]()
    @Published var calendarComponetsItems: Dictionary<DateComponents, [UIColor]> = [DateComponents: [UIColor]]()

    /// Только для превью
    convenience init(payRequest: [PaymentRequestResponseDto],
                     targets: [UserTargetDtoModel],
                     userPreview: UserProfileResultDto? = .getTestUser()) {
        self.init()
        self.userPreview = userPreview
        self.payRequest = payRequest
        self.targets = targets
        
        let items = prepereScheduleListItems(paymant: payRequest, targets: targets)
        
        print("neshko1 \(items)")
        
        print("neshko2 \(items.scheduleListItems.values.flatMap({$0}).count)")
        self.scheduleListItems = items.scheduleListItems
        self.calendarComponetsItems = items.calendarItems
    }
    
    // MARK: - Public Methods
    func onApper() {
        Task {
            if scheduleListItems.isEmpty,
               calendarComponetsItems.isEmpty {
                await updateData()
            }
        }
    }
    
    func updateData() async {
        do {
            await setIsLoading(true)
            let externalId = userRepository.externalId ?? -1
            guard let targets = try await serviceNetwork.getUserTargets(externalId: externalId).userTargets,
                  let paymant = try await serviceNetwork.getPaymentPlan(id: externalId)
            else {
                return
            }
            let items = prepereScheduleListItems(paymant: paymant, targets: targets)
            await updateUI(scheduleListItems: items.scheduleListItems, calendarItems: items.calendarItems)
        } catch {
            print("Neshko PayRequest \(error) - Ошибка загрзуки ")
        }
    }
    

    // MARK: - Private Methods
    @MainActor
    private func updateUI(scheduleListItems: [Date: [CalendatItem]], calendarItems: [DateComponents: [UIColor]], isLoading: Bool = false) {
        self.isLoading = isLoading
        self.scheduleListItems = scheduleListItems
        self.calendarComponetsItems = calendarItems

    }
    
    @MainActor
    private func setIsLoading(_ isLoading: Bool) {
        self.isLoading = isLoading
    }
    
    private func prepereScheduleListItems(paymant: [PaymentRequestResponseDto],
                                          targets: [UserTargetDtoModel]
    ) ->(scheduleListItems: [Date: [CalendatItem]], calendarItems: [DateComponents: [UIColor]])
    {
        self.payRequest = paymant
        self.targets = targets
        
        var rawTempScheduleListItems = [Date: [CalendatItem]]()
        
        // Обработка платежей
        paymant.forEach({ payMent in
            guard let dateOfPay = payMent.dueDate?.dateFromApiString,
                  let user = userRepository.userProfile ?? userPreview
            else {
                print("neshko1 ERROR")
                return
            }

            // Используем startOfDay для группировки по дням
            let startOfDay = Calendar.current.startOfDay(for: dateOfPay)
            let dateComponents = startOfDay.dateComponentsFor([.year, .month, .day])
            
            let title = payMent.comment.isEmptyOrNil ? "Оплата" : payMent.comment.orEmpty
            
            var currentScheduleListItems = rawTempScheduleListItems[startOfDay] ?? []
            currentScheduleListItems.append(.init(user: user, title: title, type: .payment(payMent), date: dateOfPay, category: nil))
            rawTempScheduleListItems[startOfDay] = currentScheduleListItems
        })
        
        // Обработка целей
        targets.forEach({ target in
            guard let deadlineDate = target.deadLineDateTime?.dateFromStringISO8601,
                  let user = userRepository.userProfile ?? userPreview
            else { return }
            
            // Используем startOfDay для группировки по дням
            let startOfDay = Calendar.current.startOfDay(for: deadlineDate)
            
            // Определяем категорию
            let category = target.category
            
            let title = "Цель: \(target.title ?? "Без названия")"
            
            // Создаем копию модели цели с полным списком подцелей для отображения
            var targetWithDetails = target
            
            // Отфильтровываем только необходимые подцели (если нужна дополнительная логика фильтрации)
            if let subTargets = targetWithDetails.subTargets {
                // Здесь можно добавить фильтрацию подцелей по статусу, если необходимо
                // Например, только невыполненные или с близким дедлайном
                targetWithDetails.subTargets = subTargets
            }
            
            var eventsCurrent = rawTempScheduleListItems[startOfDay] ?? []
            eventsCurrent.append(.init(user: user, title: title, type: .target(targetWithDetails), date: deadlineDate, category: category))
            rawTempScheduleListItems[startOfDay] = eventsCurrent
        })
        
        // Создаем данные для отметок в календаре
        var tempCalendar = [DateComponents: [UIColor]]()
        
        // Группируем события по дням для календаря
        for (date, events) in rawTempScheduleListItems {
            let dateComponents = date.dateComponentsFor([.year, .month, .day])
            
            // Отдельные цвета для платежей и целей
            var hasPayment = false
            var hasTarget = false
            var colors: [UIColor] = []
            
            // Проверяем типы событий
            for event in events {
                if case .payment = event.type  {
                    hasPayment = true
                } else if case .target = event.type {
                    hasTarget = true
                }
            }
            
            // Добавляем цвета в порядке приоритета
            if hasPayment {
                colors.append(UIColor(Color.mainRed))
            }
            if hasTarget {
                colors.append(UIColor.systemGreen)
            }
            
            tempCalendar[dateComponents] = colors
        }
        
        return (rawTempScheduleListItems, tempCalendar)
    }
}

// MARK: - Constants
extension SchedulerViewModel {
    private enum Constants {
        static let title = "Выберите карту"
    }
}


