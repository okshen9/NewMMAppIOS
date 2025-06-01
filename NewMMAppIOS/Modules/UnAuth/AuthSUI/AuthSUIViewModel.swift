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
    
    /// дает возможность открыть демо режим
    @Published var enableDemo = false

    // MARK: - Methods
    /// проверяет есть ли ответ от телеги с данными в tgAuthResult
    func validateWebRequest(url: URL?) -> String? {
        guard let urlString = url?.absoluteString,
              let range = urlString.range(of: Constants.tgAuthResult) else { return nil }

        return String(urlString[range.upperBound...])
    }

    func telegramCallBack(tgKey: String) {
        Task {
            print("Neshko telegramCallBack")
            let authQueryModel = AuthQueryModel(tgData: tgKey)
            guard let authModel = await getAuthProfile(authQueryModel: authQueryModel) else {
                await MainActor.run {
                    // Сначала закрываем WebView
                    withAnimation {
                        showWebView = false
                    }
                    // Добавляем задержку перед изменением navPath
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.navPath = .authView
                    }
                }
                await ToastManager.shared.show(.init(message: "Не удалось загрузить пользователя"))
                return
            }
            UserRepository.shared.setAuthUser(authModel)
            await MainActor.run {
                // Сначала закрываем WebView
                withAnimation {
                    showWebView = false
                }
                // Добавляем задержку перед изменением navPath
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.handleNavigation(for: authModel.authUserDto)
                }
            }
        }
    }

    private func handleNavigation(for user: AuthUserDtoResult?) {
        guard let user else { return }
        print("Neshko handleNavigation")
        let roles = user.roles ?? []
        if roles.contains(.admin) || roles.contains(.user){
            navPath = .toMinView
        } else {
            navPath = .toInfoView
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
            UserRepository.shared.setTGData(tgKey)
            telegramCallBack(tgKey: tgKey)
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
    
    func webViewDidClose(_ webView: WKWebView) {
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

    enum AuthViewModelPath: Equatable {
        case authView
        case toInfoView
        case toMinView
    }
}
