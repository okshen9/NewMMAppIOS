//
//  SubTargetRowView.swift
//  MMApp
//
//  Created by artem on 30.01.2025.
//

import SwiftUI
import Combine

protocol SubTargetRowViewModelProtocol: ObservableObject {
    func closedSubTarget(_ target: UserSubTargetDtoModel)
    func closedSubTargetWithParent(_ subTarget: UserSubTargetDtoModel, closeParent: Bool)
    func addNewSubtarget(to parentTarget: UserTargetDtoModel, withName name: String)
}

struct SubTargetRowView<ViewModel: SubTargetRowViewModelProtocol>: View {
    @EnvironmentObject var viewModelEnvironment: ViewModel
    var myTarget = true
    
    // Состояние для работы с диалогами
    @State private var showConfirmationDialog = false {
        didSet {
            print("Состояние изменилось на: \(showConfirmationDialog)")
        }
    }
    @State private var showCustomAlert = false
    @State private var isClosingWholeTarget = true
    @State private var isLoading = false
    
    // Информация о подцели и родительской цели
    var subTarget: UserSubTargetDtoModel
    var parentTarget: UserTargetDtoModel? = nil
    
    // Определяем, является ли подцель последней незакрытой в цели
    var isLastUnclosedSubtarget: Bool {
        guard let parent = parentTarget, let subTargets = parent.subTargets else { return false }
        
        // Количество незакрытых подцелей, включая текущую
        let unclosedCount = subTargets.filter { $0.targetStatus != .done }.count
        
        // Если текущая подцель тоже не закрыта и она единственная такая, то она последняя
        return unclosedCount == 1 && subTarget.targetStatus != .done
    }
    
    var body: some View {
        VStack {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    Button(action: {
                        if myTarget {
                            if isLastUnclosedSubtarget {
                                showCustomAlert = true
                            } else {
                                showConfirmationDialog = true
                            }
                        }
                    }) {
                        Image(systemName: subTarget.targetStatus == .done ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(subTarget.targetStatus == .done ? .green : .gray)
                    }
                    .buttonStyle(.plain)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(subTarget.title.orEmpty)
                        .font(.headline)
                        .foregroundColor(.headerText)
                    Text("Срок выполнения: \((subTarget.deadLineDateTime?.dateFromString ?? Date.now).toDisplayString)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .padding(.vertical, 4)
        }
        .onChange(of: subTarget, {
            print("Изменилась subTarget")
            isLoading = false
        })
        .sheet(isPresented: $showCustomAlert) {
            VStack(spacing: 0) {
                // Заголовок
                Text("Завершение последней подцели")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.headerText)
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)
                    .padding(.horizontal, 16)
                
                // Сообщение
                Text("Это последняя незавершенная подцель. Что вы хотите сделать?")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
                    .padding(.horizontal, 16)
                
                // Разделитель
                Divider()
                    .padding(.top, 16)
                
                // Toggle
                Toggle("Завершить всю цель полностью", isOn: $isClosingWholeTarget)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .tint(.accentColor)
                
                Spacer()
                
                // Разделитель перед кнопками
                Divider()
                
                // Кнопки
                HStack(spacing: 0) {
                    Button("Отмена") {
                        showCustomAlert = false
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.secondary)
                    
                    Divider()
                        .frame(height: 44)
                    
                    Button("Подтвердить") {
                        isLoading = true
                        viewModelEnvironment.closedSubTargetWithParent(subTarget, closeParent: isClosingWholeTarget)
                        showCustomAlert = false
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.accentColor)
                    .fontWeight(.semibold)
                }
                .frame(height: 44)
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            .presentationDetents([.height(250)])
            .presentationDragIndicator(.visible)
            .interactiveDismissDisabled()
        }
        // Оставьте стандартный alert для обычных подцелей
        .alert(
            (subTarget.targetStatus?.isDone) ?? false ? "Вы хотите открыть эту подцель?" : "Вы закрыли эту подцель?",
            isPresented: $showConfirmationDialog
        ) {
            Button("Да") {
                isLoading = true
                viewModelEnvironment.closedSubTarget(subTarget)
            }
            Button("Нет", role: .cancel) {
                print("Отмена операции")
            }
        }
    }
}

#Preview {
    SubTargetRowView<TargetsViewModel>(
        subTarget: .init(title: "Test", targetSubStatus: .done),
        parentTarget: .init(title: "Parent Target")
    )
    .environmentObject(TargetsViewModel())
}
