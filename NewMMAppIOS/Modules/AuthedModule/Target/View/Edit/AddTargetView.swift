//
//  AddTargetView.swift
//  MMApp
//
//  Created by artem on 30.01.2025.
//

import Foundation
import SwiftUI

struct AddTargetView: View {
    // Опциональная категория с дефолтным значением
    var category: TargetCategory? = nil
    var onSave: (UserTargetDtoModel) -> Void // Замыкание для сохранения новой цели
    @Environment(\.dismiss) private var dismiss
    
    // Состояние для основной цели
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var deadLineDateTime: Date = Date().addingTimeInterval(86400 * 7) // Дедлайн через неделю по умолчанию
    @State private var selectedCategory: TargetCategory = .personal
    
    // Состояние для подцелей
    @State private var subTargets: [UserSubTargetDtoModel] = []
    @State private var showAddSubtarget: Bool = false
    @State private var newSubTargetTitle: String = ""
    @State private var newSubTargetDescription: String = ""
    @State private var newSubTargetDeadline: Date = Date().addingTimeInterval(86400 * 7)
    
    // Валидация
    @State private var showValidationAlert: Bool = false
    @State private var validationMessage: String = ""
    
    // Отслеживание изменений для кнопки сохранения
    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Секция для основной цели
                Section(header: Text("Основная цель")) {
                    TextField("Название цели", text: $title)
                        .submitLabel(.next)
                    TextField("Описание цели", text: $description, axis: .vertical)
                        .submitLabel(.next)
                        .lineLimit(3...6)
                    
                    Picker("Категория", selection: $selectedCategory) {
                        ForEach(TargetCategory.allCases.filter { $0 != .unknown }, id: \.self) { category in
                            Text(category.rawValue)
                                .tag(category)
                        }
                    }
                    
                    DatePicker("Срок выполнения", selection: $deadLineDateTime, in: Date()..., displayedComponents: [.date])
                }
                
                // Секция для подцелей
                Section(header: Text("Подцели")) {
                    ForEach(subTargets.indices, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(subTargets[index].title.orEmpty)
                                .font(.subheadline.bold())
                            
                            if let desc = subTargets[index].description, !desc.isEmpty {
                                Text(desc)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            let date = subTargets[index].deadLineDateTime?.dateFromApiString ?? deadLineDateTime
                            Text("Срок: \(date.formatted(date: .abbreviated, time: .omitted))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                subTargets.remove(at: index)
                            } label: {
                                Label("Удалить", systemImage: "trash")
                            }
                        }
                    }
                    
                    Button(action: {
                        showAddSubtarget = true
                    }) {
                        Label("Добавить подцель", systemImage: "plus.circle")
                    }
                }
            }
            .navigationTitle("Создание цели")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        if validateForm() {
                            saveTarget()
                        } else {
                            showValidationAlert = true
                        }
                    }
                    .disabled(!isFormValid)
                }
            }
            .sheet(isPresented: $showAddSubtarget) {
                addSubtargetView()
            }
            .alert("Ошибка", isPresented: $showValidationAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(validationMessage)
            }
        }
    }
    
    // MARK: - Подцель
    @ViewBuilder
    private func addSubtargetView() -> some View {
        NavigationView {
            Form {
                Section(header: Text("Информация о подцели")) {
                    TextField("Название", text: $newSubTargetTitle)
                    
                    TextField("Описание", text: $newSubTargetDescription, axis: .vertical)
                        .lineLimit(3...6)
                    
                    DatePicker("Срок выполнения", selection: $newSubTargetDeadline, in: Date()..., displayedComponents: [.date])
                }
            }
            .navigationTitle("Новая подцель")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        resetSubtargetForm()
                        showAddSubtarget = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Добавить") {
                        if !newSubTargetTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            addSubtarget()
                            showAddSubtarget = false
                        }
                    }
                    .disabled(newSubTargetTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    // MARK: - Вспомогательные методы
    private func addSubtarget() {
        let newSubtarget = UserSubTargetDtoModel(
            title: newSubTargetTitle.trimmingCharacters(in: .whitespacesAndNewlines),
            description: newSubTargetDescription.trimmingCharacters(in: .whitespacesAndNewlines),
            subTargetPercentage: 0.0,
            targetSubStatus: .notDone,
            deadLineDateTime: newSubTargetDeadline.toApiString
        )
        
        subTargets.append(newSubtarget)
        resetSubtargetForm()
    }
    
    private func resetSubtargetForm() {
        newSubTargetTitle = ""
        newSubTargetDescription = ""
        newSubTargetDeadline = Date().addingTimeInterval(86400 * 7)
    }
    
    private func validateForm() -> Bool {
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationMessage = "Название цели не может быть пустым"
            return false
        }
        
        if deadLineDateTime < Date() {
            validationMessage = "Срок выполнения не может быть раньше текущей даты"
            return false
        }
        
        return true
    }
    
    private func saveTarget() {
        // Нормализация данных перед сохранением
        let normalizedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Равномерное распределение процентов между подцелями
        for (index, _) in subTargets.enumerated() {
            subTargets[index].subTargetPercentage = subTargets.isEmpty ? 0 : 100.0 / Double(subTargets.count)
        }
        
        let newTarget = UserTargetDtoModel(
            title: normalizedTitle,
            description: normalizedDescription,
            userExternalId: UserRepository.shared.externalId,
            percentage: 0,
            deadLineDateTime: deadLineDateTime.toApiString,
            targetStatus: .draft,
            subTargets: subTargets.isEmpty ? nil : subTargets,
            category: selectedCategory
        )
        
        onSave(newTarget)
        dismiss()
    }
}

//#Preview {
//    AddTargetView(category: .family, onSave: {_ in })
//}

