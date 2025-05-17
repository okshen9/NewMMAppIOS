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
    var events: [DateComponents: [UIColor]] // Несколько событий на одну дату
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
            // Ищем совпадающие метки событий для текущего дня
            guard let colors = findEventColors(for: dateComponents) else {
                return nil
            }
            
            // Если есть хоть одно событие, используем декорацию с иконкой
            if !colors.isEmpty {
                return .customView {
                    let iconContainer = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
                    
                    // Проверяем какие типы событий присутствуют
                    let hasPayment = colors.contains { $0 == UIColor(Color.mainRed) }
                    let hasTarget = colors.contains { $0 == UIColor.systemGreen }
                    let hasSubTarget = colors.contains { $0 == UIColor.systemBlue }
                    
                    // Выбираем иконку на основе типов событий и соответствующий цвет
                    var iconImageName = "circle.fill"
                    var iconColor = UIColor.gray
                    
                    if hasPayment && hasTarget && hasSubTarget {
                        // Есть платеж, цель и подцель
                        iconImageName = "calendar.badge.exclamationmark"
                        iconColor = UIColor(Color.mainRed) // Приоритет у платежей
                    } else if hasPayment && hasTarget {
                        // Есть и платеж и цель - используем комбинированную иконку из AppIcons
                        iconImageName = "calendar.badge.exclamationmark" // Соответствует AppIcons.combined
                        iconColor = UIColor(Color.mainRed) // Приоритет у платежей
                    } else if hasPayment && hasSubTarget {
                        // Есть платеж и подцель
                        iconImageName = "calendar.badge.exclamationmark"
                        iconColor = UIColor(Color.mainRed) // Приоритет у платежей
                    } else if hasTarget && hasSubTarget {
                        // Есть цель и подцель
                        iconImageName = "star.circle"
                        iconColor = UIColor.systemGreen
                    } else if hasPayment {
                        // Только платеж - используем иконку платежа из AppIcons
                        iconImageName = "creditcard.fill" // Соответствует AppIcons.Payment.default
                        iconColor = UIColor(Color.mainRed)
                    } else if hasTarget {
                        // Только цель - используем иконку цели из AppIcons
                        iconImageName = "star.fill" // Соответствует AppIcons.Target.completed
                        iconColor = UIColor.systemGreen
                    } else if hasSubTarget {
                        // Только подцель - используем специальную иконку для подцелей
                        iconImageName = "checkmark.circle"
                        iconColor = UIColor.systemBlue
                    }
                    
                    // Создаем иконку
                    let iconImage = UIImage(systemName: iconImageName)
                    let iconView = UIImageView(image: iconImage)
                    iconView.tintColor = iconColor
                    iconView.contentMode = .scaleAspectFit
                    iconView.frame = iconContainer.bounds
                    
                    iconContainer.addSubview(iconView)
                    return iconContainer
                }
            }
            
            // Если нет событий, возвращаем nil (нет декорации)
            return nil
        }
        
        /// Находит цвета событий для указанной даты
        private func findEventColors(for dateComponents: DateComponents) -> [UIColor]? {
            // Ищем прямое совпадение
            for (key, value) in parent.events {
                if key.equalDate(dateComponents) {
                    return value
                }
            }
            
            // Если прямое совпадение не найдено, проверяем по году, месяцу и дню
            // Это нужно, так как DateComponents могут иметь разные компоненты
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

// Расширение для поддержки адаптивного размера
extension CalendarViewUIKit {
    func adaptiveHeight() -> some View {
        GeometryReader { geometry in
            self
                .frame(maxWidth: .infinity)
                .frame(height: 500)
        }
    }
    
    // Метод для установки фиксированной ширины 360 points
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

/// Пример использования календаря
struct CustomCalendarView: View {
    @State var currentComponent = Calendar.current.dateComponents(Set<Calendar.Component>(arrayLiteral: .year, .month, .day), from: Date.now)
    @State var dateDate2: DateComponents? = DateComponents(year: 2025, month: 2, day: 25)
    
    @State var dateDate3: Set<DateComponents> = [DateComponents(year: 2025, month: 2, day: 25)]
    
    @State var selectedDate: Date?
    let markedDates: [Date: [UIColor]] = [
        Calendar.current.date(from: DateComponents(year: 2025, month: 3, day: 5))!: [.red],
        Calendar.current.date(from: DateComponents(year: 2025, month: 3, day: 3))!: [.blue, .green,
                                                                                     .blue, .orange,.yellow,.darkGray,.brown]
    ]
    
    let markedDates2: [DateComponents: [UIColor]] = [
        DateComponents(year: 2025, month: 3, day: 5): [.red],
        DateComponents(year: 2025, month: 3, day: 3): [.blue, .green,
                                                                                     .blue, .orange,.yellow,.darkGray,.brown]
    ]


    var body: some View {
        VStack {
//            CalendarViewUIKit(visibleDateComponents: $currentComponent, selection: $dateDate2)
//                .decorating(dateDate3, color: .red)
//                .decorating(dateDate3, color: .green)
//                .tint(.blue)
//                .frame(height: 450)
            Button("text", action: {
                print("govno")
                selectedDate = nil
            })
            .background(.green)
            CalendarViewUIKit(selectedDate: $selectedDate, events: markedDates2)
                .constrainedSize(width: 360)
                .tint(.mainRed)
        }
        .padding()
    }
}

#Preview {
    CustomCalendarView(selectedDate: Date.now)
//        .background(.green)
}

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
