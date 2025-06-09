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

