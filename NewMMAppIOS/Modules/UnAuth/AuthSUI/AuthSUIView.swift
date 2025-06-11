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
                    Image("mastermind")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .cornerRadius(4)
                        .padding(.top, 80)
                        .onTapGesture(count: 3, perform: {
                            viewModel.enableDemo = true
                            Task {
                                await ToastManager.shared.show(.init(message: "Вы разблокировали демо режим"))
                            }
                        })
                        .onLongPressGesture(minimumDuration: 3) {
                            if viewModel.enableDemo {
                                Task {
                                    await ToastManager.shared.show(.init(message: "Переход в демо режим"))
                                }
                                let demoKey = "eyJpZCI6NzgzNDI0MDI4NCwiZmlyc3RfbmFtZSI6IkRlbW8iLCJsYXN0X25hbWUiOiJBcHBsZSIsImF1dGhfZGF0ZSI6MTc0ODA5NTE0MywiaGFzaCI6IjYwNDc5MWY4YmY4MGQ0Y2Y0NmY0MmU4NzJjMDkzOGU2OWJhYmFiZjU1YTk1OWQ3YWM4NzM1YzI0MWYwYjg3YjYifQ"
                                viewModel.telegramCallBack(tgKey: demoKey)
                            }
                        }
                    brandingPoint()
                        .padding(.top, -100)

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
                .onDisappear(perform: {
                    print("MMM WebView onDisappear")
                })
            }
        }
        .onAppear() {
            viewModel.navPath = .authView
        }
        .onChange(of: viewModel.navPath) { navPathOld, navPathNew in
            guard navPathOld != navPathNew else { return }
            
            switch navPathNew {
            case .authView:
                break
            case .toInfoView:
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if !viewModel.showWebView {
                        let authUser = UserRepository.shared.authUser?.authUserDto
                        navigationManager.navigate(to: .signup(profileModel: nil, authModel: authUser))
                    }
//                }
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
                .disabled(viewModel.isLoding)

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
            .background(Color.tgColor.lighter(by: viewModel.isLoding ? 0.3 : 0))
            .cornerRadius(16)
        }
    }
    
    @ViewBuilder
    func brandingPoint() -> some View {
        HStack(alignment: .center, spacing: -16) {
            Image("gold")
                .resizable()
                .frameRect(60)
                .rotationEffect(.degrees(viewModel.isLoding ? 360 : 0))
                .animation(
                    Animation.linear(duration: 2)
                        .repeatForever(autoreverses: false),
                    value: viewModel.isLoding
                )
            Image("silver")
                .resizable()
                .frameRect(80)
                .rotationEffect(.degrees(viewModel.isLoding ? -360 : 0))
                .animation(
                    Animation.linear(duration: 2)
                        .repeatForever(autoreverses: false),
                    value: viewModel.isLoding
                )
                .padding(.leading, 8)
            Image("bronze")
                .resizable()
                .frameRect(70)
                .rotationEffect(.degrees(viewModel.isLoding ? 360 : 0))
                .animation(
                    Animation.linear(duration: 2)
                        .repeatForever(autoreverses: false),
                    value: viewModel.isLoding
                )
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
//    Text("")
}
