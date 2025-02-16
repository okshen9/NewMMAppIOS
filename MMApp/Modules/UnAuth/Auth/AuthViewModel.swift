//
//  AuthViewModel.swift
//  MMApp
//
//  Created by artem on 06.01.2025.
//

import Foundation
import UIKit
import SwiftUI

class AuthViewModel {
    private(set) weak var viewController: UIViewController?
//    private let apiFactory = ServiceBuilder()
    private let apiFactory = APIFactory.global
    
    init(_ vc: UIViewController) {
        self.viewController = vc
    }
    
    /// - MARK: Routing
    @MainActor
    func navigateToUserForm(_ from: UIViewController, user: AuthUserDtoResult) {
        let nextVC = UserInfoViewController(viewModel: UserInfoViewModel(userModel: user))
//        SwiftUI экрана
//        let hostingController = UIHostingController(rootView: testScreen)
//        TabBarView
        // Переход на новый экран
        nextVC.modalPresentationStyle = .fullScreen
        viewController?.present(nextVC, animated: true, completion: nil)
    }
    
    @MainActor
    func navigateToMain(_ from: UIViewController, user: AuthUserDtoResult) {
        let nextVC = TabBarView(user: user)//UserInfoViewController() // Создаем экземпляр SwiftUI экрана
        let hostingController = UIHostingController(rootView: nextVC)
//        TabBarView
        // Переход на новый экран
        hostingController.modalPresentationStyle = .fullScreen
        viewController?.present(hostingController, animated: true, completion: nil)
    }
    
    /// MARK: - Validaite
    func validateWebRequest(url: URL?, httpBody: Data?) -> String? {
        print("Neshko VAlWEb URL: \(url)")
        print("Neshko VAlWEb httpBody: \(httpBody)")
        guard
            let urlComponents = url?.absoluteString.components(
                separatedBy: Constants.tgAuthResult
            ),
            let tgKey = urlComponents[safe: 1],
            !tgKey.isEmpty
        else {
            return nil
        }
        print("Neshko profile \(tgKey)")
        KeyChainStorage.tgData.save(value: tgKey)
        return tgKey
    }
    
    func telegramCallBack(tgKey: String = KeyChainStorage.tgData.getData().orEmpty) {
        Task {[weak self] in
            let authQueryModel = AuthQueryModel(tgData: tgKey)
            let result = await self?.getProfile(authQueryModel: AuthQueryModel(tgData: tgKey))
            guard
                let jwt = result?.jwt,
                let refreshToken = result?.jwt,
                var user = result?.authUserDto,
                let vc = self?.viewController
                  
            else {
                return
            }
            KeyChainStorage.jwtToken.save(value: jwt)
            KeyChainStorage.refreshToken.save(value: refreshToken)
            user.photoUrl = authQueryModel.getTgCallBackModelDTO().photoUrl
            // TODO: Вернуть нормальную логику
            var defRole = result?.authUserDto?.roles?.first?.rawValue ?? UserDefaultsStorege.role.getData()
            
            switch defRole {
            case "ROLE_ADMIN":
                await self?.navigateToMain(vc, user: user)
            case "ROLE_DRAFT":
                user.photoUrl = authQueryModel.getTgCallBackModelDTO().photoUrl
                await self?.navigateToUserForm(vc, user: user)
            default:
                UserDefaultsStorege.role.save(value: ("ROLE_DRAFT"))
                user.photoUrl = authQueryModel.getTgCallBackModelDTO().photoUrl
                await self?.navigateToUserForm(vc, user: user)
            }
            
            defRole = UserDefaultsStorege.role.getData()
            
            if let result {
                UserRepository.shared.saveUserAuthDTO(result)
            }
            
            await self?.getUser()
        }
    }
    
    private func getUser() async {
        do {
            guard let userProfile = try await apiFactory.getProfileMe() else { return }
            UserRepository.shared.saveUserProfileDTO(userProfile)
        } catch {
            print(error)
        }
    }
    
    /// Return: true - грузим новые данные, false - данные имеются
    func chekSavedKey() -> Bool {
        guard let tgData = KeyChainStorage.tgData.getData() else {
            return true
        }
        
        return false
    }
    
    func getProfile(authQueryModel: AuthQueryModel) async -> AuthTGRequestModel? {
        
        return await apiFactory.sendTGToken(authQueryModel: authQueryModel)
    }
    
}

extension AuthViewModel {
    enum Constants {
        static let queryParamQuestion = "#"
        static let tgAuthResult = "tgAuthResult="
//        static let kirilTgData = "eyJpZCI6MTIzNDU2NywiZmlyc3RfbmFtZSI6IkpvaG4iLCJsYXN0X25hbWUiOiJEb2VlIiwidXNlcm5hbWUiOiJqb2huZG9lIiwicGhvdG9fdXJsIjoiaHR0cHM6XC9cL3QubWVcL2lcL3VzZXJwaWNcLzMyMFwveXJDSERfSFJIRFZrdHBRaExIZURRNlRzWVAtMVNnbGR5dEFLWEJIbHV4MC5qcGciLCJhdXRoX2RhdGUiOiAxNjE3MTgxMTkyLCJoYXNoIjoiMWZmMmY0ZDJiNjBkMDY4YTZiN2VmNzRkYTYyZDljYjgxNzk5NDE2ZjJlMTg2MDY3ZDJhNzFkYmQ3Y2Y3NDc4YSJ9"
    }
}

