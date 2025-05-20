//
//  CalendarViewUIKit.swift
//  MMApp
//
//  Created by artem on 23.02.2025.
//

import SwiftUI
import UIKit

struct CalendarViewUIKit: UIViewRepresentable {
    @Binding var selectedDate: Date?
    var events: [DateComponents: [CalendatItem]] // Несколько событий на одну дату
    var canDeselectSameDate: Bool = true // Можно ли отменить выбор, нажав на ту же дату
    
    // Соотношение сторон для календаря (ширина:высота)
    var aspectRatio: CGFloat = 0.9

    func makeUIView(context: Context) -> UICalendarView {
        let calendarView = UICalendarView()
        calendarView.locale = Locale(identifier: "ru_RU")
        calendarView.delegate = context.coordinator
        
        // Улучшаем адаптивность компонента
        calendarView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        calendarView.setContentHuggingPriority(.defaultLow, for: .vertical)
        calendarView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        // Создаем и настраиваем поведение выбора даты
        let selectionBehavior = UICalendarSelectionSingleDate(delegate: context.coordinator)
        selectionBehavior.setSelected(nil, animated: false)
        
        // Устанавливаем поведение
        calendarView.selectionBehavior = selectionBehavior
        
        return calendarView
    }

    func updateUIView(_ uiView: UICalendarView, context: Context) {
        // Синхронизация выбранной даты в UICalendarView с selectedDate
        if let selectedDate = selectedDate {
            print("⬆️ CalendarViewUIKit.updateUIView: установка даты \(selectedDate)")
            let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: selectedDate)
            (uiView.selectionBehavior as? UICalendarSelectionSingleDate)?.setSelected(dateComponents, animated: true)
        } else {
            // Если selectedDate стало nil, сбрасываем выбор даты
            print("⬇️ CalendarViewUIKit.updateUIView: сброс даты")
            (uiView.selectionBehavior as? UICalendarSelectionSingleDate)?.setSelected(nil, animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate, SubscriptionStore {
        var parent: CalendarViewUIKit

        init(_ parent: CalendarViewUIKit) {
            self.parent = parent
        }

        func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            // Ищем события для текущего дня
            guard let items = findEvents(for: dateComponents), !items.isEmpty else {
                return nil
            }
            
            // Определяем типы событий и приоритеты
            let hasPayment = items.contains { if case .payment = $0.type { return true } else { return false } }
            let hasTarget = items.contains { if case .target = $0.type { return true } else { return false } }
            let hasSubTarget = items.contains { if case .subTarget = $0.type { return true } else { return false } }
            
            return .customView {
                let iconContainer = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
                
                // Получаем иконку и цвет в зависимости от комбинации типов событий
                let (iconImage, iconColor) = self.getEventIconAndColor(
                    items: items,
                    hasPayment: hasPayment, 
                    hasTarget: hasTarget, 
                    hasSubTarget: hasSubTarget
                )
                
                // Создаем иконку
                let iconView = UIImageView(image: iconImage)
                iconView.tintColor = iconColor
                iconView.contentMode = .scaleAspectFit
                iconView.frame = iconContainer.bounds
                
                iconContainer.addSubview(iconView)
                return iconContainer
            }
        }
        
        /// Возвращает иконку и цвет для отображения в календаре
        private func getEventIconAndColor(
            items: [CalendatItem],
            hasPayment: Bool,
            hasTarget: Bool,
            hasSubTarget: Bool
        ) -> (UIImage?, UIColor) {
            // Комбинированные события

            if hasPayment && hasTarget && hasSubTarget {
                // Все три типа событий
                return (AppIcons.General.cardCombined.foregroundStyle(Color.mainRed).asUIImage(), UIColor(Color.mainRed))
            } else if hasPayment && hasTarget {
                // Платеж и цель
                return (AppIcons.General.cardCombined.foregroundStyle(Color.mainRed).asUIImage(), UIColor(Color.mainRed))
            } else if hasPayment && hasSubTarget {
                // Платеж и подцель
                return (AppIcons.General.cardCombined.foregroundStyle(Color.mainRed).asUIImage(), UIColor(Color.mainRed))
            } else if hasTarget && hasSubTarget {
                // Цель и подцель - используем иконку звезды с кружком
                return (AppIcons.General.targetCombined.foregroundStyle(Color.green).asUIImage(), UIColor(Color.green))
            }
            
            // Только платежи
            if hasPayment {
                if let paymentItem = items.first(where: { if case .payment = $0.type { return true } else { return false } }),
                   case let .payment(payment) = paymentItem.type {
                    let status = payment.paymentRequestStatus ?? .unknown
                    return (
                        AppIcons.Payment.baseIcon(for: status)
                            .foregroundStyle(Color.mainRed)
                            .asUIImage(),
                        UIColor(AppIcons.Payment.color(for: status)))
                }
                return (
                    AppIcons.Payment.baseIcon(for: nil)
                        .foregroundStyle(Color.mainRed)
                        .asUIImage(),
                    UIColor(Color.mainRed))
            }
            
            // Только цели
            if hasTarget {
                if let targetItem = items.first(where: { if case .target = $0.type { return true } else { return false } }),
                   case let .target(target) = targetItem.type {
                    let status = target.targetStatus ?? .unknown
                    return (
                        AppIcons.Target.baseIcon(for: .done)
                            .foregroundStyle(Color.green)
                            .asUIImage(),
                        UIColor(AppIcons.Target.color(for: status)))
                }
                return (
                    AppIcons.Target.baseIcon(for: .done)
                        .foregroundStyle(Color.green)
                        .asUIImage(),
                    UIColor.systemGreen)
            }
            
            // Только подцели
            if hasSubTarget {
                let sizeIconSubTarget = 30.0
                if let subTargetItem = items.first(where: { if case .subTarget = $0.type { return true } else { return false } }),
                   case let .subTarget(subTarget) = subTargetItem.type {
                    
                    let status = subTarget.targetStatus ?? .unknown
                    // Для подцелей используем стандартную иконку с соответствующим цветом
                    return (
                        AppIcons.SubTarget.coloredIcon(
                            for: status,
                            backColor: .white)
                        .frameRect(sizeIconSubTarget)
                        .asUIImage(),
                        UIColor(AppIcons.SubTarget.color(for: status)))
                }
                return (
                    AppIcons.SubTarget.coloredIcon(
                        for: .done,
                        backColor: .white)
                    .frameRect(sizeIconSubTarget)
                    .asUIImage(),
                    UIColor.green)
            }
            
            // Другие события
            return (UIImage(systemName: "lightbulb.fill"),
                    UIColor.systemIndigo)
        }
        
        /// Находит события для указанной даты
        private func findEvents(for dateComponents: DateComponents) -> [CalendatItem]? {
            // Ищем прямое совпадение
            for (key, value) in parent.events {
                if key.equalDate(dateComponents) {
                    return value
                }
            }
            
            // Если прямое совпадение не найдено, проверяем по году, месяцу и дню
            for (key, value) in parent.events {
                if key.year == dateComponents.year && 
                   key.month == dateComponents.month && 
                   key.day == dateComponents.day {
                    return value
                }
            }
            
            return nil
        }

        func dateSelection(_ selection: UICalendarSelectionSingleDate,
                           didSelectDate dateComponents: DateComponents?) {
            print("🔍 CalendarViewUIKit.didSelectDate: \(String(describing: dateComponents))")
            
            // Если dateComponents == nil, это означает отмену выбора
            if dateComponents == nil {
                DispatchQueue.main.async {
                    print("🔄 CalendarViewUIKit: отмена выбора даты")
                    self.parent.selectedDate = nil
                }
                return
            }
            
            guard let date = Calendar.current.date(from: dateComponents!) else {
                return
            }
            
            DispatchQueue.main.async {
                // Если пользователь нажал на уже выбранную дату и разрешена отмена выбора
                if self.parent.canDeselectSameDate,
                   let currentSelectedDate = self.parent.selectedDate,
                   Calendar.current.isDate(currentSelectedDate, inSameDayAs: date) {
                    // Сбрасываем выбор в UI компоненте
                    selection.setSelected(nil, animated: true)
                    // Сбрасываем значение биндинга
                    self.parent.selectedDate = nil
                } else {
                    // Устанавливаем новую дату
                    self.parent.selectedDate = date
                }
            }
        }
        
        // Метод для контроля возможности выбора даты
        func dateSelection(_ selection: UICalendarSelectionSingleDate,
                          canSelectDate dateComponents: DateComponents?) -> Bool {
            // Всегда разрешаем выбор даты
            return true
        }

        // Метод для контроля возможности отмены выбора даты
        func dateSelection(_ selection: UICalendarSelectionSingleDate,
                          canDeselectDate dateComponents: DateComponents?) -> Bool {
            // Всегда разрешаем отмену выбора даты
            print("⚡️ CalendarViewUIKit: запрос на canDeselectDate, разрешаем")
            return true
        }
    }
}

// MARK: - Расширение для поддержки адаптивного размера
extension CalendarViewUIKit {
    func adaptiveHeight() -> some View {
        GeometryReader { geometry in
            self
                .frame(maxWidth: .infinity)
                .frame(height: 500)
        }
    }
    
    // Метод для установки фиксированной ширины
    func fixedWidth(_ width: CGFloat = 360) -> some View {
        self
            .frame(width: width)
            .frame(height: width * aspectRatio)
    }

    // Метод для фиксированного размера, который действительно работает с UICalendarView
    func constrainedSize(width: CGFloat = 360) -> some View {
        let height = width * aspectRatio
        
        return GeometryReader { geometry in
            // Используем ZStack с фиксированным размером, чтобы принудительно ограничить размер
            ZStack {
                self
                    .fixedSize() // Важно: заставляет UIKit view соблюдать свои intrinsic размеры
                    .frame(width: min(width, geometry.size.width), height: height)
            }
            .frame(width: min(width, geometry.size.width), height: height)
        }
        .frame(width: width, height: height)
    }
}

// MARK: - Вспомогательное расширение для совместимости
extension CalendarViewUIKit {
    /// Инициализатор для обратной совместимости с версией, использующей UIColor
    init(selectedDate: Binding<Date?>, events: [DateComponents: [UIColor]], canDeselectSameDate: Bool = true) {
        self._selectedDate = selectedDate
        self.events = [:]
        self.canDeselectSameDate = canDeselectSameDate
    }
}

/// Пример использования календаря
struct CustomCalendarView: View {
    @State var selectedDate: Date?
    let events: [DateComponents: [CalendatItem]] = [:]

    var body: some View {
        VStack {
            Button("Сбросить дату", action: {
                selectedDate = nil
            })
            .background(.green)
            
            CalendarViewUIKit(selectedDate: $selectedDate, events: events)
                .constrainedSize(width: 360)
                .tint(.mainRed)
        }
        .padding()
    }
}

#Preview("Календарь") {
    CustomCalendarView(selectedDate: Date.now)
}

#Preview("Календарь со всеми типами событий") {
    // Создаем пользователя для тестирования
    let testUser = UserProfileResultDto.getTestUser()
    
    // Создаем текущую дату и даты для разных событий
    let today = Date.now
    let calendar = Calendar.current
    
    // Создаем компоненты дат для разных дней
    let todayComponents = calendar.dateComponents([.year, .month, .day], from: today)
    let day1Components = calendar.dateComponents([.year, .month, .day], from: calendar.date(byAdding: .day, value: 1, to: today)!)
    let day2Components = calendar.dateComponents([.year, .month, .day], from: calendar.date(byAdding: .day, value: 2, to: today)!)
    let day3Components = calendar.dateComponents([.year, .month, .day], from: calendar.date(byAdding: .day, value: 3, to: today)!)
    let day4Components = calendar.dateComponents([.year, .month, .day], from: calendar.date(byAdding: .day, value: 4, to: today)!)
    let day5Components = calendar.dateComponents([.year, .month, .day], from: calendar.date(byAdding: .day, value: 5, to: today)!)
    let day6Components = calendar.dateComponents([.year, .month, .day], from: calendar.date(byAdding: .day, value: 6, to: today)!)
    let day7Components = calendar.dateComponents([.year, .month, .day], from: calendar.date(byAdding: .day, value: 7, to: today)!)
    
    // Создаем платеж
    let payment1 = PaymentRequestResponseDto(
        id: 1,
        externalId: 1,
        amount: 1500.0,
        dueDate: today.toApiString,
        comment: "Оплата за консультацию",
        paymentRequestStatus: .wait,
        userProfilePreview: testUser
    )
    
    let payment2 = PaymentRequestResponseDto(
        id: 2,
        externalId: 2,
        amount: 2500.0,
        dueDate: today.toApiString,
        comment: "Оплата за услуги",
        paymentRequestStatus: .fullPaid,
        userProfilePreview: testUser
    )
    
    let payment3 = PaymentRequestResponseDto(
        id: 3,
        externalId: 3,
        amount: 3500.0,
        dueDate: today.toApiString,
        comment: "Оплата за подписку",
        paymentRequestStatus: .overdue,
        userProfilePreview: testUser
    )
    
    let payment4 = PaymentRequestResponseDto(
        id: 4,
        externalId: 4,
        amount: 4500.0,
        dueDate: today.toApiString,
        comment: "Оплата за аренду",
        paymentRequestStatus: .canceled,
        userProfilePreview: testUser
    )
    
    // Создаем цель
    let target1 = UserTargetDtoModel(
        id: 1,
        title: "Изучить SwiftUI",
        description: "Освоить основы SwiftUI и создать приложение",
        deadLineDateTime: today.toApiString,
        targetStatus: .inProgress,
        subTargets: [],
        category: .personal
    )
    
    let target2 = UserTargetDtoModel(
        id: 2,
        title: "Завершить проект",
        description: "Закончить разработку проекта",
        deadLineDateTime: today.toApiString,
        targetStatus: .done,
        subTargets: [],
        category: .money
    )
    
    let target3 = UserTargetDtoModel(
        id: 3,
        title: "Спортивная цель",
        description: "Заниматься спортом каждый день",
        deadLineDateTime: today.toApiString,
        targetStatus: .expired,
        subTargets: [],
        category: .health
    )
    
    // Создаем подцели с разными статусами
    let subTarget1 = UserSubTargetDtoModel(
        id: 1,
        title: "Изучить основы",
        description: "Изучить основные концепции SwiftUI",
        subTargetPercentage: 30.0,
        targetSubStatus: .inProgress,
        rootTargetId: 1
    )
    
    let subTarget2 = UserSubTargetDtoModel(
        id: 2,
        title: "Создать UI",
        description: "Разработать пользовательский интерфейс",
        subTargetPercentage: 40.0,
        targetSubStatus: .done,
        rootTargetId: 1
    )
    
    let subTarget3 = UserSubTargetDtoModel(
        id: 3,
        title: "Тестирование",
        description: "Провести тестирование приложения",
        subTargetPercentage: 30.0,
        targetSubStatus: .expired,
        rootTargetId: 1
    )
    
    // Создаем дополнительные подцели с разными статусами
    let subTarget4 = UserSubTargetDtoModel(
        id: 4,
        title: "Подцель не выполнена",
        description: "Статус не выполнена",
        subTargetPercentage: 0.0,
        targetSubStatus: .notDone,
        rootTargetId: 1
    )
    
    let subTarget5 = UserSubTargetDtoModel(
        id: 5,
        title: "Подцель выполнена с просрочкой",
        description: "Статус выполнена с просрочкой",
        subTargetPercentage: 100.0,
        targetSubStatus: .expiredDone,
        rootTargetId: 1
    )
    
    let subTarget6 = UserSubTargetDtoModel(
        id: 6,
        title: "Подцель провалена",
        description: "Статус провалена",
        subTargetPercentage: 0.0,
        targetSubStatus: .failed,
        rootTargetId: 1
    )
    
    // Создаем события календаря
    var events: [DateComponents: [CalendatItem]] = [:]
    
    // День 1: Только платеж
    events[todayComponents] = [
        CalendatItem(user: testUser, title: "Платеж", type: .payment(payment1), date: today, category: nil)
    ]
    
    // День 2: Только цель
    events[day1Components] = [
        CalendatItem(user: testUser, title: "Цель", type: .target(target1), date: calendar.date(byAdding: .day, value: 1, to: today)!, category: .personal)
    ]
    
    // День 3: Только подцели (с разными статусами)
    events[day2Components] = [
        CalendatItem(user: testUser, title: "Подцель (в процессе)", type: .subTarget(subTarget1), date: calendar.date(byAdding: .day, value: 2, to: today)!, category: nil)
    ]
    
    // День 4: Платеж + цель
    events[day3Components] = [
        CalendatItem(user: testUser, title: "Платеж", type: .payment(payment2), date: calendar.date(byAdding: .day, value: 3, to: today)!, category: nil),
        CalendatItem(user: testUser, title: "Цель", type: .target(target2), date: calendar.date(byAdding: .day, value: 3, to: today)!, category: .money)
    ]
    
    // День 5: Платеж + подцель
    events[day4Components] = [
        CalendatItem(user: testUser, title: "Платеж", type: .payment(payment3), date: calendar.date(byAdding: .day, value: 4, to: today)!, category: nil),
        CalendatItem(user: testUser, title: "Подцель", type: .subTarget(subTarget2), date: calendar.date(byAdding: .day, value: 4, to: today)!, category: nil)
    ]
    
    // День 6: Цель + подцель
    events[day5Components] = [
        CalendatItem(user: testUser, title: "Цель", type: .target(target3), date: calendar.date(byAdding: .day, value: 5, to: today)!, category: .health),
        CalendatItem(user: testUser, title: "Подцель", type: .subTarget(subTarget3), date: calendar.date(byAdding: .day, value: 5, to: today)!, category: nil)
    ]
    
    // День 7: Платеж + цель + подцель (все типы событий)
    events[day6Components] = [
        CalendatItem(user: testUser, title: "Платеж", type: .payment(payment4), date: calendar.date(byAdding: .day, value: 6, to: today)!, category: nil),
        CalendatItem(user: testUser, title: "Цель", type: .target(target1), date: calendar.date(byAdding: .day, value: 6, to: today)!, category: .personal),
        CalendatItem(user: testUser, title: "Подцель", type: .subTarget(subTarget1), date: calendar.date(byAdding: .day, value: 6, to: today)!, category: nil)
    ]
    
    // День 8: Разные статусы платежей
    events[day7Components] = [
        CalendatItem(user: testUser, title: "Платеж (ожидание)", type: .payment(payment1), date: calendar.date(byAdding: .day, value: 7, to: today)!, category: nil),
        CalendatItem(user: testUser, title: "Платеж (оплачен)", type: .payment(payment2), date: calendar.date(byAdding: .day, value: 7, to: today)!, category: nil),
        CalendatItem(user: testUser, title: "Платеж (просрочен)", type: .payment(payment3), date: calendar.date(byAdding: .day, value: 7, to: today)!, category: nil),
        CalendatItem(user: testUser, title: "Платеж (отменен)", type: .payment(payment4), date: calendar.date(byAdding: .day, value: 7, to: today)!, category: nil)
    ]
    
    // Дополнительные дни с подцелями разных статусов
    let day14Components = calendar.dateComponents([.year, .month, .day], from: calendar.date(byAdding: .day, value: 14, to: today)!)
    let day15Components = calendar.dateComponents([.year, .month, .day], from: calendar.date(byAdding: .day, value: 15, to: today)!)
    let day16Components = calendar.dateComponents([.year, .month, .day], from: calendar.date(byAdding: .day, value: 16, to: today)!)
    
    events[day14Components] = [
        CalendatItem(user: testUser, title: "Подцель (не выполнена)", type: .subTarget(subTarget4), date: calendar.date(byAdding: .day, value: 14, to: today)!, category: nil)
    ]
    
    events[day15Components] = [
        CalendatItem(user: testUser, title: "Подцель (выполнена с просрочкой)", type: .subTarget(subTarget5), date: calendar.date(byAdding: .day, value: 15, to: today)!, category: nil)
    ]
    
    events[day16Components] = [
        CalendatItem(user: testUser, title: "Подцель (провалена)", type: .subTarget(subTarget6), date: calendar.date(byAdding: .day, value: 16, to: today)!, category: nil)
    ]
    
    return VStack {
        Text("Календарь со всеми типами событий")
            .font(MMFonts.title)
        
        CalendarViewUIKit(selectedDate: .constant(today), events: events)
            .constrainedSize(width: 360)
            .tint(.mainRed)
            
        VStack(alignment: .leading, spacing: 8) {
            Text("Легенда:")
                .font(MMFonts.subTitle)
            
            HStack {
                AppIcons.Payment.coloredIcon(for: .wait)
                    .frameRect(20)
                Text("Платеж")
                
                Spacer()
                
                AppIcons.Target.coloredIcon(for: .done)
                    .frameRect(20)
                Text("Цель")
                
                Spacer()
                
                AppIcons.SubTarget.coloredIcon(for: .done, backColor: .white)
                    .frameRect(20)
                Text("Подцель")
            }
            .font(MMFonts.caption)
            
            Divider()
            
            HStack {
                AppIcons.General.cardCombined
                    .foregroundStyle(Color.mainRed)
                    .frameRect(20)
                Text("Платеж + Цель")
                
                Spacer()
                
                AppIcons.General.cardCombined
                    .foregroundStyle(Color.mainRed)
                    .frameRect(20)
                Text("Платеж + Подцель")
            }
            .font(MMFonts.caption)
            
            HStack {
                AppIcons.General.targetCombined
                    .foregroundStyle(Color.green)
                    .frameRect(20)
                Text("Цель + Подцель")
                
                Spacer()
                
                AppIcons.General.cardCombined
                    .foregroundStyle(Color.mainRed)
                    .frameRect(20)
                Text("Все типы")
            }
            .font(MMFonts.caption)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .padding()
    }
}

#Preview("Календарь с разными статусами целей") {
    // Создаем пользователя для тестирования
    let testUser = UserProfileResultDto.getTestUser()
    
    // Создаем текущую дату и даты для разных событий
    let today = Date.now
    let calendar = Calendar.current
    
    // Создаем компоненты дат для разных дней
    let todayComponents = calendar.dateComponents([.year, .month, .day], from: today)
    let day1Components = calendar.dateComponents([.year, .month, .day], from: calendar.date(byAdding: .day, value: 1, to: today)!)
    let day2Components = calendar.dateComponents([.year, .month, .day], from: calendar.date(byAdding: .day, value: 2, to: today)!)
    let day3Components = calendar.dateComponents([.year, .month, .day], from: calendar.date(byAdding: .day, value: 3, to: today)!)
    let day4Components = calendar.dateComponents([.year, .month, .day], from: calendar.date(byAdding: .day, value: 4, to: today)!)
    let day5Components = calendar.dateComponents([.year, .month, .day], from: calendar.date(byAdding: .day, value: 5, to: today)!)
    let day6Components = calendar.dateComponents([.year, .month, .day], from: calendar.date(byAdding: .day, value: 6, to: today)!)
    
    // Создаем цели с разными статусами
    let targetInProgress = UserTargetDtoModel(
        id: 1,
        title: "В процессе",
        description: "Цель в процессе выполнения",
        deadLineDateTime: today.toApiString,
        targetStatus: .inProgress,
        subTargets: [],
        category: .personal
    )
    
    let targetDone = UserTargetDtoModel(
        id: 2,
        title: "Завершена",
        description: "Цель завершена",
        deadLineDateTime: today.toApiString,
        targetStatus: .done,
        subTargets: [],
        category: .money
    )
    
    let targetDoneExpired = UserTargetDtoModel(
        id: 3,
        title: "Завершена с просрочкой",
        description: "Цель завершена с просрочкой",
        deadLineDateTime: today.toApiString,
        targetStatus: .doneExpired,
        subTargets: [],
        category: .family
    )
    
    let targetExpired = UserTargetDtoModel(
        id: 4,
        title: "Просрочена",
        description: "Цель просрочена",
        deadLineDateTime: today.toApiString,
        targetStatus: .expired,
        subTargets: [],
        category: .health
    )
    
    let targetCancelled = UserTargetDtoModel(
        id: 5,
        title: "Отменена",
        description: "Цель отменена",
        deadLineDateTime: today.toApiString,
        targetStatus: .cancelled,
        subTargets: [],
        category: .other
    )
    
    let targetFailed = UserTargetDtoModel(
        id: 6,
        title: "Провалена",
        description: "Цель провалена",
        deadLineDateTime: today.toApiString,
        targetStatus: .failed,
        subTargets: [],
        category: .personal
    )
    
    // Создаем подцели с разными статусами
    let subTargetNotDone = UserSubTargetDtoModel(
        id: 1,
        title: "Не выполнена",
        description: "Подцель не выполнена",
        subTargetPercentage: 0.0,
        targetSubStatus: .notDone,
        rootTargetId: 1
    )
    
    let subTargetInProgress = UserSubTargetDtoModel(
        id: 2,
        title: "В процессе",
        description: "Подцель в процессе выполнения",
        subTargetPercentage: 50.0,
        targetSubStatus: .inProgress,
        rootTargetId: 1
    )
    
    let subTargetDone = UserSubTargetDtoModel(
        id: 3,
        title: "Выполнена",
        description: "Подцель выполнена",
        subTargetPercentage: 100.0,
        targetSubStatus: .done,
        rootTargetId: 1
    )
    
    let subTargetExpired = UserSubTargetDtoModel(
        id: 4,
        title: "Просрочена",
        description: "Подцель просрочена",
        subTargetPercentage: 30.0,
        targetSubStatus: .expired,
        rootTargetId: 1
    )
    
    let subTargetExpiredDone = UserSubTargetDtoModel(
        id: 5,
        title: "Выполнена с просрочкой",
        description: "Подцель выполнена с просрочкой",
        subTargetPercentage: 100.0,
        targetSubStatus: .expiredDone,
        rootTargetId: 1
    )
    
    let subTargetFailed = UserSubTargetDtoModel(
        id: 6,
        title: "Провалена",
        description: "Подцель провалена",
        subTargetPercentage: 10.0,
        targetSubStatus: .failed,
        rootTargetId: 1
    )
    
    // Создаем события календаря
    var events: [DateComponents: [CalendatItem]] = [:]
    
    // Разные статусы целей
    events[todayComponents] = [
        CalendatItem(user: testUser, title: "В процессе", type: .target(targetInProgress), date: today, category: .personal)
    ]
    
    events[day1Components] = [
        CalendatItem(user: testUser, title: "Завершена", type: .target(targetDone), date: calendar.date(byAdding: .day, value: 1, to: today)!, category: .money)
    ]
    
    events[day2Components] = [
        CalendatItem(user: testUser, title: "Завершена с просрочкой", type: .target(targetDoneExpired), date: calendar.date(byAdding: .day, value: 2, to: today)!, category: .family)
    ]
    
    events[day3Components] = [
        CalendatItem(user: testUser, title: "Просрочена", type: .target(targetExpired), date: calendar.date(byAdding: .day, value: 3, to: today)!, category: .health)
    ]
    
    events[day4Components] = [
        CalendatItem(user: testUser, title: "Отменена", type: .target(targetCancelled), date: calendar.date(byAdding: .day, value: 4, to: today)!, category: .other)
    ]
    
    events[day5Components] = [
        CalendatItem(user: testUser, title: "Провалена", type: .target(targetFailed), date: calendar.date(byAdding: .day, value: 5, to: today)!, category: .personal)
    ]
    
    // Разные статусы подцелей
    let day8Components = calendar.dateComponents([.year, .month, .day], from: calendar.date(byAdding: .day, value: 8, to: today)!)
    let day9Components = calendar.dateComponents([.year, .month, .day], from: calendar.date(byAdding: .day, value: 9, to: today)!)
    let day10Components = calendar.dateComponents([.year, .month, .day], from: calendar.date(byAdding: .day, value: 10, to: today)!)
    let day11Components = calendar.dateComponents([.year, .month, .day], from: calendar.date(byAdding: .day, value: 11, to: today)!)
    let day12Components = calendar.dateComponents([.year, .month, .day], from: calendar.date(byAdding: .day, value: 12, to: today)!)
    let day13Components = calendar.dateComponents([.year, .month, .day], from: calendar.date(byAdding: .day, value: 13, to: today)!)
    
    events[day8Components] = [
        CalendatItem(user: testUser, title: "Не выполнена", type: .subTarget(subTargetNotDone), date: calendar.date(byAdding: .day, value: 8, to: today)!, category: nil)
    ]
    
    events[day9Components] = [
        CalendatItem(user: testUser, title: "В процессе", type: .subTarget(subTargetInProgress), date: calendar.date(byAdding: .day, value: 9, to: today)!, category: nil)
    ]
    
    events[day10Components] = [
        CalendatItem(user: testUser, title: "Выполнена", type: .subTarget(subTargetDone), date: calendar.date(byAdding: .day, value: 10, to: today)!, category: nil)
    ]
    
    events[day11Components] = [
        CalendatItem(user: testUser, title: "Просрочена", type: .subTarget(subTargetExpired), date: calendar.date(byAdding: .day, value: 11, to: today)!, category: nil)
    ]
    
    events[day12Components] = [
        CalendatItem(user: testUser, title: "Выполнена с просрочкой", type: .subTarget(subTargetExpiredDone), date: calendar.date(byAdding: .day, value: 12, to: today)!, category: nil)
    ]
    
    events[day13Components] = [
        CalendatItem(user: testUser, title: "Провалена", type: .subTarget(subTargetFailed), date: calendar.date(byAdding: .day, value: 13, to: today)!, category: nil)
    ]
    
    return VStack {
        Text("Календарь с разными статусами")
            .font(MMFonts.title)
        
        CalendarViewUIKit(selectedDate: .constant(today), events: events)
            .constrainedSize(width: 360)
            .tint(.mainRed)
            
        VStack(alignment: .leading, spacing: 8) {
            Text("Статусы целей:")
                .font(MMFonts.subTitle)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(TargetStatus.valueCases, id: \.self) { status in
                        VStack {
                            AppIcons.Target.coloredIcon(for: status)
                                .frameRect(20)
                            Text(status.title)
                                .font(MMFonts.caption)
                        }
                    }
                }
            }
            
            Text("Статусы подцелей:")
                .font(MMFonts.subTitle)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(TargetSubStatus.allCases, id: \.self) { status in
                        VStack {
                            AppIcons.SubTarget.coloredIcon(for: status, backColor: .white)
                                .frameRect(20)
                            Text(status.title)
                                .font(MMFonts.caption)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .padding()
    }
}

#Preview("В контексте приложения") {
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
                    id: 2,
                    title: "Изучить SwiftUI",
                    description: "Освоить основы SwiftUI и создать первое приложение",
                    deadLineDateTime: Date().toApiString,
                    targetStatus: .inProgress,
                    subTargets: [
                        UserSubTargetDtoModel(id: 1,
                                              title: "sddf",
                                              description: Date().toApiString,
                                              subTargetPercentage: 44.4,
                                              targetSubStatus: .notDone,
                                              rootTargetId: 2)
                    ],
                    category: .personal
                )
            ]
        ))
//        .preferredColorScheme(.dark)
    }
}
