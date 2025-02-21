//
//  TargetRowView.swift
//  MMApp
//
//  Created by artem on 30.01.2025.
//

import SwiftUI

struct TargetRowView: View {
    @Binding var clusedSubTarget: UserSubTargetDtoModel?
    @Binding var clusedTarget: UserTargetDtoModel?
    
    @State private var showCloseTaskDialog = false
    
    @State private var showLongTapDialog = false
    
    
    @Binding var target: UserTargetDtoModel
    @State private var isExpanded: Bool = false
    @State private var isEditing: Bool = false
    
    @State private var isLoading = false
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Заголовок, дата, прогресс-бар
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text($target.title.wrappedValue.orEmpty)
                        .font(.subheadline)
                        .foregroundColor(.headerText)
                    Text("Срок выполнения: \(($target.deadLineDateTime.wrappedValue?.dateFromString ?? Date.now).formatted(date: .abbreviated, time: .shortened))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    let percentTarget: Double = (($target.subTargets.wrappedValue).isEmptyOrNil) ?
                    ((($target.targetStatus.wrappedValue?.isDone) ?? false) ? 100.0 : 0.0) :
                    $target.percentage.wrappedValue ?? 0.0
                    
                    ProgressView(value: percentTarget, total: 100)
                        .tint(.mainRed)
                }
                Spacer()
                Button(action: { isEditing = true }) {
                    Image(systemName: "pencil")
                        .foregroundColor(.mainRed)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
                .sheet(isPresented: $isEditing) {
                    TargetEditView(target: $target.wrappedValue)
                }
            }
            
            // Подцели
            if isExpanded {
                let subTargetsBinding = Binding($target.subTargets, default: [])
                ForEach(subTargetsBinding) { $subTarget in
                    SubTargetRowView(clusedSubTarget: $clusedSubTarget, subTarget: $subTarget)
                }
            }
            var targetButtonStatus = targetButtonStatus(target: target)
            
            // Кнопка "Развернуть/Свернуть" Открыть / Закрыть задачу
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                Button(action: {
                    withAnimation {
                        switch targetButtonStatus {
                        case .turn, .expand:
                            isExpanded.toggle()
                        case .toDone, .toInProgress:
                            showCloseTaskDialog = true
                        }
                    }
                }) {
                    
                    
                    Text(targetButtonStatus.name)
                        .font(.caption)
                        .foregroundColor(.mainRed)
                        .frame(alignment: .leading)
                }
                .contentShape(Rectangle())
                .alert(isPresented: $showCloseTaskDialog,
                       content: {
                    let title = (target.targetStatus?.isDone) ?? false ? "Вы хотите открыть цель?" : "Вы закрыли цель?"
                    return Alert(title: Text(title),
                                 primaryButton:
                            .default(Text("Да"), action: {
                                //                        subTarget.targetStatus = .done
                                isLoading = true
                                clusedTarget = target
                                print("Done")
                            }),
                                 secondaryButton:
                            .destructive(Text("Нет"), action: {
                                //                        subTarget.targetStatus = .inProgress
                                print("Not Done")
                            })
                    )
                })
            }

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
        .scaleEffect(isPressed ? 1.05 : 1.0) // Анимация масштаба
        .animation(.easeInOut(duration: 0.3), value: isPressed) // Анимация
        .onLongPressGesture(
            minimumDuration: 0.5, // Минимальная длительность нажатия
            pressing: { isPressing in
                withAnimation {
                    isPressed = isPressing // Обновляем состояние нажатия
                }
            },
            perform: {
                showLongTapDialog = true
            }
        )
//        .actionSheet(isPresented: $showLongTapDialog) {
//            ActionSheet(
//                title: Text("Действия с целью"),
//                buttons: [
//                    .default(Text("Изменить цель")) {
////                        selection = "Red"
//                    },
//
//                        .destructive(Text("Удалить цель")) {
////                        selection = "Green"
//                        },
//
//                        .cancel(Text("Отмена")) {
////                        selection = "Blue"
//                    },
//                ]
//            )
//        }
//        .confirmationDialog("Select a color", isPresented: $showLongTapDialog, titleVisibility: .visible) {
//            Button("Red") {
////                selection = "Red"
//            }
//
//            Button("Green") {
////                selection = "Green"
//            }
//
//            Button("Blue") {
////                selection = "Blue"
//            }
//        }

    }
    
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

extension Binding {
    init(_ source: Binding<Value?>, default defaultValue: Value) {
        self.init(
            get: { source.wrappedValue ?? defaultValue },
            set: { source.wrappedValue = $0 }
        )
    }
}
