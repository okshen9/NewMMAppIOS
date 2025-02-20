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
    private let service = ServiceBuilder()
//    private let apiFactory = APIFactory.global
    
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
        let nextVC = TabBarView()
        let hostingController = UIHostingController(rootView: nextVC)
        // Переход на новый экран
        hostingController.modalPresentationStyle = .fullScreen
        viewController?.present(hostingController, animated: true, completion: nil)
    }
    
    /// MARK: - Validaite
    /// Провереяет url на наличе tgData
    /// - Parameters:
    ///   - url: проверяемый url
    ///   - httpBody: боди запроса
    /// - Returns: строку tgKey или nil, если не нашел
    func validateWebRequest(url: URL?, httpBody: Data?) -> String? {
        print("Neshko VAlWEb URL: \(url)")
        print("Neshko VAlWEb httpBody: \(httpBody)")
        guard
            let urlComponents = url?.absoluteString.components(separatedBy: Constants.tgAuthResult),
            let tgKey = urlComponents[safe: 1],
            !tgKey.isEmpty
        else {
            return nil
        }
        print("Neshko profile \(tgKey)")
        return tgKey
    }
    
    func saveTGData(tgKey: String) async {
        /*await*/ UserRepository.shared.setTGData(tgKey)
    }
    
    /// Кол бек с телеграм даты - авторизация и навигация
    func telegramCallBack(tgKey: String) {
        Task { [weak self] in
            let authQueryModel = AuthQueryModel(tgData: tgKey)
            let resultAuth = await self?.getAuthProfile(authQueryModel: authQueryModel)
            guard
                let jwt = resultAuth?.jwt,
                let refreshToken = resultAuth?.jwt,
                var authUser = resultAuth?.authUserDto,
                let vc = self?.viewController
                  
            else {
                return
            }
            /*await*/ UserRepository.shared.setAuthUser(resultAuth)
            authUser.photoUrl = authQueryModel.getTgCallBackModelDTO().photoUrl
            // TODO: Вернуть нормальную логику
            
            let role = (resultAuth?.authUserDto?.roles ?? [.draft]).contains(.draft) ? Roles.draft : Roles.admin
            
            switch role {
            case .admin, .user:
                await self?.navigateToMain(vc, user: authUser)
            case .draft, .unknown:
                await self?.navigateToUserForm(vc, user: authUser)
            }
        }
    }
    
    private func fetchUser() async {
        do {
            guard let userProfile = try await service.getProfileMe() else { return }
            /*await*/ UserRepository.shared.setUserProfile(userProfile)
        } catch {
            print(error)
        }
    }
    
    /// Return: true - грузим новые данные, false - данные имеются
    func chekSavedTGData() async -> String? {
        /*await*/ UserRepository.shared.tgData
    }
    
    func currentUserIsDraft() async -> Bool {
        return (/*await*/ UserRepository.shared.roles ?? [])
            .map{Roles(rawValue: $0)}
            .contains(where: {$0 == .draft || $0 == .unknown})
    }
    
    /// Запрашиваем authUser
    func getAuthProfile(authQueryModel: AuthQueryModel) async -> AuthTGRequestModel? {
        do {
            return await try service.sendTGToken(model: authQueryModel)
        } catch {
            print("neshko error \(error)")
            return nil
        }
    }
}

extension AuthViewModel {
    enum Constants {
        static let queryParamQuestion = "#"
        static let tgAuthResult = "tgAuthResult="
//        static let kirilTgData = "eyJpZCI6MTIzNDU2NywiZmlyc3RfbmFtZSI6IkpvaG4iLCJsYXN0X25hbWUiOiJEb2VlIiwidXNlcm5hbWUiOiJqb2huZG9lIiwicGhvdG9fdXJsIjoiaHR0cHM6XC9cL3QubWVcL2lcL3VzZXJwaWNcLzMyMFwveXJDSERfSFJIRFZrdHBRaExIZURRNlRzWVAtMVNnbGR5dEFLWEJIbHV4MC5qcGciLCJhdXRoX2RhdGUiOiAxNjE3MTgxMTkyLCJoYXNoIjoiMWZmMmY0ZDJiNjBkMDY4YTZiN2VmNzRkYTYyZDljYjgxNzk5NDE2ZjJlMTg2MDY3ZDJhNzFkYmQ3Y2Y3NDc4YSJ9"
    }
}

