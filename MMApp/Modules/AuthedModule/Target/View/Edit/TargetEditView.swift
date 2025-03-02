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
    @State var isLoading = false

    let target: UserTargetDtoModel

    var body: some View {
        NavigationView {
            Form {
                Section(header: headerView()) {
                    TextField("Название", text: $newTitle)
                    textEditor(textBinding: $newDescription)
                    DatePicker("Срок выполнения", selection: $newDeadline, displayedComponents: .date)
                }
                Section {
                    Button("Добавить подцель") {
                        // Добавить подцель
                    }
                }
            }
            .onAppear {
                newTitle = target.title.orEmpty
                newDescription = target.description.orEmpty
                newDeadline = target.deadLineDateTime?.dateFromString ?? Date.now
            }
        }
        
        
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
                Button(action: {
                    ///SAVE
                    //Neshko TODO
                    isLoading = true
                    print("SAVE")
                }, label: {
                    Image.init(systemName: "checkmark")
                        .resizable()
                        .tint(.mainRed)
                        .frame(width: 16,
                               height: 16)
                        .padding(4)
                })}
        }
    }
}

#Preview {
    TargetEditView(target: .init(title: "Test", targetStatus: .inProgress))
}
