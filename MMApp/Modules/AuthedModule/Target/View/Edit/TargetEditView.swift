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

    let target: UserTarget

    var body: some View {
        Form {
            Section(header: Text("Редактирование цели")) {
                TextField("Название", text: $newTitle)
                TextField("Описание", text: $newDescription)
                DatePicker("Дедлайн", selection: $newDeadline, displayedComponents: .date)
            }

            Section {
                Button("Добавить подцель") {
                    // Добавить подцель
                }
            }
        }
        .navigationTitle("Редактирование цели")
        .onAppear {
            newTitle = target.title
            newDescription = target.description
            newDeadline = target.deadLineDateTime
        }
    }
}
