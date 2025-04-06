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
    @Published var navPath = ProfileInfoViewModelPath.toMinView
    @Published var isLoaded = false

    let isCanEditTelegramUsername: Bool
    
    private let authModel: AuthUserDtoResult?
    private let profileModel: UserProfileResultDto?
    private let apiFactory = ServiceBuilder.shared
    private let isEditProfile: Bool
    private var needUpdateAction: () -> Void

    init(profileModel: UserProfileResultDto?, authModel: AuthUserDtoResult?, isEditProfile: Bool = false, needUpdateAction: @escaping () -> Void = {}) {
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
            errors["firstName"] =  userProfile.firstName.isEmpty || userProfile.firstName.count > 3 ? nil : "Имя не может быть 3 символов"
            errors["telegramUsername"] =  userProfile.telegramUsername.isEmpty || userProfile.telegramUsername.count > 3 ? nil : "Имя пользователя в Telegram не может быть менее 3 символов"
            errors["occupation"] =  userProfile.occupation.isEmpty || userProfile.occupation.count > 3 ? nil : "Род деятельности не может быть менее 3 символов"
            errors["city"] =  userProfile.city.isEmpty || userProfile.city.count > 3 ? nil : "Город проживания не может быть менее 3 символов"
            errors["about"] =  userProfile.about.isEmpty || userProfile.about.count > 3 ? nil : "Поле 'О себе' не может быть 3 символов"
            errors["phoneNumber"] =  (userProfile.phoneNumber.isEmpty || isValidPhoneNumber(userProfile.phoneNumber))  ? nil : "Некорректный номер телефона"
            
            let anyEmpty = userProfile.firstName.isEmpty || userProfile.telegramUsername.isEmpty || userProfile.occupation.isEmpty || userProfile.city.isEmpty || userProfile.about.isEmpty || userProfile.phoneNumber.isEmpty
            
            isValid = errors.isEmpty && !anyEmpty
        }
        
        
    }
    
    // Проверка номера телефона
    private func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        let phoneRegex = "^\\+7 \\(9\\d{2}\\) \\d{3}-\\d{2}-\\d{2}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return predicate.evaluate(with: phoneNumber)
    }
    
    // Функция сохранения профиля (адаптирована из запроса)
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
                                                                    roles: profileModel?.roles,
                                                                    activitySphere: userProfile.occupation,
                                                                    authUserDto: authModel,
                                                                    biography: userProfile.about
                                                                )
                )
                UserRepository.shared.setRoles([(updatedUser?.userProfileStatus) ?? ""])
                await setIsLoaded(false)
                self.needUpdateAction()
                await navigationTo(.dismiss)
            } else {
                let finalUser = try await apiFactory.createProfile(profileData: CreateUserProfileBodyModel(
                    externalId: 0, // Предполагаем, что ID будет получен позже
                    username: userProfile.telegramUsername,
                    fullName: userProfile.firstName,
                    userProfileStatus: "DRAFT",
                    userPaymentStatus: "DRAFT",
                    photoUrl: "", // Поле не указано в списке, оставляем пустым
                    location: userProfile.city,
                    phoneNumber: userProfile.phoneNumber,
                    biography: userProfile.about,
                    activitySphere: userProfile.occupation
                ))
                
                UserRepository.shared.setRoles([(finalUser?.userProfileStatus) ?? ""])
                await setIsLoaded(false)
                await navigationTo(.toMinView)
            }
        } catch {
            await setIsLoaded(false)
            print(error)
        }
    }
    
    @MainActor
    func navigationTo(_ path: ProfileInfoViewModelPath) {
        navPath = path
    }

    @MainActor
    func setIsLoaded(_ isActive: Bool) {
        self.isLoaded = isActive
    }
}

extension ProfileInfoViewModel {
    enum ProfileInfoViewModelPath {
        //        case authView
        case toInfoView
        case toMinView
        case dismiss
    }
}
