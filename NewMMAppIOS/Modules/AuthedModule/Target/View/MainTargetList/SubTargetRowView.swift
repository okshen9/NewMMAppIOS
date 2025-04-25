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

    @Binding var showDescription: Bool

    // Состояние для работы с диалогами
    @State private var showConfirmationDialog = false
    @State private var showCustomAlert = false
    @State private var isClosingWholeTarget = true
    @State private var isLoading = false


    // Информация о подцели и родительской цели
    var subTarget: UserSubTargetDtoModel
    var parentTarget: UserTargetDtoModel? = nil
    
    // Определяем, является ли подцель последней незакрытой в цели
    var isLastUnclosedSubtarget: Bool {
        guard let parent = parentTarget, let subTargets = parent.subTargets else { return false }
        let unclosedCount = subTargets.filter { $0.targetStatus != .done }.count
        return unclosedCount == 1 && subTarget.targetStatus != .done
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
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
                            .imageScale(.large)
                    }
                    .buttonStyle(.plain)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(subTarget.title.orEmpty)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.headerText)

                        Spacer()
                    }

                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .foregroundColor(.gray)
                            .imageScale(.small)

                        Text((subTarget.deadLineDateTime?.dateFromString ?? Date.now).toDisplayString)
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                    }
                }
            }

            if showDescription {
                if let description = subTarget.description, !description.isEmpty {
                    Text(description)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
//                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .background(Color(.systemGray6))
                        .cornerRadius(6)
                        .padding(.leading, 32)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onChange(of: subTarget, {
            isLoading = false
        })
        .sheet(isPresented: $showCustomAlert) {
            VStack(spacing: 0) {
                Text("Завершение последней подцели")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.headerText)
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)
                    .padding(.horizontal, 16)
                
                Text("Это последняя незавершенная подцель. Что вы хотите сделать?")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
                    .padding(.horizontal, 16)
                
                Divider()
                    .padding(.top, 16)
                
                Toggle("Завершить всю цель полностью", isOn: $isClosingWholeTarget)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .tint(.accentColor)
                
                Spacer()
                
                Divider()
                
                HStack {
                    Button(action: {
                        showCustomAlert = false
                    }) {
                        Text("Отмена")
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                    }
                    
                    Divider()
                    
                    Button(action: {
                        isLoading = true
                        viewModelEnvironment.closedSubTargetWithParent(subTarget, closeParent: isClosingWholeTarget)
                        showCustomAlert = false
                    }) {
                        Text("Подтвердить")
                            .bold()
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 44)
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .padding()
        }
        .alert("Завершить подцель?", isPresented: $showConfirmationDialog) {
            Button("Да") {
                isLoading = true
                viewModelEnvironment.closedSubTarget(subTarget)
            }
            Button("Нет", role: .cancel) { }
        }
    }
}

#Preview {
    @Previewable @State var showDescription: Bool = false
    SubTargetRowView<TargetsViewModel>(
        showDescription: $showDescription,
        subTarget: .init(
            title: "Test",
            description: "Тестовое описание подцели",
            targetSubStatus: .done
        ),
        parentTarget: .init(title: "Parent Target")
    )
    .environmentObject(TargetsViewModel())
}
