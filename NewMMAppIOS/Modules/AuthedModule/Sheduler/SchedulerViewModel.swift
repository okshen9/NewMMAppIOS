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
    @Published var calendarComponetsItems: [DateComponents: [CalendatItem]] = [:]

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
            if scheduleListItems.isEmpty ||
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
    private func updateUI(scheduleListItems: [Date: [CalendatItem]], calendarItems: [DateComponents: [CalendatItem]], isLoading: Bool = false) {
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
    ) -> (scheduleListItems: [Date: [CalendatItem]], calendarItems: [DateComponents: [CalendatItem]])
    {
        self.payRequest = paymant
        self.targets = targets
        
        var rawTempScheduleListItems = [Date: [CalendatItem]]()
        
        // Обработка платежей
        processPayments(payments: paymant, scheduleItems: &rawTempScheduleListItems)
        
        // Обработка целей
        processTargets(targets: targets, scheduleItems: &rawTempScheduleListItems)
        
        // Создаем данные для отметок в календаре
        let tempCalendar = createCalendarMarkers(from: rawTempScheduleListItems)
        
        return (rawTempScheduleListItems, tempCalendar)
    }
    
    /// Обрабатывает платежи и добавляет их в список событий календаря
    private func processPayments(payments: [PaymentRequestResponseDto], scheduleItems: inout [Date: [CalendatItem]]) {
        payments.forEach { payment in
            guard let dateOfPay = payment.dueDate?.dateFromApiString,
                  let user = userRepository.userProfile ?? userPreview
            else {
                print("neshko1 ERROR")
                return
            }

            // Используем startOfDay для группировки по дням
            let startOfDay = Calendar.current.startOfDay(for: dateOfPay)
            
            let title = payment.comment.isEmptyOrNil ? "Оплата" : payment.comment.orEmpty
            
            var currentScheduleListItems = scheduleItems[startOfDay] ?? []
            currentScheduleListItems.append(.init(user: user, title: title, type: .payment(payment), date: dateOfPay, category: nil))
            scheduleItems[startOfDay] = currentScheduleListItems
        }
    }
    
    /// Обрабатывает цели и их подцели, добавляя их в список событий календаря
    private func processTargets(targets: [UserTargetDtoModel], scheduleItems: inout [Date: [CalendatItem]]) {
        targets.forEach { target in
            guard let deadlineDate = target.deadLineDateTime?.dateFromStringISO8601,
                  let user = userRepository.userProfile ?? userPreview
            else { return }
            
            // Добавляем основную цель
            addTargetToSchedule(target: target, date: deadlineDate, user: user, scheduleItems: &scheduleItems)
            
            // Обрабатываем подцели
            processSubTargets(parentTarget: target, parentDeadline: deadlineDate, user: user, scheduleItems: &scheduleItems)
        }
    }
    
    /// Добавляет основную цель в список событий календаря
    private func addTargetToSchedule(target: UserTargetDtoModel, date: Date, user: UserProfileResultDto, scheduleItems: inout [Date: [CalendatItem]]) {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let category = target.category
        let title = "Цель: \(target.title ?? "Без названия")"
        
        // Создаем копию модели цели с полным списком подцелей для отображения
        var targetWithDetails = target
        
        var eventsCurrent = scheduleItems[startOfDay] ?? []
        eventsCurrent.append(.init(user: user, title: title, type: .target(targetWithDetails), date: date, category: category))
        scheduleItems[startOfDay] = eventsCurrent
    }
    
    /// Обрабатывает подцели и добавляет их в список событий календаря
    private func processSubTargets(parentTarget: UserTargetDtoModel, parentDeadline: Date, user: UserProfileResultDto, scheduleItems: inout [Date: [CalendatItem]]) {
        guard let subTargets = parentTarget.subTargets else { return }
        
        let parentStartOfDay = Calendar.current.startOfDay(for: parentDeadline)
        let category = parentTarget.category
        
        for subTarget in subTargets {
            guard let subDeadlineDate = subTarget.deadLineDateTime?.dateFromStringISO8601 else { continue }
            
            let subStartOfDay = Calendar.current.startOfDay(for: subDeadlineDate)
            
            // Пропускаем, если дедлайн подцели совпадает с дедлайном основной цели
            if subStartOfDay == parentStartOfDay { continue }
            
            let subTitle = "Подцель: \(subTarget.title ?? "Без названия")"
            
            var eventsCurrent = scheduleItems[subStartOfDay] ?? []
            eventsCurrent.append(.init(user: user, title: subTitle, type: .subTarget(subTarget), date: subDeadlineDate, category: category))
            scheduleItems[subStartOfDay] = eventsCurrent
        }
    }
    
    /// Создает маркеры для календаря на основе списка событий
    private func createCalendarMarkers(from scheduleItems: [Date: [CalendatItem]]) -> [DateComponents: [CalendatItem]] {
        var calendarMarkers = [DateComponents: [CalendatItem]]()
        
        for (date, events) in scheduleItems {
            let dateComponents = date.dateComponentsFor([.year, .month, .day])
            calendarMarkers[dateComponents] = events
        }
        
        return calendarMarkers
    }
}

// MARK: - Constants
extension SchedulerViewModel {
    private enum Constants {
        static let title = "Выберите карту"
    }
}


