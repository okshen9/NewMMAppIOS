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
    
    // Состояние для новой подцели
    @State private var showAddSubtarget: Bool = false
    @State private var newSubTargetTitle: String = ""
    @State private var newSubTargetDescription: String = ""
    @State private var newSubTargetDeadline: Date = Date().addingTimeInterval(86400 * 7)
    
    // Валидация
    @State private var showValidationAlert: Bool = false
    @State private var validationMessage: String = ""
    
    init(target: UserTargetDtoModel, isCreateTarget: Bool) {
        self.target = target
        self.isCreateTarget = isCreateTarget
        _newTarget = State(initialValue: target)
    }
    
    // Инициализатор для создания новой цели с опциональной категорией
    init(category: TargetCategory? = nil, isCreateTarget: Bool = true) {
        let newEmptyTarget = UserTargetDtoModel(
            title: "",
            description: "",
            userExternalId: UserRepository.shared.externalId,
            percentage: 0,
            deadLineDateTime: Date().addingTimeInterval(86400 * 7).toApiString,
            targetStatus: .draft,
            subTargets: nil,
            category: category ?? .personal
        )
        self.target = newEmptyTarget
        self.isCreateTarget = isCreateTarget
        _newTarget = State(initialValue: newEmptyTarget)
    }
    
    private var isFormValid: Bool {
        !newTarget.title.orEmpty.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: headerView()) {
                    TextField("Название", text: $newTarget.title.orEmpty)
                        .foregroundStyle(Color.headerText)
                    TextEditorWithPalceHolder(palceHolder: "Описание подцели", textBinding: $newTarget.description.orEmpty)
                        .foregroundStyle(Color.headerText)
                    Picker("Категория цели", selection: $newTarget.category.orDefault(.other)) {
                        ForEach(TargetCategory.allCases.filter({ $0 != .unknown })) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.mainRed)

                    DatePicker("Срок выполнения", selection: $newTarget.deadLineDateTime.asBindingDate, displayedComponents: .date)
                        
                        .tint(.mainRed)
                        .foregroundStyle(Color.headerText)
                        
                }
                
                Section(header: Text("Подцели")
                    .font(.headline)
                    .foregroundStyle(Color.black.opacity(0.9))) {
                    subTargetsSection()
                }
            }
            .alert("Ошибка", isPresented: $showValidationAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(validationMessage)
            }
        }
        .navigationTitle(isCreateTarget ? "Создание цели" : "Редактирование цели")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    func subTargetsSection() -> some View {
        if let subTargets = newTarget.subTargets, !subTargets.isEmpty {
            ForEach($newTarget.subTargets.orDefault([]), id: \.creationDateTime) { $item in
                SubTargetEditView(subTarget: $item)
                    .padding(.vertical)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive, action: {
                            if let index = newTarget.subTargets?.firstIndex(of: item) {
                                newTarget.subTargets?.remove(at: index)
                            }
                        }) {
                            Label("Удалить", systemImage: "trash")
                        }

                        .tint(.red)
                    }
            }
        }
        
        Button(action: {
            addNewSubTarget()
        }, label: {
            Label("Добавить подцель", systemImage: "plus.circle")
                .foregroundColor(.mainRed)
        })
    }
    
    /// Хежер экрана
    @ViewBuilder
    func headerView() -> some View {
        HStack {
            Text(isCreateTarget ? "Создание цели" : "Редактирование цели")
                .font(Font.subheadline)
                .foregroundStyle(Color.headerText)
            Spacer()
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .frame(width: 16,
                           height: 16)
                    .padding(4)
            } else {
                let isActive = isCreateTarget || target != $newTarget.wrappedValue
                Button(action: {
                    if validateForm() {
                        saveTarget()
                    } else {
                        showValidationAlert = true
                    }
                }, label: {
                    HStack(spacing: 0) {
                        Text("Готово")
                            .font(.caption.weight(.medium))
                            .foregroundColor(isActive ? .mainRed : .gray)
                        Image(systemName: "checkmark")
                            .resizable()
                            .foregroundColor(isActive ? .mainRed : .gray)
                            .frame(width: 16,
                                   height: 16)
                            .padding(4)
                    }
                })
                .disabled(!isActive || !isFormValid)
            }
        }
    }
    
    // MARK: - Вспомогательные методы
    private func addNewSubTarget() {
        if newTarget.subTargets == nil {
            newTarget.subTargets = []
        }
        
        let newSubTarget = UserSubTargetDtoModel(
            title: "",
            description: "",
            subTargetPercentage: 0.0,
            targetSubStatus: .notDone,
            rootTargetId: target.id,
            creationDateTime: Date.now.toApiString, 
            deadLineDateTime: Date.now.toApiString
        )
        
        newTarget.subTargets?.append(newSubTarget)
    }
    
    private func validateForm() -> Bool {
        if newTarget.title.orEmpty.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationMessage = "Название цели не может быть пустым"
            return false
        }
        
        if let deadlineDate = newTarget.deadLineDateTime?.dateFromApiString, deadlineDate < Date() {
            validationMessage = "Срок выполнения не может быть раньше текущей даты"
            return false
        }
        
        return true
    }
    
    private func saveTarget() {
        // Нормализация данных перед сохранением
        newTarget.title = newTarget.title.orEmpty.trimmingCharacters(in: .whitespacesAndNewlines)
        newTarget.description = newTarget.description?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Равномерное распределение процентов между подцелями
        if let subTargets = newTarget.subTargets, !subTargets.isEmpty {
            for (index, _) in subTargets.enumerated() {
                newTarget.subTargets?[index].subTargetPercentage = 100.0 / Double(subTargets.count)
            }
        }
        
        isLoading = true
        Task {
            if await viewModelEnvironment.saveTarget(newTarget, isCreateTarget: isCreateTarget) != nil {
                isLoading = false
                await ToastManager.shared.show(
                    ToastModel(message: isCreateTarget ? "Цель успешно создана" : "Цель успешно отредактирована", icon: "checkmark.circle", duration: 2)
                )
                dismiss()
            } else {
                await ToastManager.shared.show(
                    ToastModel(message: "Ошибка сохранения цели", icon: "xmark", duration: 2)
                )
                isLoading = false
            }
        }
    }
}

#Preview {
    Group {
        TargetEditView<TargetsViewModel>(target: .init(title: "Test",
                                                   targetStatus: .inProgress,
                                                   subTargets: [.init(title: "TestSub", targetSubStatus: .notDone, creationDateTime: Date.now.toApiString)]
                                                  ), isCreateTarget: false)
            .environmentObject(TargetsViewModel())
        
//        TargetEditView<TargetsViewModel>(category: .family, isCreateTarget: true)
//            .environmentObject(TargetsViewModel())
    }
}

