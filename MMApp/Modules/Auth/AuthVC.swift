//
//  AuthVC.swift
//  MMApp
//
//  Created by artem on 17.12.2024.
//

import UIKit
import SnapKit
import Combine
import WebKit

class AuthVC: UIViewController, SubscriptionStore {
    // MARK: Private Property
    private var isLogined = false
    private(set) var viewModel = AuthViewModel()
    
    
    // MARK: Live cicle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureLayout()
        bind()
        webView.navigationDelegate = self
        self.view.backgroundColor = .manColor
    }
    
    //  MARK: Private propertis
    private let contentView = UIView().apply {
        $0.backgroundColor = .lightGray
        $0.setCornerRadius(8)
    }
    
    private let manImageView = UIImageView().apply {
        $0.image = UIImage.man
        $0.setCornerRadius(4)
    }
    
    private let telegramImageView = UIImageView().apply {
        $0.image = UIImage.tg
        $0.setCornerRadius(4)
    }
    
    private let telegramLabel = UILabel().apply {
        $0.text = "Авторизируйся через telegram"
        $0.backgroundColor = .clear
        $0.setCornerRadius(4)
    }
    
    
    private let telegramStack = UIStackView().apply({
        $0.axis = .horizontal
        $0.spacing = 5
        $0.backgroundColor = UIColor.tgColor
        $0.setCornerRadius(8)
        $0.alignment = .center
        $0.distribution = .equalCentering
    })
    
    private let testLabel = UILabel().apply {
        $0.text = "Развивайся с нами"
        $0.backgroundColor = .clear
        $0.setCornerRadius(4)
        $0.textAlignment = .center
    }
    
    private let webView: WKWebView = {
        let config = WKWebViewConfiguration()
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.alpha = 0
        return webView
    }()
    
    // MARK: - Private Methods
    private func bind() {
        telegramStack.publisher
            .handleEvents(
                receiveSubscription: {_ in
                    print("Neshko receiveSubscription")
                },
                receiveOutput: {_ in
                    print("Neshko receiveOutput")
                },
                receiveCompletion: {_ in
                    print("Neshko receiveCompletion")
                },
                receiveCancel: {
                    print("Neshko receiveCancel")
                },
                receiveRequest: {_ in
                    print("Neshko receiveRequest")
                }
            )
            .sink{ [weak self] _ in
                print("Neshko Hui")
                self?.openWebView()
            }
            .store(in: &subscriptions)
        
        contentView.publisher
            .handleEvents(
                receiveSubscription: {_ in
                    print("0Neshko receiveSubscription")
                },
                receiveOutput: {_ in
                    print("0Neshko receiveOutput")
                },
                receiveCompletion: {_ in
                    print("0Neshko receiveCompletion")
                },
                receiveCancel: {
                    print("0Neshko receiveCancel")
                },
                receiveRequest: {_ in
                    print("0Neshko receiveRequest")
                }
            )
            .sink{ [weak self] _ in
                print("Neshko Hui")
                self?.openWebView()
            }
            .store(in: &subscriptions)
    }
    
    
    private func openWebView() {
        // TODO: Убрать - чистку кешей веб вью при открытии webview
        clearWebViewCache()
        // END: -
        
        guard viewModel.chekSavedKey() else {
            return
        }
        let request = URLRequest(url: URL(string: Constants.tgBotdev)!)
        webView.load(request)
        
        contentView.snp.remakeConstraints({ make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalToSuperview { $0.safeAreaLayoutGuide }.inset(8)
        })
        
        UIView.animate(withDuration: 0.5, animations: {[weak self] in
            self?.webView.alpha = 1
            self?.view.layoutIfNeeded()
        })
    }
    
    
    
    private func configureViews() {
        telegramStack.addArrangedSubviews([telegramImageView, telegramLabel])
        contentView.addSubviews(telegramStack, testLabel, webView)
        view.addSubviews(manImageView, contentView)
    }
    
    private func configureLayout() {
        configureViews()
        
        manImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(80)
        }
        
        contentView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(self.view.snp.centerY).offset(50)
        }
        
        telegramStack.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(16)
            make.height.equalTo(30)
        }
        
        testLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(telegramStack.snp.bottom).offset(16)
            make.trailing.equalToSuperview().inset(8)
        }
        
        telegramImageView.snp.makeConstraints { make in
            make.size.equalTo(30)
            make.leading.equalToSuperview().inset(8)
        }
        
        webView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}


extension AuthVC {
    enum Constants {
        static let queryParamQuestion = "#"
        static let tgAuthResult = "tgAuthResult="
        static let tgBotdev = "https://oauth.telegram.org/auth?bot_id=7585753405&origin=http%3A%2F%2F194.87.93.98&embed=1&return_to=http%3A%2F%2F194.87.93.98%2Fauth%2Fauthentication"
        static let tgBotLocalHost = "https://oauth.telegram.org/auth?bot_id=7621034824&origin=http%3A%2F%2F127.0.0.1&embed=1&return_to=http%3A%2F%2F127.0.0.1%2Fauth%2Fauthentication"
    }
}

