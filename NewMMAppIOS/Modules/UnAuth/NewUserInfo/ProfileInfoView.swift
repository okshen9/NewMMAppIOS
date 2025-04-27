//
//  UserInfoViewController.swift
//  MMApp
//
//  Created by artem on 24.03.2025.
//

import SwiftUI

struct ProfileInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ProfileInfoViewModel
    @EnvironmentObject var appStateServise: AppStateService
    @State var isKeyboardVisible = false

    var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    ValidatedTextField(
                        title: "Имя",
                        text: $viewModel.userProfile.firstName,
                        error: viewModel.errors["firstName"]
                    )
                    
                    ValidatedTextField(
                        title: "Имя пользователя в Telegram",
                        text: $viewModel.userProfile.telegramUsername,
                        error: viewModel.errors["telegramUsername"]
                    )
                    .setCanEdit(viewModel.isCanEditTelegramUsername)
                    
                    ValidatedTextField(
                        title: "Род деятельности",
                        text: $viewModel.userProfile.occupation,
                        error: viewModel.errors["occupation"]
                    )
                    
                    ValidatedTextField(
                        title: "Город проживания",
                        text: $viewModel.userProfile.city,
                        error: viewModel.errors["city"]
                    )
                    
                    PhoneNumberTextField(
                        phoneNumber: $viewModel.userProfile.phoneNumber,
                        error: viewModel.errors["phoneNumber"]
                    )
                    
                    ValidatedTextEditor(
                        title: "О себе",
                        text: $viewModel.userProfile.about,
                        error: viewModel.errors["about"]
                    )
                    
                    Button(action: {
                        Task {
                            await viewModel.saveProfile()
                        }
                    }) {
                        if !viewModel.isLoaded {
                            Text("Сохранить")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.mainRed)
                                .foregroundColor(.white)
                                .cornerRadius(16)
                        } else {
                            ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .frame(width: 16,
                                   height: 16)
                            .padding(4)
                        }
                    }
                    .disabled(!viewModel.isValid)

                }
                .padding()
                .onChange(of: viewModel.userProfile) {
                    viewModel.validate()
                }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Данные профиля")
            .onChange(of: viewModel.navPath) { oldPath, newPath in
                switch newPath {
                case .toInfoView:
                    break
                case .toMinView:
                    appStateServise.setNewState(.authorized)
                case .dismiss:
                    dismiss()
                }
            }
        }
            .scrollDismissesKeyboard(.interactively)



    }
}


//#Preview {
//    ProfileInfoView(viewModel: ProfileInfoViewModel(profileModel: <#UserProfileResultDto?#>, authModel: <#AuthUserDtoResult?#>), isKeyboardVisible: false)
//}
