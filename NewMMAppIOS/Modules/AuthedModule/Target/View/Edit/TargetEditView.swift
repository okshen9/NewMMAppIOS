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
    @StateObject private var viewModel: TargetEditViewModel
    
    @State var isLoading = false
    @State private var showDismissAlert = false
    
    var target: UserTargetDtoModel
    var isCreateTarget: Bool
    
    init(target: UserTargetDtoModel, isCreateTarget: Bool) {
        self.target = target
        self.isCreateTarget = isCreateTarget
        _viewModel = StateObject(wrappedValue: TargetEditViewModel(target: target, isCreateTarget: isCreateTarget))
    }
    
    // Инициализатор для создания новой цели с опциональной категорией
    init(category: TargetCategory? = nil, isCreateTarget: Bool = true) {
        let newEmptyTarget = UserTargetDtoModel(
            title: "",
            description: "",
            userExternalId: UserRepository.snapshot.externalId,
            percentage: 0,
            deadLineDateTime: Date().addingTimeInterval(86400 * 7).toApiString,
            targetStatus: .draft,
            subTargets: nil,
            category: category ?? .personal
        )
        self.target = newEmptyTarget
        self.isCreateTarget = isCreateTarget
        _viewModel = StateObject(wrappedValue: TargetEditViewModel(target: newEmptyTarget, isCreateTarget: isCreateTarget))
    }
    
	var body: some View {
		NavigationStack {
			Form {
				Section(header: headerView()) {
					TextField("Название", text: $viewModel.targetTitle)
						.foregroundStyle(Color.headerText)
					TextEditorWithPalceHolder(palceHolder: "Описание цели", textBinding: $viewModel.targetDescription)
						.foregroundStyle(Color.headerText)
					Picker(
//						label: {
//							Text("Категория цели")
//						},
						"Категория цели",
						selection: $viewModel.targetCategory) {
							ForEach(TargetCategory.allCases.filter({ $0 != .unknown })) { category in
								Text(category.rawValue).tag(category)
							}
						}
						.pickerStyle(.menu)
						.tint(.mainRed)
						.foregroundStyle(Color.headerText)
					
					DatePicker("Срок выполнения", selection: $viewModel.targetDeadline, displayedComponents: .date)
						.tint(.mainRed)
						.foregroundStyle(Color.headerText)
					
					if let titleError = viewModel.titleError {
						Text(titleError)
							.foregroundColor(.red)
							.font(MMFonts.caption)
					}
					
					if let descriptionError = viewModel.descriptionError {
						Text(descriptionError)
							.foregroundColor(.red)
							.font(MMFonts.caption)
					}
					
					if let deadlineError = viewModel.deadlineError {
						Text(deadlineError)
							.foregroundColor(.red)
							.font(MMFonts.caption)
					}
				}
				
				
				
				Section(header: Text("Подцели")
					.font(MMFonts.body)
					.foregroundStyle(Color.black.opacity(0.9))) {
						subTargetsSection()
					}
			}
			.scrollDismissesKeyboard(.interactively)
			.alert("Ошибка", isPresented: $showValidationAlert) {
				Button("OK", role: .cancel) { }
			} message: {
				Text(validationMessage)
			}
			.alert("Закрыть?", isPresented: $showDismissAlert) {
				Button("Отмена", role: .cancel) {}
				Button("Закрыть", role: .destructive) { dismiss() }
			} message: {
				Text("Все изменения будут потеряны.")
			}
		}
		.navigationBarTitleDisplayMode(.inline)
		.interactiveDismissDisabled(true) // Блокируем свайп
		.onAppear {
			viewModel.validateTarget()
			viewModel.validateSubTargets()
		}
	}
    
    @ViewBuilder
    func subTargetsSection() -> some View {
        ForEach(viewModel.subTargets.indices, id: \.self) { index in
            VStack(alignment: .leading) {
                TextField("Название", text: $viewModel.subTargets[index].title)
                    .foregroundStyle(Color.headerText)
                
                if let titleError = viewModel.subTargets[index].titleError {
                    Text(titleError)
                        .foregroundColor(.red)
                        .font(MMFonts.caption)
                }
                
                TextEditorWithPalceHolder(palceHolder: "Описание подцели", textBinding: $viewModel.subTargets[index].description)
                    .foregroundStyle(Color.headerText)
                
                if let descriptionError = viewModel.subTargets[index].descriptionError {
                    Text(descriptionError)
                        .foregroundColor(.red)
                        .font(MMFonts.caption)
                }
                
                DatePicker("Срок выполнения", selection: $viewModel.subTargets[index].deadline, displayedComponents: .date)
                    .tint(Color.mainRed)
                    .foregroundStyle(Color.headerText)
                
                if let deadlineError = viewModel.subTargets[index].deadlineError {
                    Text(deadlineError)
                        .foregroundColor(.red)
                        .font(MMFonts.caption)
                }
            }
            .padding(.vertical)
            .swipeActions(edge: .trailing) {
                Button(role: .destructive, action: {
                    viewModel.removeSubTarget(at: index)
                }) {
                    Label("Удалить", systemImage: "trash")
                }
                .tint(.red)
            }
        }
        
        Button(action: {
            viewModel.addNewSubTarget()
        }, label: {
            Label("Добавить подцель", systemImage: "plus.circle")
                .foregroundColor(.mainRed)
        })
    }
    
    /// Хежер экрана
    @ViewBuilder
    func headerView() -> some View {
        HStack {
			Button(action: {
				showDismissAlert = true
			}) {
				Image(systemName: "xmark")
					.foregroundStyle(Color.mainRed)
			}
            Text(isCreateTarget ? "Создание" : "Редактирование")
				.font(MMFonts.body)
                .foregroundStyle(Color.headerText)
				.lineLimit(1)
            Spacer()
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .frame(width: 16,
                           height: 16)
                    .padding(4)
            } else {
                Button(action: {
                    saveTarget()
                }, label: {
                    HStack(spacing: 0) {
                        Text("Готово")
                            .font(MMFonts.caption)
                            .foregroundColor(viewModel.isFormValid ? .mainRed : .gray)
                        Image(systemName: "checkmark")
                            .resizable()
                            .foregroundColor(viewModel.isFormValid ? .mainRed : .gray)
                            .frame(width: 16,
                                   height: 16)
                            .padding(4)
                    }
                })
                .disabled(!viewModel.isFormValid)
            }
        }
    }
    
    // MARK: - Validation Alert
    @State private var showValidationAlert: Bool = false
    @State private var validationMessage: String = ""
    
	private func saveTarget() {
		// Используем ViewModel для создания модели цели
		let targetModel = viewModel.createTargetModel()
		
		isLoading = true
		Task {
			if let target = await viewModelEnvironment.saveTarget(targetModel, isCreateTarget: isCreateTarget),
			   target != nil {
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
