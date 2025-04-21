import SwiftUI
import Combine

// MARK: - ViewModel
class SchedulerViewModel: ObservableObject, SubscriptionStore {
    
    private var payRequest: [PaymentRequestResponseDto]?
    private var targets: [UserTargetDtoModel]?
    @Published var isLoading: Bool = false
    
    private let serviceNetwork = ServiceBuilder.shared
    private let userRepository = UserRepository.shared
    
    @Published var scheduleListItems = [Date: [CalendatItem]]()
    @Published var calendarComponetsItems: Dictionary<DateComponents, [UIColor]> = [DateComponents: [UIColor]]()

    
    convenience init(payRequest: [PaymentRequestResponseDto], targets: [UserTargetDtoModel]) {
        self.init()
        self.payRequest = payRequest
        self.targets = targets

        let items = prepereScheduleListItems(paymant: payRequest, targets: targets)
        print("neshko1 \(items)")
        self.scheduleListItems = items.scheduleListItems
        self.calendarComponetsItems = items.calendarItems
    }
    
    // MARK: - Public Methods
    func onApper() {
        Task {
            await updateProfile()
        }
    }
    
    func updateProfile() async {
        do {
            await setIsLoading(true)
            let externalId = userRepository.externalId ?? -1
            guard let targets = try await serviceNetwork.getUserTargets(externalId: externalId).userTargets,
                  let paymant = try await serviceNetwork.getPaymentPlan(id: externalId)
            else { return }
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
        calendarComponetsItems = calendarItems
        
    }
    
    @MainActor
    private func setIsLoading(_ isLoading: Bool) {
        self.isLoading = isLoading
    }
    
    private func prepereScheduleListItems(paymant: [PaymentRequestResponseDto], targets: [UserTargetDtoModel]) -> (scheduleListItems: [Date: [CalendatItem]], calendarItems: [DateComponents: [UIColor]]) {
        self.payRequest = paymant
        self.targets = targets
        
        var rawTempScheduleListItems = [Date: [CalendatItem]]()
        
        // Обработка платежей
        paymant.forEach({ payMent in
            guard let dateOfPay = payMent.dueDate?.dateFromStringISO8601,
                  var user = userRepository.userProfile
            else { return }
            
            // Используем startOfDay для группировки по дням
            let startOfDay = Calendar.current.startOfDay(for: dateOfPay)
            let componentOfPay = startOfDay.dateComponentsFor()
            
            let name = "Оплата \(payMent.amount ?? 0.0) ₽"
            
            var currentScheduleListItems = rawTempScheduleListItems[startOfDay] ?? []
            currentScheduleListItems.append(.init(payment: payMent, target: nil, user: user, title: name, type: .payment, date: dateOfPay, category: nil))
            rawTempScheduleListItems[startOfDay] = currentScheduleListItems
        })
        
        // Обработка целей
        targets.forEach({ target in
            guard let component = target.deadLineDateTime?.dateFromStringISO8601,
                  var user = userRepository.userProfile
            else { return }
            
            // Используем startOfDay для группировки по дням
            let startOfDay = Calendar.current.startOfDay(for: component)
            
            let name = "Крайний срок цели: \(target.title ?? "Цель без названия")"
            var enetsCurrent = rawTempScheduleListItems[startOfDay] ?? []
            enetsCurrent.append(.init(payment: nil, target: target, user: user, title: name, type: .target, date: component, category: target.category))
            rawTempScheduleListItems[startOfDay] = enetsCurrent
        })
        
        // Уже сгруппировали по дням, поэтому дополнительная группировка не нужна
        let tempScheduleListItems = rawTempScheduleListItems
        
        // Создаем данные для отметок в календаре
        var tempCalendar = [DateComponents: [UIColor]]()
        let calendarItemsByDay = rawTempScheduleListItems.mapValues { events in
            events.map { $0.type.color }
        }
        
        // Преобразуем даты в компоненты для календаря
        for (date, colors) in calendarItemsByDay {
            let dateComponents = date.dateComponentsFor([.year, .month, .day])
            tempCalendar[dateComponents] = colors
        }
        
        return (tempScheduleListItems, tempCalendar)
    }
}

// MARK: - Constants
extension SchedulerViewModel {
    private enum Constants {
        static let title = "Выберите карту"
    }
}


