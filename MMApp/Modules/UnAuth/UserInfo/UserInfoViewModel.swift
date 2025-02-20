//
//  UserInfoViewModel.swift
//  MMApp
//
//  Created by artem on 29.12.2024.
//

import Foundation
import Combine
import UIKit
import SwiftUI

class UserInfoViewModel {
    private(set) weak var viewController: UIViewController?
    
    let userModel: AuthUserDtoResult
    // MARK: - Input
    @Published var firstName: String = .empty
    @Published var lastName: String = .empty
    @Published var occupation: String = .empty
    @Published var city: String = .empty
    @Published var userName: String = .empty
    @Published var phoneNumber: String = .empty
    
    // MARK: - Output
    @Published private(set) var isFormValid: Bool = false
    
    private let apiFactory = ServiceBuilder()
    private var cancellables = Set<AnyCancellable>()
    
    init(userModel: AuthUserDtoResult) {
        self.userModel = userModel
        userName = userModel.username.orEmpty
        let params1 = Publishers.CombineLatest4($firstName, $lastName, $occupation, $city)
        let params2 = Publishers.CombineLatest($userName, $phoneNumber)
        params1.combineLatest(params2)
            .map { value in
                return !value.0.0.isEmpty && !value.0.1.isEmpty && !value.0.2.isEmpty && !value.0.3.isEmpty && !value.1.0.isEmpty && !value.1.1.isEmpty
            }
            .assign(to: &$isFormValid)
    }
    
    func createProfile() async {
        do {
            let finalUser = try await apiFactory.createProfile(profileData: CreateUserProfileBodyModel(
                externalId: userModel.id ?? 0,
                username: userModel.username ?? userName,
                fullName: firstName,
                userProfileStatus: "DRAFT",
                userPaymentStatus: "DRAFT",
                comment: occupation,
                photoUrl: userModel.photoUrl.orEmpty,
                location: city,
                phoneNumber: phoneNumber)
            )
            
            // TODO: Вернуться насчет авторизации
            UserRepository.shared.setRoles([(finalUser?.userProfileStatus).orEmpty])
            guard let viewController else { return }
            Task {
                await navigateToMain(viewController)
            }
            print(finalUser)
        }
        catch {
            print(error)
            return
        }
        

    }
    
    
    @MainActor
    func navigateToMain(_ from: UIViewController) {
        let nextVC = TabBarView()//UserInfoViewController() // Создаем экземпляр SwiftUI экрана
        let hostingController = UIHostingController(rootView: nextVC)
//        TabBarView
        // Переход на новый экран
        hostingController.modalPresentationStyle = .fullScreen
        viewController?.present(hostingController, animated: true, completion: nil)
    }
    
    func setVC(_ vc: UIViewController) {
        self.viewController = vc
    }
}
