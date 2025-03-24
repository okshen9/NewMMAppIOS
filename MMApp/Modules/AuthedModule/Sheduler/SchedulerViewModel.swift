import SwiftUI
import Combine

// MARK: - ViewModel
class SchedulerViewModel: ObservableObject, SubscriptionStore {
    
    private var payRequest: [PaymentRequestResponseDto]?
    private var targets: [UserTargetDtoModel]?
    @Published var isLoading: Bool = false
    
    private let serviceNetwork = ServiceBuilder()
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
        
        paymant.forEach({ payMent in
            guard let dateOfPay = payMent.dueDate?.dateFromStringISO8601,
                  var user = userRepository.userProfile
            else { return }
            let componentOfPay = dateOfPay.dateComponentsFor()
            
            let name = "Запланировал платеж \(payMent.amount ?? 0.0)"
            
            var currentScheduleListItems = rawTempScheduleListItems[dateOfPay] ?? []
            currentScheduleListItems.append(.init(user: user, title: name, type: .payment, date: dateOfPay))
            rawTempScheduleListItems[dateOfPay] = currentScheduleListItems
        })
        
        targets.forEach({ target in
            guard let component = target.deadLineDateTime?.dateFromStringISO8601,
                  var user = userRepository.userProfile
            else { return }
            
            let name = "Крайний срок цели: \(target.title ?? "Цель без названия")"
            var enetsCurrent = rawTempScheduleListItems[component] ?? []
            enetsCurrent.append(.init(user: user, title: name, type: .target, date: component))
            rawTempScheduleListItems[component] = enetsCurrent
        })
        
        
        var tempScheduleListItems = rawTempScheduleListItems.reduce(into: [Date: [CalendatItem]]()) { result, entry in
            let startOfDay = Calendar.current.startOfDay(for: entry.key)
            result[startOfDay, default: []].append(contentsOf: entry.value)
        }
        
        
        var tempCalendar = [DateComponents: [UIColor]]()
        let rawCalendarItems = rawTempScheduleListItems.map({ key, value in
            return (key.dateComponentsFor(), value.map { $0.type.color })
        })
        
        for item in rawCalendarItems {
            let keyComponet = item.0
            let colors = rawCalendarItems
                .filter{$0.0 == keyComponet}
                .map{$0.1}
                .flatMap{$0}
            tempCalendar[keyComponet] = colors
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


