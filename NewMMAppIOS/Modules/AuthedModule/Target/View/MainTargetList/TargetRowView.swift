//
//  TargetRowView.swift
//  MMApp
//
//  Created by artem on 30.01.2025.
//

import SwiftUI

protocol TargetRowViewModelProtocol: ObservableObject {
    /// Закрыть цель
    func closedTarget(target: UserTargetDtoModel)
    /// удлить цель
    func deleteTarget(target: UserTargetDtoModel)
}

struct TargetRowView<ViewModel: TargetRowViewModelProtocol>: View {
    @EnvironmentObject private var viewModelEnvironment: ViewModel

    var myTarget = true
    /// Отображаемый таргет
    var target: UserTargetDtoModel
    
    /// Показать диалоговое окошко закрытии/открытие задачи
    @State private var showCloseTaskDialog = false {
        didSet {
            print("showCloseTaskDialog изменился на: \(showCloseTaskDialog)")
        }
    }
    /// Показать модалку по лонгтапу
    @State private var showLongTapDialog = false
    
    /// Показать модалку по лонгтапу
    @State private var isPressed = false
    /// Свернуть/развернуть цель
    @State private var isExpanded: Bool = false
    /// переход на экаран редактирования
    @State private var isEditing: Bool = false
    /// Меняется статус цели
    @State private var isLoading = false
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            headerView()
            // Подцели
            if isExpanded,
               let subTargets = target.subTargets {
                ForEach(subTargets) { subTarget in
                    SubTargetRowView<TargetsViewModel>(
                        myTarget: myTarget,
                        subTarget: subTarget,
                        parentTarget: target
                    )
                }
            }
            let targetButtonStatus = targetButtonStatus(target: target)
            targetButtonView(targetButtonStatus)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(radius: 2)
        .padding(.horizontal, 4)
        .onChange(of: target, {
            isLoading = false
            print("Изменилась TargetRowView")
        })
        
        // Анимация масштаба
        .scaleEffect(isPressed ? 1.05 : 1.0)
        // Анимация
        .animation(.easeInOut(duration: 0.3), value: isPressed)
        .onLongPressGesture(
            // Минимальная длительность нажатия
            minimumDuration: 0.5,
            // Обновляем состояние нажатия
            pressing: { isPressing in
                if myTarget {
                    withAnimation { isPressed = isPressing }
                }
            },
            perform: {
                if myTarget {
                    showLongTapDialog = true
                }
            }
        )
        .actionSheet(isPresented: $showLongTapDialog) {
                ActionSheet(
                    title: Text("Действия с целью"),
                    buttons: [
                        .default(Text("Изменить цель")) {
                            isEditing = true
                        },
                        .destructive(Text("Удалить цель")) {
                            viewModelEnvironment.deleteTarget(target: target)

                        },
                        .cancel(Text("Отмена")) {
                            //                        selection = "Blue"
                        },
                    ]
                )
        }
        .alert(
            (target.targetStatus?.isDone) ?? false ? "Вы хотите открыть эту цель?" : "Вы закрыли эту цель?",
            isPresented: $showCloseTaskDialog
        ) {
            Button("Да") {
                isLoading = true
                viewModelEnvironment.closedTarget(target: target)
                print("Цель изменена")
            }
            Button("Нет", role: .cancel) {
                print("Отмена операции")
            }
        }
    }
    
    // MARK: - ViewBuilder
    /// Заголовок, дата, прогресс-бар
    @ViewBuilder
    func headerView() -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(target.title.orEmpty)
                    .font(.subheadline)
                    .foregroundColor(.headerText)
                Text("Срок выполнения: \((target.deadLineDateTime?.dateFromString ?? Date.now).toDisplayString)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                let percentTarget: Double = ((target.subTargets).isEmptyOrNil) ?
                (((target.targetStatus?.isDone) ?? false) ? 100.0 : 0.0) :
                target.percentage ?? 0.0
                
                ProgressView(value: percentTarget, total: 100)
                    .tint(.mainRed)
            }
            Spacer()
            .buttonStyle(.plain)
            .contentShape(Rectangle())
            .sheet(isPresented: $isEditing) {
                TargetEditView<TargetsViewModel>(target: target, isCreateTarget: false)
            }
            let statusText: (String, Color) = switch target.targetStatus ?? .draft {
            case .draft, .unknown: ("На рассмотрении", .orange)
            case .done: ("Выполнено", .green)
            case .expired: ("Просрочено", .red)
            case .inProgress:
                ("В процессе", .yellow)
            case .doneExpired:
                ("Выполненно с задержкой", .red)
            case .cancelled:
                ("Отменено", .red)
            case .failed:
                ("Провалено", .red)
            }
            Text(statusText.0)
                .font(.subheadline)
                .foregroundColor(statusText.1)
        }
    }
    
    /// Кнопка "Развернуть/Свернуть" Открыть / Закрыть задачу
    @ViewBuilder
    func targetButtonView(_ targetButtonStatus: TargetButtonStatus) -> some View {
        if (targetButtonStatus == .toDone ||
               targetButtonStatus == .toInProgress),
           !myTarget {
            EmptyView()
        } else {
            Button(action: {
                withAnimation {
                    switch targetButtonStatus {
                    case .turn, .expand:
                        isExpanded.toggle()
                    case .toDone, .toInProgress:
                        print("Показываем диалог закрытия задачи")
                        if myTarget {
                            showCloseTaskDialog = true
                        }
                    }
                }
            }) {
                Text(targetButtonStatus.name)
                    .font(.caption)
                    .foregroundColor(isLoading ? .gray.opacity(0.5) : .mainRed)
                    .frame(alignment: .leading)
            }
            .contentShape(Rectangle())
            .overlay(content: {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
            })
        }
    }

    // MARK: - Private method
    /// Возврашщает статус кнопки цели (сервенуть/развернуть/закрыть цель/открыть цель)
    private func targetButtonStatus(target: UserTargetDtoModel) -> TargetButtonStatus {
        if target.subTargets.isEmptyOrNil {
            if target.targetStatus?.isDone ?? false {
                return .toDone
            } else {
                return .toInProgress
            }
        } else {
            return $isExpanded.wrappedValue ? .turn : .expand
        }
    }
}

extension TargetRowView {
    enum TargetButtonStatus {
        /// свернуть подзадачи
        case turn
        /// Развернуть подзадачи
        case expand
        /// Закрыть задачу
        case toDone
        /// Открыть задачу
        case toInProgress
        
        var name: String {
            switch self {
            case .turn:
                return "Свернуть"
            case .expand:
                return "Развернуть"
            case .toDone:
                return "Открыть задачу вновь"
            case .toInProgress:
                return "Закрыть задачу"
            }
        }
    }
}



#Preview {
    TargetRowView<TargetsViewModel>(target: .init(title: "Test",
                                subTargets: [.init(title: "Test", targetSubStatus: .notDone)]))
        .environmentObject(TargetsViewModel())
}
