//
//  TargetEditView.swift
//  MMApp
//
//  Created by artem on 30.01.2025.
//

import SwiftUI

protocol TargetEditViewProtocol: ObservableObject {
    func editTarget(_ target: UserTargetDtoModel) async -> UserTargetDtoModel?
}

struct TargetEditView<ViewModel: TargetEditViewProtocol>: View {
    @EnvironmentObject var viewModelEnvironment: ViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var newTitle = ""
    @State private var newDescription = ""
    @State private var newDeadline = Date()
    @State private var newCategory = TargetCategory.other
    @State private var newSubtarget = [UserSubTargetDtoModel]()
    @State var isLoading = false
    
    var target: UserTargetDtoModel
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: headerView()) {
                    TextField("Название", text: $newTitle)
                    textEditor(textBinding: $newDescription)
                    Picker("Категория цели", selection: $newCategory) {
                        ForEach(TargetCategory.allCases.filter({ $0 != .unknown })) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.mainRed)
                    DatePicker("Срок выполнения", selection: $newDeadline, displayedComponents: .date)
                }
                
                Text("Подцели")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(Color.gray.opacity(0.9))
                subTargetsSection()
                
            }
            .onAppear {
                newTitle = target.title.orEmpty
                newDescription = target.description.orEmpty
                newDeadline = target.deadLineDateTime?.dateFromString ?? Date.now
                newCategory = target.category ?? .other
                newSubtarget = target.subTargets ?? []
            }
        }
    }
    
    @ViewBuilder
    func subTargetsSection() -> some View {
        
        List {
            ForEach($newSubtarget, id: \.creationDateTime) { $item in
                SubTargetEditView(subTarget: $item)
                    .swipeActions(edge: .trailing) {
                        Button("Удалить") {
                            newSubtarget.removeAll(where: {
                                $0 == $item.wrappedValue
                            })
                        }
                        .tint(.red)
                    }
            }
            
            

        }
        Button(action: {
            
            newSubtarget.append(UserSubTargetDtoModel(title: "", description: "", targetSubStatus: .notDone, rootTargetId: target.id, creationDateTime: Date.now.toApiString, deadLineDateTime: Date.now.toApiString))
            print("Добавить \(newSubtarget.count)")
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
                Button(action: {
                    ///SAVE
                    //Neshko TODO
                    isLoading = true
                    var newTarget = target
                    newTarget.update(newTitle, newDescription, newDeadline.toApiString, newCategory)
                    Task {
                        if await viewModelEnvironment.editTarget(newTarget) != nil {
                            
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
                            .foregroundColor(.mainRed)
                        Image.init(systemName: "checkmark")
                            .resizable()
                            .foregroundColor(.mainRed)
                            .frame(width: 16,
                                   height: 16)
                            .padding(4)
                    }
                })}
        }
    }
}

#Preview {
    TargetEditView<TargetsViewModel>(target: .init(title: "Test",
                                                   targetStatus: .inProgress,
                                                   subTargets: [.init(title: "TestSub", targetSubStatus: .notDone, creationDateTime: Date.now.toApiString)]
                                                  ))
        .environmentObject(TargetsViewModel())
}
