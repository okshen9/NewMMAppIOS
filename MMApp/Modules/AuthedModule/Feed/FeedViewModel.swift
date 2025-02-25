import SwiftUI
import Combine

// MARK: - ViewModel
class FeedViewModel: ObservableObject {
    
    @Published var payRequest: [PaymentRequestResponseDto]?
    @Published var targets: [UserTargetDtoModel]?
    @Published var isLoading: Bool = false
    
    private let serviceNetwork = ServiceBuilder()
    private let userRepository = UserRepository.shared
    
    @Published var events = [Date: [EventMM]]()
    @Published var eventsCalendar: Dictionary<Date, [UIColor]> = /*[Date: [UIColor]]()*/[
        Calendar.current.date(from: DateComponents(year: 2025, month: 2, day: 5))!: [.red],
        Calendar.current.date(from: DateComponents(year: 2025, month: 2, day: 3))!: [.blue, .green,
                                                                                     .blue, .orange,.yellow,.darkGray,.brown]]


    // MARK: - Public Methods
    func updateTitle() {
    }

    // MARK: - Private Methods
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
            await updateUI(paymant: paymant, targets: targets)
        } catch {
            print("Neshko PayRequest \(error) - Ошибка загрзуки ")
        }
    }
    
    @MainActor
    private func updateUI(paymant: [PaymentRequestResponseDto], targets: [UserTargetDtoModel], isLoading: Bool = false) {
        self.payRequest = paymant
        self.targets = targets
        self.isLoading = isLoading
        let testPay = payRequest?.map({$0.amount})
            .compactMap{$0}
        
        var tempEvents = [Date: [EventMM]]()
        
        paymant.forEach({ payMent in
            guard let component = payMent.dueDate?.dateFromStringISO8601 else { return }
            
            let name = "Запланировал платеж \(payMent.amount ?? 0.0)"
            var enetsCurrent = tempEvents[component] ?? []
            enetsCurrent.append(.init(title: name, type: .payment))
            tempEvents[component] = enetsCurrent
        })
        
        targets.forEach({ target in
            guard let component = target.deadLineDateTime?.dateFromStringISO8601 else { return }
            
            let name = "Крайний срок цели: \(target.title ?? "Цель без названия")"
            var enetsCurrent = tempEvents[component] ?? []
            enetsCurrent.append(.init(title: name, type: .target))
            tempEvents[component] = enetsCurrent
        })
        events = tempEvents
        let testww = Dictionary<Date, [UIColor]>(
            uniqueKeysWithValues: tempEvents.map { Dictionary.Element($0.key, $0.value.map{ $0.type.color }) }
        ) //as Dictionary<DateComponents, [Color]>
        eventsCalendar = testww
        
        
    }
    
    @MainActor
    private func setIsLoading(_ isLoading: Bool) {
        self.isLoading = isLoading
    }
    
}

// MARK: - Constants
extension FeedViewModel {
    private enum Constants {
        static let title = "Выберите карту"
    }
}


struct EventMM: Identifiable, Equatable {
    var id = UUID()
    
    let title: String
    let type: MMEventType
    
    enum MMEventType {
        case payment
        case target
        
        var name: String {
            switch self {
            case .payment:
                return "Оплата"
            case .target:
                return "Закрытие цели"
            }
        }
        
        var color: UIColor {
            switch self {
            case .payment:
                return .blue
            case .target:
                return .red
            }
        }
    }
}
