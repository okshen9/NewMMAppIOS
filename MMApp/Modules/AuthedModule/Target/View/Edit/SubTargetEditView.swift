//
//  SubTargetEditView.swift
//  MMApp
//
//  Created by artem on 30.01.2025.
//

import SwiftUI

struct SubTargetEditView: View {
    @State private var newTitle = ""
    @State private var newDescription = ""
    @State private var newDeadline = Date()

    let subTarget: UserSubTarget

    var body: some View {
        Form {
            Section(header: Text("Редактирование подцели")) {
                TextField("Название", text: $newTitle)
                TextField("Описание", text: $newDescription)
                DatePicker("Дедлайн", selection: $newDeadline, displayedComponents: .date)
            }
        }
        .navigationTitle("Редактирование подцели")
        .onAppear {
            newTitle = subTarget.title
            newDescription = subTarget.description
            newDeadline = subTarget.deadLineDateTime
        }
    }
}
