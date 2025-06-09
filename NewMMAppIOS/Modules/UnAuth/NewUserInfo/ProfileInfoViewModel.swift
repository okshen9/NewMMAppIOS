//
//  ProfileInfoViewModel.swift
//  MMApp
//
//  Created by artem on 24.03.2025.
//


import SwiftUI

class ProfileInfoViewModel: ObservableObject {
    @Published var userProfile: UserProfile
    @Published var errors: [String: String] = [:]
    @Published var isValid = false
    @Published var shouldNavigateToMain = false
    @Published var navPath = UserInfoViewModelPath.toInfoView
    @Published var isLoaded = false
    
    @Published var hasError = false

    let isCanEditTelegramUsername: Bool
    
    private let authModel: AuthUserDtoResult?
    private let profileModel: UserProfileResultDto?
    private let apiFactory = ServiceBuilder.shared
    let isEditProfile: Bool
    private var needUpdateAction: () -> Void

    init(profileModel: UserProfileResultDto?, authModel: AuthUserDtoResult?, isEditProfile: Bool, needUpdateAction: @escaping () -> Void = {}) {
        self.authModel = authModel
        self.profileModel = profileModel
        userProfile = UserProfile(
            firstName: profileModel?.fullName ?? (authModel?.firstName).orEmpty,
            telegramUsername: profileModel?.username ?? (authModel?.username).orEmpty,
            occupation: (profileModel?.activitySphere).orEmpty,
            city: (profileModel?.location).orEmpty,
            phoneNumber: (profileModel?.phoneNumber).orEmpty,
            about: (profileModel?.biography).orEmpty
        )
        self.isEditProfile = isEditProfile
        self.isCanEditTelegramUsername = (profileModel?.username ?? (authModel?.username).orEmpty).isEmpty
        self.needUpdateAction = needUpdateAction
    }
    
    static func editProfileViewModel(needUpdateAction: @escaping () -> Void) -> ProfileInfoViewModel {
        let userRepository = UserRepository.shared
        let authModel = userRepository.authUser?.authUserDto
        let profileModel = userRepository.userProfile
        return ProfileInfoViewModel(profileModel: profileModel, authModel: authModel, isEditProfile: true, needUpdateAction: needUpdateAction)
    }
    
    // Валидация всех полей
    func validate() {
        
        withAnimation {
            errors["firstName"] =  userProfile.firstName.isEmpty || userProfile.firstName.count >= 5 ? nil : "ФИО не может быть менее 5-ти символов"
            errors["telegramUsername"] =  userProfile.telegramUsername.isEmpty || userProfile.telegramUsername.count >= 5 ? nil : "Имя пользователя в Telegram не может быть менее 5-ти символов"
            errors["occupation"] =  userProfile.occupation.isEmpty || userProfile.occupation.count >= 3 ? nil : "Род деятельности не может быть менее 3-х символов"
            errors["city"] =  userProfile.city.isEmpty || userProfile.city.count >= 3 ? nil : "Город проживания не может быть менее 3-х символов"
            errors["about"] =  userProfile.about.isEmpty || userProfile.about.count >= 3 ? nil : "Поле 'О себе' не может быть менее 3-х символов"
            errors["phoneNumber"] =  (userProfile.phoneNumber.isEmpty || isValidPhoneNumber(userProfile.phoneNumber))  ? nil : "Некорректный номер телефона"
            
            // поля не должны быть пустыми
            let anyEmpty = userProfile.firstName.isEmpty || userProfile.telegramUsername.isEmpty || userProfile.occupation.isEmpty || userProfile.city.isEmpty || userProfile.phoneNumber.isEmpty
            print("neshko777 isValid \(isValid) anyEmpty \(anyEmpty)")
            isValid = errors.isEmpty && !anyEmpty
        }
        
        
    }
    
    // Проверка номера телефона с поддержкой международных форматов
    private func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        // Извлекаем только цифры для проверки длины
        let digits = phoneNumber.filter { $0.isNumber }
        
        // Минимально допустимая длина: код страны + местный номер
        // Обычно телефон содержит от 7 до 15 цифр по стандарту E.164
        guard digits.count >= 7 && digits.count <= 15 else {
            return false
        }
        
        // Проверяем, что строка начинается с +
        guard phoneNumber.hasPrefix("+") else {
            return false
        }
        
        // Проверка на наличие хотя бы одного пробела или дефиса для разделения частей
        // Но не проверяем конкретные форматы, так как они могут отличаться
        let containsFormatting = phoneNumber.contains(" ") || phoneNumber.contains("-")
        
        return containsFormatting
    }
    
    /// Функция сохранения профиля (адаптирована из запроса)
    func saveProfile() async {
        //        await navigateToMain()
        //        return
        await setIsLoaded(true)
        do {
            if isEditProfile {
                let updatedUser = try await apiFactory.patchMe(profileData:
                                                                EditProfileBodyDTO(
                                                                    username: userProfile.telegramUsername,
                                                                    fullName: userProfile.firstName,
                                                                    userProfileStatus: profileModel?.userProfileStatus,
                                                                    userPaymentStatus: profileModel?.userPaymentStatus,
                                                                    isDeleted: profileModel?.isDeleted,
                                                                    comment: profileModel?.comment,
                                                                    photoUrl: profileModel?.photoUrl,
                                                                    location: userProfile.city,
                                                                    phoneNumber: userProfile.phoneNumber,
                                                                    activitySphere: userProfile.occupation,
                                                                    biography: userProfile.about
                                                                )
                )
                // Сохраняем обновленный профиль в UserRepository
                UserRepository.shared.setUserProfile(updatedUser)
                UserRepository.shared.setRoles([(updatedUser.userProfileStatus) ?? ""])
                await setIsLoaded(false)
                self.needUpdateAction()
                await navigationTo(.dismiss)
            } else {
                let finalUser = try await apiFactory.createProfile(profileData: CreateUserProfileBodyModel(
                    externalId: nil, // Предполагаем, что ID будет получен позже
                    username: userProfile.telegramUsername,
                    fullName: userProfile.firstName,
                    userProfileStatus: nil,
                    userPaymentStatus: nil,
                    photoUrl: UserRepository.shared.getUrlPhotoFromTGData(), // Поле не указано в списке, оставляем пустым
                    location: userProfile.city,
                    phoneNumber: userProfile.phoneNumber,
                    biography: userProfile.about,
                    activitySphere: userProfile.occupation
                ))
                guard let refreshJWT = UserRepository.shared.refreshJWT,
                      let updatedAuthUser = try await apiFactory.refreshJWT(refreshModel: .init(refreshToken: refreshJWT)) else {
                    await navigationTo(.toInfoView)
                    return
                }
                UserRepository.shared.setAuthUser(updatedAuthUser)
                UserRepository.shared.setUserProfile(finalUser)
                await setIsLoaded(false)
                await navigationTo(.dismiss)
                await navigationTo(.toMinView)
            }
        } catch {
            await setIsLoaded(false)
            if let error = error as? ResponseError {
                switch error {
                case let .responseBase(response: baseError, statusCode: code):
                    await ToastManager.shared.show(
                        ToastModel(message: baseError.errorMessage.orEmpty, icon: "xmark.app", duration: 2)
                    )
                default:
                    await ToastManager.shared.show(
                        ToastModel(message: "Что-то пошло не так", icon: "xmark.app", duration: 2)
                    )
                }
            } else {
                await ToastManager.shared.show(
                    ToastModel(message: "Что-то пошло не так", icon: "xmark.app", duration: 2)
                )
            }
            print(error)
        }
    }
    
    /// Функция сохранения профиля (адаптирована из запроса)
    func deleteProfile() async {
        await setIsLoaded(true)
        do {
            // TODO: delete profile
            try await apiFactory.patchMe(profileData:
                                            EditProfileBodyDTO (
                                                isDeleted: true
                                            )
            )
        } catch {
            await ToastManager.shared.show(
                ToastModel(message: "Что-то пошло не так", icon: "xmark.app", duration: 2)
            )
        }
    }
    
    @MainActor
    func navigationTo(_ path: UserInfoViewModelPath) {
        navPath = path
    }

    @MainActor
    func setIsLoaded(_ isActive: Bool) {
        self.isLoaded = isActive
    }
}

extension ProfileInfoViewModel {
    enum UserInfoViewModelPath {
        //        case authView
        case toInfoView
        case toMinView
        case dismiss
    }
}
