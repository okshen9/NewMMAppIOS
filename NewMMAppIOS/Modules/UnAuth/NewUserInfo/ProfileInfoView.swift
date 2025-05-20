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
    @EnvironmentObject var appStateServise: AppNavigationStateService
    @EnvironmentObject var navigationManager: NavigationManager<AuthRoute>
    @State var isKeyboardVisible = false
    @State private var showDismissAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if viewModel.isEditProfile {
                    HStack {
                        Button(action: {
                            showDismissAlert = true
                        }) {
                            Image(systemName: "xmark")
                                .foregroundStyle(Color.mainRed)
                        }
                        Spacer()
                        Text("Редактирование профиля")
                            .font(MMFonts.title)
                            .foregroundStyle(Color.headerText)
                        Spacer()
                    }
                }
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
                            .background(viewModel.isValid ? Color.mainRed : Color.gray.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(16)
                    } else {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(16)
                    }
                }
                .disabled(!viewModel.isValid || viewModel.isLoaded)

            }
            .padding()
            .onChange(of: viewModel.userProfile) {
                viewModel.validate()
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: viewModel.navPath) { oldPath, newPath in
                switch newPath {
                case .toInfoView:
                    break
                case .toMinView:
                    appStateServise.setNewState(.authorized)
                case .dismiss:
                    if viewModel.isEditProfile {
                        dismiss()
                    } else {
                        navigationManager.pop()
                    }
                }
            }
            .disabled(viewModel.isLoaded) // Блокируем взаимодействие с формой при загрузке
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Данные профиля")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    showDismissAlert = true
                }) {
                    Image(systemName: "chevron.backward")
                        .foregroundStyle(Color.mainRed)
                }
            }
        }
        .alert("Закрыть?", isPresented: $showDismissAlert) {
            Button("Отмена", role: .cancel) {}
            Button("Закрыть", role: .destructive) {
                if viewModel.isEditProfile {
                    dismiss()
                } else {
                    navigationManager.pop()
                }
            }
        } message: {
            Text("Все изменения будут потеряны.")
        }
        .interactiveDismissDisabled(true) // Блокируем свайп
        .navigationBarBackButtonHidden()
    }
}


#Preview {
	@Previewable @State var isPresented: Bool = false
	let view = ProfileInfoView(viewModel: ProfileInfoViewModel(profileModel: .getTestUser(),
															   authModel: AuthUserDtoResult(id: 123, telegramId: nil, authDate: nil, hash: nil, lastName: nil, firstName: nil, username: nil, enabled: true, authStatus: nil, roles: nil),
															   isEditProfile: false,
															   needUpdateAction: {}))
	NavigationStack {
		NavigationLink("sdvsd", destination:
						view
					   
		)
		Text("Sheet")
			.onTapGesture {
				isPresented.toggle()
			}
			.sheet(isPresented: $isPresented) {
				view
			}
		
		
	}
}
