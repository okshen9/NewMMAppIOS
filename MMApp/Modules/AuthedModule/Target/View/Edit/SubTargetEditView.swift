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

    @Binding var subTarget: UserSubTargetDtoModel

    var body: some View {
        Form {
            Section() {
        VStack {
            TextField("Название", text: $newTitle)
            TextField("Описание", text: $newDescription)
            DatePicker("Срок выполнения", selection: $newDeadline, displayedComponents: .date)
                        }
                    }
                    .navigationTitle("Подцель")
        }
        .onAppear {
            newTitle = subTarget.title.orEmpty
            newDescription = subTarget.description.orEmpty
            newDeadline = subTarget.deadLineDateTime?.dateFromString ?? Date.now
        }
    }
}
