//
//  TargetEditView.swift
//  MMApp
//
//  Created by artem on 30.01.2025.
//

import SwiftUI

struct TargetEditView: View {
    @State private var newTitle = ""
    @State private var newDescription = ""
    @State private var newDeadline = Date()

    let target: UserTargetDtoModel

    var body: some View {
        Form {
            Section(header: Text("Редактирование цели")) {
                TextField("Название", text: $newTitle)
                TextField("Описание", text: $newDescription)
                DatePicker("Срок выполнения", selection: $newDeadline, displayedComponents: .date)
            }

            Section {
                Button("Добавить подцель") {
                    // Добавить подцель
                }
            }
        }
        .navigationTitle("Редактирование цели")
        .onAppear {
            newTitle = target.title.orEmpty
            newDescription = target.description.orEmpty
            newDeadline = target.deadLineDateTime?.dateFromString ?? Date.now
        }
    }
}
