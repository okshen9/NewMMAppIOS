//
//  RepotView.swift
//  NewMMAppIOS
//
//  Created by artem on 24.05.2025.
//

import SwiftUI
import Kingfisher

struct RepotView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ReportViewModel
    @State private var reportText = String.empty
    @State private var selectedReason: ReportReason = .other
    @FocusState private var isTextFieldFocused: Bool
    
    private var validReport: Bool {
        reportText.count >= 5
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        KFImage(URL(string: viewModel.profile.photoUrl.orEmpty))
                            .placeholder {
                                Image(.MM)
                                    .resizable(resizingMode: .stretch)
                                    .renderingMode(.template)
                                    .padding(6)
                            }
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 44, height: 44)
                            .clipShape(Circle())
                            .overlay {
                                Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            }
                        
                        Text(viewModel.profile.fullName ?? "Пользователь без имени")
                            .font(.headline)
                            .foregroundStyle(Color.headerText)
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Жалоба на пользователя")
                } footer: {
                    Text("Ваша жалоба будет рассмотрена модератором")
                }
                
                Section(header: Text("Причина жалобы")) {
                    Picker("Выберите причину", selection: $selectedReason) {
                        ForEach(ReportReason.allCases) { reason in
                            Text(reason.title).tag(reason)
                        }
                    }
                    .foregroundStyle(Color.headerText)
                    .pickerStyle(.menu)
                }
                
                Section(header: Text("Описание проблемы")) {
                    TextEditorWithPalceHolder(palceHolder: "Опишите ситуацию подробнее...", textBinding: $reportText)
                        .frame(minHeight: 120)
                    if !validReport && !reportText.isEmpty {
                        Text("Описание должно содержать не менее 5 символов")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Жалоба")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                    .foregroundStyle(Color.mainRed)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(
                        action: {
                            Task {
                                if await viewModel.sendReport("\(selectedReason.title): \(reportText)") {
                                    dismiss()
                                    await ToastManager.shared.show(.init(message: "Жалоба отправлена на рассмотрение"))
                                } else {
                                    await ToastManager.shared.show(.init(message: "Не удалось отправить жалобу"))
                                }
                            }
                        },
                        label: {
                            if viewModel.isLoad {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            } else {
                                Text("Отправить")
                            }
                        })
                    .fontWeight(.medium)
                    .disabled(!validReport)
                    .foregroundStyle(validReport ? Color.mainRed : Color.secondary)
                }
            }
            .onTapGesture {
                // Скрыть клавиатуру при тапе по фону
                UIApplication.shared.endEditing()
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }
}

enum ReportReason: String, CaseIterable, Identifiable {
    case spam
    case harassment
    case inappropriateContent
    case falseInformation
    case other
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .spam: return "Спам"
        case .harassment: return "Домогательство"
        case .inappropriateContent: return "Неуместный контент"
        case .falseInformation: return "Недостоверная информация"
        case .other: return "Другое"
        }
    }
}

#Preview {
    RepotView(viewModel: .init(profile: .getTestUser()))
}
