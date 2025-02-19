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
    private(set) lazy var viewModel = AuthViewModel(self)
    
    
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
        $0.backgroundColor = .secondbackGraund
        $0.setCornerRadius(20)
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
        $0.text = "Войти через Telegram   "
        $0.backgroundColor = .clear
        $0.textAlignment = .left
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
    
    private let headerLabel = UILabel().apply {
        $0.text = "Добро Пожаловать"
        $0.backgroundColor = .clear
        $0.textColor = .headerText
        $0.font = .systemFont(ofSize: 18, weight: .bold)
        $0.textAlignment = .center
    }
    
//    private let linkLabel = UILabel().apply {
//        $0.text = "Продолжая пользование приложением, я соглашаюсь\n с Порядком и условиями обработки персональных данных\n и Политикой конфиденциальности компании"
//        $0.backgroundColor = .clear
//        $0.textColor = .subtitleText
//        $0.numberOfLines = 0
//        $0.font = .systemFont(ofSize: 12, weight: .regular)
//        $0.textAlignment = .center
//    }
    
    private let linkLabel: UILabel = {
        let label = UILabel()
        label.text = "Продолжая пользование приложением, я соглашаюсь\n с Порядком и условиями обработки персональных данных\n и Политикой конфиденциальности компании"
        label.backgroundColor = .clear
        label.textColor = .subtitleText
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .center
        
        // Добавление атрибутного текста с гиперссылками
        let text = """
        Продолжая пользование приложением, я соглашаюсь\n с Порядком и условиями обработки персональных данных\n и Политикой конфиденциальности компании
        """
        let attributedString = NSMutableAttributedString(string: text)
        
        // Настройка подчеркивания ссылок
        let termsRange = (text as NSString).range(of: "Порядком и условиями обработки персональных данных")
        let privacyRange = (text as NSString).range(of: "Политикой конфиденциальности компании")
        
        attributedString.addAttributes(
            [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .foregroundColor: label.textColor as Any
            ],
            range: termsRange
        )
        attributedString.addAttributes(
            [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .foregroundColor: label.textColor as Any
            ],
            range: privacyRange
        )
        
        label.attributedText = attributedString
        label.isUserInteractionEnabled = true // Включение взаимодействия
        
        // Добавление жеста для обработки касаний
        let tapGesture = UITapGestureRecognizer(target: AuthVC.self, action: #selector(handleTapOnLabel(_:)))
        label.addGestureRecognizer(tapGesture)
        
        return label
    }()
    
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
        //        clearWebViewCache()
        // END: -
        
        guard viewModel.chekSavedKey() else {
            if let role = UserDefaultsStorege.role.getData(),
               !role.isEmpty,
               role != "ROLE_DRAFT",
               role != "UNKNOWN"{
                
                
                viewModel.telegramCallBack()
            } else {
                viewModel.telegramCallBack()
            }
            
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
            
            [self?.headerLabel,
            self?.telegramStack,
             self?.linkLabel].forEach({
                $0?.alpha = 0
            })
            
            
            
            
            
        })
    }
    
    
    
    private func configureViews() {
        telegramStack.addArrangedSubviews([telegramImageView, telegramLabel])
        contentView.addSubviews(headerLabel, telegramStack, webView, linkLabel)
        view.addSubviews(manImageView, contentView)
    }
    
    private func configureLayout() {
        configureViews()
        
        manImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(80)
        }
        
        contentView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(self.view.snp.centerY)
        }
        
        telegramStack.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(headerLabel.snp.bottom).offset(16)
            make.height.equalTo(40)
        }
        
        headerLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(16)
            make.trailing.equalToSuperview().inset(8)
        }
        
        telegramImageView.snp.makeConstraints { make in
            make.size.equalTo(30)
            make.leading.equalToSuperview().inset(8)
        }
        
        webView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        linkLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
    }
    
    
    @objc private func handleTapOnLabel(_ gesture: UITapGestureRecognizer) {
        guard let label = gesture.view as? UILabel,
              let text = label.attributedText?.string else { return }
        
        let termsRange = (text as NSString).range(of: "Порядком и условиями обработки персональных данных")
        let privacyRange = (text as NSString).range(of: "Политикой конфиденциальности компании")
        
        let tapLocation = gesture.location(in: label)
        guard let textPosition = label.characterIndex(at: tapLocation) else { return }
        
        if NSLocationInRange(textPosition, termsRange) {
            print("Tapped on: Порядком и условиями обработки персональных данных")
            // Добавьте переход на нужный экран или открытие ссылки
        } else if NSLocationInRange(textPosition, privacyRange) {
            print("Tapped on: Политикой конфиденциальности компании")
            // Добавьте переход на нужный экран или открытие ссылки
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


private extension UILabel {
    func characterIndex(at point: CGPoint) -> Int? {
        guard let attributedText = attributedText, let font = font else { return nil }
        
        let textStorage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: bounds.size)
        textContainer.lineFragmentPadding = 0.0
        textContainer.maximumNumberOfLines = numberOfLines
        textContainer.lineBreakMode = lineBreakMode
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        let location = layoutManager.glyphIndex(for: point, in: textContainer)
        return location
    }
}
