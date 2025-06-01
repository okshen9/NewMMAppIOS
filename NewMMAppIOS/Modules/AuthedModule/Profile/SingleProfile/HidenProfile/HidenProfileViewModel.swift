//
//  HidenProfileViewModel.swift
//  NewMMAppIOS
//
//  Created by artem on 01.06.25.
//

import Foundation
import Combine
import UIKit

class HidenProfileViewModel: ObservableObject {
    private let service = ServiceBuilder.shared
    private let userRepository = UserRepository.shared
    
    private var hidenIds: [Int]?
    @Published var profiles: [UserProfileResultDto] = []
    @Published var isLoading = false
    
    init(hidenIds: [Int]? = nil) {
        self.hidenIds = hidenIds
        loadHiddenProfiles()
    }
    
    /// Загрузить профили игнорируемых пользователей
    func loadHiddenProfiles() {
        guard let hiddenIds = hidenIds, !hiddenIds.isEmpty else {
            self.profiles = []
            return
        }
        
        Task {
            await setIsLoading(true)
            
            do {
                var loadedProfiles: [UserProfileResultDto] = []
                
                // Загружаем профили по ID
                for externalId in hiddenIds {
                    if let profile = try await service.getUserProfile(externalId: externalId) {
                        loadedProfiles.append(profile)
                    }
                }
                
                await MainActor.run {
                    self.profiles = loadedProfiles.sorted { 
                        ($0.fullName ?? "") < ($1.fullName ?? "") 
                    }
                }
            } catch {
                print("Ошибка загрузки игнорируемых профилей: \(error)")
                await ToastManager.shared.show(.baseError)
            }
            
            await setIsLoading(false)
        }
    }
    
    /// Скрыть неподходящие эвенты
    /// - Parameter externalId: id который надо убрать из игнорирования
    func unhideProfile(externalId: Int) async -> UserProfileResultDto? {
        do {
            guard var userProfile = userRepository.userProfile else {
                throw NSError(domain: "SendReportError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid type"])
            }
            
            var newForUserHideThisExtIdUsersEvents = Set((userProfile.forUserHideThisExtIdUsersEvents) ?? [])
            newForUserHideThisExtIdUsersEvents.remove(externalId)
            userProfile.forUserHideThisExtIdUsersEvents = Array(newForUserHideThisExtIdUsersEvents)
            
            let edit = EditProfileBodyDTO(userProfile)
            let newUser = try await service.patchMe(profileData: edit)
            userRepository.setUserProfile(newUser)
            
            // Обновляем локальный список скрытых ID
            hidenIds?.removeAll(where: { $0 == externalId })
            profiles.removeAll { $0.externalId == externalId }
            UserRepository.shared.setUserProfile(newUser)
            
            return newUser
        }
        catch {
            await ToastManager.shared.show(.baseError)
            return nil
        }
    }
    
    @MainActor
    private func setIsLoading(_ isLoading: Bool) {
        self.isLoading = isLoading
    }
    
    func openTelegramChat(username: String) {
        // Формируем ссылку для приложения Telegram
        let telegramURL = URL(string: "tg://resolve?domain=\(username)")!
        
        // Проверяем, установлен ли Telegram
        if UIApplication.shared.canOpenURL(telegramURL) {
            // Открываем Telegram
            UIApplication.shared.open(telegramURL, options: [:], completionHandler: nil)
        } else {
            // Если Telegram не установлен, открываем веб-версию
            let webURL = URL(string: "https://t.me/\(username)")!
            UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
        }
    }
}
