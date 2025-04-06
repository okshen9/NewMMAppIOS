//
//  AuthSUIViewModel.swift
//  TestUISwift
//
//  Created by artem on 25.03.2025.
//

import Foundation
import Combine
import SwiftUI
import WebKit

// MARK: - ViewModel
final class AuthSUIViewModel: NSObject, ObservableObject {
    @Published var showWebView = false
    private let service = ServiceBuilder.shared

    @Published var navPath = AuthViewModelPath.authView


    // MARK: - Methods
    func validateWebRequest(url: URL?) -> String? {
        guard let urlString = url?.absoluteString,
              let range = urlString.range(of: Constants.tgAuthResult) else { return nil }

        return String(urlString[range.upperBound...])
    }

    func telegramCallBack(tgKey: String) {
        Task {
            let authQueryModel = AuthQueryModel(tgData: tgKey)
            guard let result = await getAuthProfile(authQueryModel: authQueryModel) else { return }

            let getProfile = try? await service.getProfileMe()
            UserRepository.shared.setUserProfile(getProfile)

            await MainActor.run {
                UserRepository.shared.setAuthUser(result)
                
                handleNavigation(for: result.authUserDto)
            }
        }
    }

    private func handleNavigation(for user: AuthUserDtoResult?) {
        guard let user else { return }

        let roles = user.roles ?? []
        if roles.contains(.admin) || roles.contains(.user) || roles.contains(.draft) {

            navPath = .toMinView
        } else {

            // Navigate to user form
        }
    }

    /// Запрашиваем authUser
    private func getAuthProfile(authQueryModel: AuthQueryModel) async -> AuthTGRequestModel? {
        do {
            return await try service.sendTGToken(model: authQueryModel)
        } catch {
            print("neshko error \(error)")
            return nil
        }
    }
}


extension AuthSUIViewModel: WKUIDelegate, WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url,
           let tgKey = validateWebRequest(url: url) {
            telegramCallBack(tgKey: tgKey)
            print("Uspech")
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
    
    func webViewDidClose(_ webView: WKWebView) {
        webView.isHidden = true
        webView.endEditing(true)
        withAnimation {
            showWebView = false
        }
    }
}


extension AuthSUIViewModel {
    enum Constants {
        static let queryParamQuestion = "#"
        static let tgAuthResult = "tgAuthResult="
    }

    enum AuthViewModelPath {
        case authView
        case toInfoView
        case toMinView
    }
}
