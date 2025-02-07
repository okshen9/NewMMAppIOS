//
//  AddTargetView.swift
//  MMApp
//
//  Created by artem on 30.01.2025.
//

import Foundation
import SwiftUI

struct AddTargetView: View {
    let category: UserTarget.Category // Категория, переданная из CategoryEditView
    var onSave: (UserTarget) -> Void // Замыкание для сохранения новой цели
    @Environment(\.dismiss) private var dismiss
    
    // Состояние для основной цели
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var deadLineDateTime: Date = Date()
    
    // Состояние для подцелей
    @State private var subTargets: [UserSubTarget] = []
    @State private var newSubTargetTitle: String = ""
    @State private var newSubTargetDescription: String = ""
    @State private var newSubTargetDeadline: Date = Date()
    
    var body: some View {
        NavigationView {
            Form {
                // Секция для основной цели
                Section(header: Text("Основная цель")) {
                    TextField("Название цели", text: $title)
                    TextField("Описание цели", text: $description)
                    DatePicker("Дедлайн", selection: $deadLineDateTime, displayedComponents: [.date, .hourAndMinute])
                }
                
                // Секция для добавления подцелей
                Section(header: Text("Подцели")) {
                    ForEach(subTargets) { subTarget in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(subTarget.title)
                                .font(.headline)
                            Text(subTarget.description)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("Дедлайн: \(subTarget.deadLineDateTime.formatted(date: .abbreviated, time: .shortened))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // Форма для добавления новой подцели
                    Group {
                        TextField("Название подцели", text: $newSubTargetTitle)
                        TextField("Описание подцели", text: $newSubTargetDescription)
                        DatePicker("Дедлайн подцели", selection: $newSubTargetDeadline, displayedComponents: [.date, .hourAndMinute])
                        
                        Button(action: addSubTarget) {
                            Text("Добавить подцель")
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .disabled(newSubTargetTitle.isEmpty || newSubTargetDescription.isEmpty) // Кнопка неактивна, если поля пустые
                    }
                }
            }
            .navigationTitle("Новая цель")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        saveTarget()
                        dismiss()
                    }
                    .disabled(title.isEmpty || description.isEmpty) // Кнопка "Готово" неактивна, если поля пустые
                }
            }
        }
    }
    
    // Добавление подцели
    private func addSubTarget() {
        let newSubTarget = UserSubTarget(
            id: subTargets.count + 1, // Временный ID (в реальном приложении это должно генерироваться на сервере)
            title: newSubTargetTitle,
            description: newSubTargetDescription,
            subTargetPercentage: 0, // Начальный прогресс
            targetStatus: "active", // Статус по умолчанию
            rootTargetId: 0, // Временное значение (будет обновлено после сохранения основной цели)
            isDeleted: false,
            creationDateTime: Date(),
            lastUpdatingDateTime: Date(),
            deadLineDateTime: newSubTargetDeadline
        )
        subTargets.append(newSubTarget)
        
        // Очищаем поля после добавления
        newSubTargetTitle = ""
        newSubTargetDescription = ""
        newSubTargetDeadline = Date()
    }
    
    // Сохранение основной цели
    private func saveTarget() {
        let newTarget = UserTarget(
            id: 0, // Временный ID (в реальном приложении это должно генерироваться на сервере)
            title: title,
            description: description,
            userExternalId: 1, // Временное значение (должно быть передано из контекста пользователя)
            percentage: 0, // Начальный прогресс
            deadLineDateTime: deadLineDateTime,
            streamId: 1, // Временное значение (должно быть передано из контекста)
            targetStatus: "active", // Статус по умолчанию
            subTargets: subTargets,
            isDeleted: false,
            creationDateTime: Date(),
            lastUpdatingDateTime: Date(),
            category: category
        )
        onSave(newTarget)
    }
}

#Preview {
    AddTargetView(category: .family, onSave: {_ in })
}

