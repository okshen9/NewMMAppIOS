//
//  TargetEditView.swift
//  MMApp
//
//  Created by artem on 30.01.2025.
//

import SwiftUI

protocol TargetEditViewProtocol: ObservableObject {
    func saveTarget(_ target: UserTargetDtoModel, isCreateTarget: Bool) async -> UserTargetDtoModel?
}

struct TargetEditView<ViewModel: TargetEditViewProtocol>: View {
    @EnvironmentObject var viewModelEnvironment: ViewModel
    @Environment(\.dismiss) var dismiss

    @State var isLoading = false
    
    var target: UserTargetDtoModel
    var isCreateTarget: Bool
    @State private var newTarget: UserTargetDtoModel
    
    init(target: UserTargetDtoModel, isCreateTarget: Bool) {
        self.target = target
        self.isCreateTarget = isCreateTarget
        _newTarget = State(initialValue: target)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: headerView()) {
                    TextField("Название", text: $newTarget.title.orEmpty)
                        .foregroundStyle(Color.black.opacity(0.8))
                    textEditor(textBinding: $newTarget.description.orEmpty)
                        .foregroundStyle(Color.black.opacity(0.8))
                    Picker("Категория цели", selection:  $newTarget.category.orDefault(.other)) {
                        ForEach(TargetCategory.allCases.filter({ $0 != .unknown })) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.mainRed)
                    DatePicker("Срок выполнения", selection: $newTarget.deadLineDateTime.asBindingDate, displayedComponents: .date)
                }
                
                Text("Подцели")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(Color.black.opacity(0.9))
                subTargetsSection()
                
            }
        }
    }
    
    @ViewBuilder
    func subTargetsSection() -> some View {
        List {
            ForEach($newTarget.subTargets.orDefault([]), id: \.creationDateTime) { $item in
                SubTargetEditView(subTarget: $item)
                    .padding(.vertical, 4)
                    .swipeActions(edge: .trailing) {
                        Button("Удалить") {
                            newTarget.subTargets?.removeAll(where: {
                                $0 == $item.wrappedValue
                            })
                        }
                        .tint(.red)
                    }
            }
        }
        
        Button(action: {
            if newTarget.subTargets == nil {
                newTarget.subTargets = []
            }
            newTarget.subTargets?.append(UserSubTargetDtoModel(title: "", description: "", targetSubStatus: .notDone, rootTargetId: target.id, creationDateTime: Date.now.toApiString, deadLineDateTime: Date.now.toApiString))
            print("Добавить \(newTarget.subTargets?.count)")
        }, label: {
            Text("Добавить подцель")
                .foregroundColor(.mainRed)
        })
    }
    
    /// Многострочное текстовое поле
    @ViewBuilder
    func textEditor(title: String = "Описание цели",
                    textBinding: Binding<String>) -> some View {
        ZStack(alignment: .topLeading) {
            if textBinding.wrappedValue.isEmpty {
                Text(title)
                    .foregroundColor(.gray)
                    .padding(4)
            }
            TextEditor(text: textBinding)
                .frame(height: 100)
        }
    }
    
    /// Хежер экрана
    @ViewBuilder
    func headerView() -> some View {
        HStack {
            Text("Редактирование цели")
            Spacer()
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .frame(width: 16,
                           height: 16)
                    .padding(4)
            } else {
                let isActive = target != $newTarget.wrappedValue
                Button(action: {
                    ///SAVE
                    isLoading = true
                    Task {
                        if await viewModelEnvironment.saveTarget(newTarget, isCreateTarget: isCreateTarget) != nil {
                            
                            isLoading = false
                            ToastManager.shared.show(
                                //                                🎯
                                ToastModel(message: "Цель успешно отправлена на рассмотерение", icon: "checkmark.circle", duration: 2)
                            )
                            dismiss()
                        } else {
                            ToastManager.shared.show(
                                ToastModel(message: "Ошибка изменения цели", icon: "xmark", duration: 2)
                            )
                            isLoading = false
                        }
                    }
                }, label: {
                    HStack(spacing: 0) {
                        Text("Готово")
                            .font(.caption.weight(.medium))
                            .foregroundColor(isActive ? .mainRed : .gray)
                        Image.init(systemName: "checkmark")
                            .resizable()
                            .foregroundColor(isActive ? .mainRed : .gray)
                            .frame(width: 16,
                                   height: 16)
                            .padding(4)
                    }
                })
                .disabled(!isActive)
            }
        }
    }
}

#Preview {
    TargetEditView<TargetsViewModel>(target: .init(title: "Test",
                                                   targetStatus: .inProgress,
                                                   subTargets: [.init(title: "TestSub", targetSubStatus: .notDone, creationDateTime: Date.now.toApiString)]
                                                  ), isCreateTarget: false)
        .environmentObject(TargetsViewModel())
}

