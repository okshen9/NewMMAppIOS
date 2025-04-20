//
//  AddTargetView.swift
//  MMApp
//
//  Created by artem on 30.01.2025.
//

import Foundation
import SwiftUI

struct AddTargetView: View {
    let category: TargetCategory // Категория, переданная из CategoryEditView
    var onSave: (UserTargetDtoModel) -> Void // Замыкание для сохранения новой цели
    @Environment(\.dismiss) private var dismiss
    
    // Состояние для основной цели
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var deadLineDateTime: Date = Date()
    
    // Состояние для подцелей
    @State private var subTargets: [UserSubTargetDtoModel] = []
    @State private var newSubTargetTitle: String = ""
    @State private var newSubTargetDescription: String = ""
    @State private var newSubTargetDeadline: Date = Date()
    
    var body: some View {
        // Neshko TODO
        NavigationView {
            Form {
                // Секция для основной цели
                Section(header: Text("Основная цель")) {
                    TextField("Название цели", text: $title)
                    TextField("Описание цели", text: $description)
                    DatePicker("Срок выполнения", selection: $deadLineDateTime, displayedComponents: [.date, .hourAndMinute])
                }
                
                // Секция для добавления подцелей
                Section(header: Text("Подцели")) {
                    ForEach($subTargets.indices, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 4) {
                            Text($subTargets[index].title.wrappedValue.orEmpty)
                                .font(.headline)
                            Text($subTargets[index].description.wrappedValue.orEmpty)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            let date = $subTargets[index].deadLineDateTime.wrappedValue?.dateFromString ?? Date.now
                            let text = "Дедлайн: \((date).formatted(date: .abbreviated, time: .shortened))"
                            Text(text) // Используем wrappedValue
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
//                    // Форма для добавления новой подцели
                    Group {
                        TextField("Название подцели", text: $newSubTargetTitle)
                        TextField("Описание подцели", text: $newSubTargetDescription)
                        DatePicker("Срок выполнения подцели", selection: $newSubTargetDeadline, displayedComponents: [.date, .hourAndMinute])
                        
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
        let newSubTarget = UserSubTargetDtoModel(
            id: subTargets.count + 1, // Временный ID (в реальном приложении это должно генерироваться на сервере)
            title: newSubTargetTitle,
            description: newSubTargetDescription,
            subTargetPercentage: 100.0/Double(subTargets.count + 1), // значение размера таргета
            targetSubStatus: .notDone, // Статус по умолчанию
            rootTargetId: 0, // Временное значение (будет обновлено после сохранения основной цели)
            isDeleted: false,
            creationDateTime: Date().toApiString,
            lastUpdatingDateTime: Date().toApiString,
            deadLineDateTime: newSubTargetDeadline.toApiString
        )
        subTargets.append(newSubTarget)
        
        // Очищаем поля после добавления
        newSubTargetTitle = ""
        newSubTargetDescription = ""
        newSubTargetDeadline = Date()
    }
    
    // Сохранение основной цели
    private func saveTarget() {
        for (index, _) in subTargets.enumerated() {
            subTargets[index].subTargetPercentage = 100.0/Double(subTargets.count)
        }
        let newTarget = UserTargetDtoModel(
            id: 0, // Временный ID (в реальном приложении это должно генерироваться на сервере)
            title: title,
            description: description,
            userExternalId: 1, // Временное значение (должно быть передано из контекста пользователя)
            percentage: 0, // Начальный прогресс
            deadLineDateTime: deadLineDateTime.toApiString,
            streamId: 1, // Временное значение (должно быть передано из контекста)
            targetStatus: .draft, // Статус по умолчанию
            subTargets: subTargets,
            isDeleted: false,
            creationDateTime: Date().toApiString,
            lastUpdatingDateTime: Date().toApiString,
            category: category
        )
        onSave(newTarget)
    }
}

//#Preview {
//    AddTargetView(category: .family, onSave: {_ in })
//}

