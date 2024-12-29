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
    
    private let webView = WKWebView().apply {
        $0.alpha = 0
    }
    
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
        let request = URLRequest(url: URL(string: "https://oauth.telegram.org/auth?bot_id=7585753405&origin=http%3A%2F%2F194.87.93.98&embed=1&return_to=http%3A%2F%2F194.87.93.98%2Fauth%2Fauthentication")!)
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
    
    private func validateWebRequest(url: URL?, httpBody: Data?) {
        print("Neshko WEb URL: \(url)")
        print("Neshko WEb httpBody: \(httpBody)")
        guard
            let urlComponents = url?.absoluteString.components(
                separatedBy: Constants.tgAuthResult
            ),
            let tgKey = urlComponents[safe: 1],
            !tgKey.isEmpty
        else {
            return
        }
        print("Neshko weEnd \(tgKey)")
        webView.alpha = 0
    }
}

extension AuthVC: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = webView.url else { return }
        decisionHandler(.allow)
        validateWebRequest(
            url: url,
            httpBody: navigationAction.request.httpBody
        )
        let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems
        print("---------- Neshko Hui: ---- \(url) ----")
        
        
        if url.absoluteString.contains("") {
            
        }
    }

    
    
    func webView(
        _ webView: WKWebView,
        didFinish navigation: WKNavigation!
    ) {
        print("Neshko web didFinish \(navigation)")
    }

    func webView(
        _ webView: WKWebView,
        didFail navigation: WKNavigation!,
        withError error: Error
    ) {
        print("Neshko web didFail1 \(error)")
    }
    
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: any Error) {
        print(" +++ Neshko web didFail2 \(error)")
        guard let userInfo = (error as? NSError)?.userInfo["NSErrorFailingURLKey"]
        else { return }
        
        let urlComponents = (userInfo as? URL)?.absoluteString.components(
            separatedBy: Constants.tgAuthResult
        )
        
        guard
            let urlComponents,
            let tgKey = urlComponents[safe: 1]
        else {
            print(" === Neshko Error")
            return
        }
        
        let base64String = Data(tgKey.utf8).base64EncodedString()
        
        guard let decodedData = Data(base64Encoded: base64String),
              let decodedString = String(data: decodedData, encoding: .utf8)
        else {
                  print("Не удалось декодировать строку из Base64")
            return
        }
        
        let decodedString2 = decodeBase64(tgKey)
        
        guard
            let jsonData = decodedString.data(using: .utf8),
            let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
        else {
            print("Не удалось декодировать строку в jsonData")
            return
        }
        
        print(jsonObject)

        
        
        
        
        

    }
    
    
    
    func decodeBase64(_ input: String) -> String? {
        // Проверяем, является ли входящая строка корректной Base64 строкой
        guard let decodedData = Data(base64Encoded: input) else {
            return nil
        }
        
        // Преобразуем полученные данные обратно в строку
        return String(data: decodedData, encoding: .utf8)
    }
}



extension AuthVC {
    enum Constants {
        static let queryParamQuestion = "#"
        static let tgAuthResult = "tgAuthResult="
    }
}

