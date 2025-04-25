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
    @State private var showCloseTaskDialog = false
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
    /// Показать описание
    @State private var showDescription: Bool = false
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Основной контент цели
//            Button(action: {
//                withAnimation(.spring(response: 0.1, dampingFraction: 3.8)) {
//                    showDescription.toggle()
//                    isExpanded.toggle()
//                }
//            }) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(target.title.orEmpty)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.headerText)
                            .multilineTextAlignment(.leading)

                        Spacer()
                        if let subTargets = target.subTargets,
                           !subTargets.isEmpty,
                           let description = target.description,
                           !description.isEmpty {
                            Image(systemName: showDescription ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                                .foregroundColor(.gray)
                                .imageScale(.small)
                        }
                    }

                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .foregroundColor(.gray)
                            .imageScale(.small)

                        Text((target.deadLineDateTime?.dateFromApiString ?? Date.now).toDisplayString)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)

                        if let percentage = target.percentage, percentage > 0 {
                            Spacer()
                            Text("\(Int(percentage))%")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(percentage == 100 ? .green : .gray)
                        }
                    }

                    let percentTarget: Double = ((target.subTargets).isEmptyOrNil) ?
                    (((target.targetStatus?.isDone) ?? false) ? 100.0 : 0.0) :
                    target.percentage ?? 0.0

                    ProgressView(value: percentTarget, total: 100)
                        .tint(percentTarget == 100 ? .green : .mainRed)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(4)
                }
                .background(.white)
//            }
            .buttonStyle(PlainButtonStyle())

            // Описание цели
            VStack(alignment: .leading, spacing: 8) {
                if showDescription,
                   let description = target.description,
                   !description.isEmpty {
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
//                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }



                // Подцели
                if isExpanded,
                   let subTargets = target.subTargets,
                   !subTargets.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Divider()

                        Text("Подцели")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.headerText)
                            .padding(.top, 4)

                        ForEach(subTargets) { subTarget in
                            SubTargetRowView<TargetsViewModel>(
                                myTarget: myTarget,
                                showDescription: $showDescription,
                                subTarget: subTarget,
                                parentTarget: target
                            )
                        }
                    }
                    .padding(.top, 4)
                }

                // Кнопка для отображения подцелей
                //                    if let subTargets = target.subTargets, !subTargets.isEmpty {
                //                        Button(action: {
                //                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                //                                isExpanded.toggle()
                //                            }
                //                        }) {
                //                            HStack {
                //                                Text(isExpanded ? "Скрыть подцели" : "Показать подцели")
                //                                    .font(.system(size: 14, weight: .medium))
                //                                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                //                            }
                //                            .foregroundColor(.mainRed)
                //                        }
                //                        .padding(.top, 4)
                //                    }
            }
                .transition(.opacity.combined(with: .identity))
                        /*.move(edge: .trailing)))*/

            // Закрыть цель
            if let isDone = target.targetStatus?.isDone {
                HStack {
                    Spacer()
                    Button(
                        action: {
                            showCloseTaskDialog = true
                        }, label: {
                            Text(isDone ? "Переоткрыть цель" : "Закрыть цель")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.mainRed)
                        })
                }
            }
        }
        .padding(8)
        .background(Color(.systemBackground))
        .contentShape(Rectangle())
        .onChange(of: target, {
            isLoading = false
        })
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isPressed)
        .onTapGesture {
            withAnimation(.spring(response: 0.1, dampingFraction: 3.8)) {
                showDescription.toggle()
                isExpanded.toggle()
            }
        }
        .onLongPressGesture(
            minimumDuration: 0.5,
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
                    .default(Text("Изменить цель")
                        .foregroundStyle(Color(.systemBlue))) {
                        isEditing = true
                    },
                    .destructive(Text("Удалить цель")) {
                        viewModelEnvironment.deleteTarget(target: target)
                    },
                    .cancel(Text("Отмена"))
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
            }
            Button("Нет", role: .cancel) { }
        }
        .sheet(isPresented: $isEditing) {
            TargetEditView<TargetsViewModel>(target: target, isCreateTarget: false)
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
    TargetRowView<TargetsViewModel>(target: .init(
        title: "Test",
        description: "Тестовое описание цели khbhhjbkjhkghjvkgvkgvkgvcgc,hgvm kgk kv jghvlvhj,,b",
        subTargets: [.init(title: "Test", description: "dssds",targetSubStatus: .notDone)]
    ))
    .environmentObject(TargetsViewModel())
}
