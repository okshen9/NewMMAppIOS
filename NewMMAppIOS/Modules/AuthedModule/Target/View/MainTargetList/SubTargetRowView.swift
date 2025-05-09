//
//  SubTargetRowView.swift
//  MMApp
//
//  Created by artem on 30.01.2025.
//

import SwiftUI
import Combine

protocol SubTargetRowViewModelProtocol: ObservableObject {
	/// Закрывает подцель
    func closedSubTarget(_ target: UserSubTargetDtoModel)
	/// Закрывает последнюю подцель и при необходимости закрывает родительскую цель или создает новую подцель
    func closedSubTargetWithParent(_ subTarget: UserSubTargetDtoModel, closeParent: Bool)
	/// Добавляет новую подцель к указанной цели
    func addNewSubtarget(to parentTarget: UserTargetDtoModel, withName name: String)
}

struct SubTargetRowView<ViewModel: SubTargetRowViewModelProtocol>: View {
    @EnvironmentObject var viewModelEnvironment: ViewModel
    var myTarget = true

    @Binding var showDescription: Bool

    // Состояние для работы с диалогами
    @State private var showConfirmationDialog = false
    @State private var showCustomAlert = false
    @State private var isClosingWholeTarget = true
    @State private var isLoading = false


    // Информация о подцели и родительской цели
    var subTarget: UserSubTargetDtoModel
    var parentTarget: UserTargetDtoModel? = nil
    
    // Определяем, является ли подцель последней незакрытой в цели
    var isLastUnclosedSubtarget: Bool {
        guard let parent = parentTarget, let subTargets = parent.subTargets else { return false }
        let unclosedCount = subTargets.filter { $0.targetStatus != .done }.count
        return unclosedCount == 1 && subTarget.targetStatus != .done
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    Button(action: {
                        if myTarget {
//                            if isLastUnclosedSubtarget {
//                                showCustomAlert = true
//                            } else {
                                showConfirmationDialog = true
//                            }
                        }
                    }) {
                        Image(systemName: subTarget.targetStatus == .done ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(subTarget.targetStatus == .done ? .green : .gray)
                            .imageScale(.medium)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 2)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(subTarget.title.orEmpty)
                            .font(MMFonts.body)
                            .foregroundColor(.headerText)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(2)

                        Spacer()
                    }

                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .foregroundColor(.gray)
                            .imageScale(.small)

                        Text((subTarget.deadLineDateTime?.dateFromApiString ?? Date.now).toDisplayString)
                            .font(MMFonts.caption)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }
            }

            if showDescription {
                if let description = subTarget.description, !description.isEmpty {
                    Text(description)
                        .font(MMFonts.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(nil)
                        .cornerRadius(6)
                        .padding(.leading, 32)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onChange(of: subTarget, {
            isLoading = false
        })
		.alert((subTarget.targetStatus?.isDone).orFalse ? "Переоткрыть подцель?" : "Завершить подцель?", isPresented: $showConfirmationDialog) {
            Button("Да") {
                isLoading = true
//                viewModelEnvironment.closedSubTarget(subTarget)
                viewModelEnvironment.closedSubTargetWithParent(subTarget, closeParent: isLastUnclosedSubtarget)
            }
            Button("Нет", role: .cancel) { }
        }
    }
}

#Preview {
    @Previewable @State var showDescription: Bool = false
    SubTargetRowView<TargetsViewModel>(
        showDescription: $showDescription,
        subTarget: .init(
            title: "Test",
            description: "Тестовое описание подцели",
            targetSubStatus: .done
        ),
		parentTarget: .init(id: 0,
							title: "Parent Target")
    )
    .environmentObject(TargetsViewModel())
}
