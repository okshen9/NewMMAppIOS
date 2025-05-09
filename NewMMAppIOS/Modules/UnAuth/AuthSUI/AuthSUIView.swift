//
//  AuthSUIView.swift
//  TestUISwift
//
//  Created by artem on 25.03.2025.
//

import SwiftUI
import WebKit

struct AuthSUIView: View {
    @EnvironmentObject var appStateServise: AppNavigationStateService
    @EnvironmentObject var navigationManager: NavigationManager<AuthRoute>
    @StateObject private var viewModel = AuthSUIViewModel()

    @State private var showTerms = false
    @State private var showPrivacy = false

    var body: some View {
        ZStack {
            Color.manColor
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                if !viewModel.showWebView {
                    Image("man")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .cornerRadius(4)
                        .padding(.top, 80)

                    Spacer()
                }
                contentView
            }

            if viewModel.showWebView {
				WebView(url: URL(string: RequestUrls.tgStand)!,
                        navigationDelegate: viewModel,
                        uiDelegate: viewModel)
				.opacity(viewModel.showWebView ? 1 : 0)
                .edgesIgnoringSafeArea(.all)
                .transition(.opacity)
            }
        }
        .onAppear() {
            viewModel.navPath = .authView
        }
        .onChange(of: viewModel.navPath) { navPathOld, navPathNew in
            switch navPathNew {
            case .authView:
                break
            case .toInfoView:
                let authUser = UserRepository.shared.authUser?.authUserDto
                navigationManager.navigate(to: .signup(profileModel: nil, authModel: authUser))
            case .toMinView:
                appStateServise.setNewState(.authorized)
            }
        }
        .sheet(isPresented: $showTerms, content: {
            WebView(url: URL(string: "https://paymastermind.ru/privacy")!)
        })

    }

    private var contentView: some View {
        VStack(spacing: 16) {
            Text("Добро Пожаловать")
                .font(MMFonts.subTitle)
                .foregroundColor(.headerText)

            telegramButton

            Spacer()

            LinkedText(
                text: "Продолжая пользование приложением, я соглашаюсь с Порядком и условиями обработки персональных данных и Политикой конфиденциальности компании",
                links: [
                    "Порядком и условиями обработки персональных данных": .terms,
                    "Политикой конфиденциальности компании": .privacy
                ],
                action: { linkType in
                    switch linkType {
                    case .terms: showTerms = true
                    case .privacy: showPrivacy = true
                    }
                }
            )
            .font(MMFonts.subCaption)

            .foregroundColor(.subtitleText)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
        }
        .padding()
        .background(Color.secondbackGraund)
        .cornerRadius(20)
        .padding(.horizontal)
    }

    private var telegramButton: some View {
        Button(action: {
            withAnimation {
				viewModel.showWebView.toggle()
            }
        }) {
            HStack {
                Image(.tg)
                    .resizable()
                    .frame(width: 30, height: 30)
                    .cornerRadius(4)

                Text("Войти через Telegram")
                    .foregroundColor(.primary)
            }
            .padding()
            .background(Color.tgColor)
            .cornerRadius(16)
        }
    }
}

extension AuthSUIView {
    enum Constant {
        static let tgImageWidth = CGFloat(32)
    }

    enum NavPath {
        case infoUser
        case authScreen
    }
}

#Preview {
    AuthSUIView()
}
