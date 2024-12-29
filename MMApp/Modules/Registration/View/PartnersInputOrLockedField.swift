////
////  PartnersInputOrLockedField.swift
////  MMApp
////
////  Created by artem on 20.12.2024.
////
//
//import UIKit
//import Combine
//
//
//
///// Поле ввода, которое можно переключать в режим `Нередактируемое`
//final class PartnersInputOrLockedField: UIView, SubscriptionStore {
//    struct InputOrLockedField: Equatable {
//        /// Текст
//        var text: String
//        /// Редактирование недоступно
//        var locked: Bool
//    }
//    // MARK: - Public Properties
//
//    /// При каждом изменении текста в поле ввода
//    let textChangedSubject = PassthroughSubject<String?, Never>()
//
//    /// Начат ввод текста
//    let beginEditSubject = PassthroughSubject<Void, Never>()
//
//    /// Ввод текста завершён
//    let finishEditSubject = PassthroughSubject<Void, Never>()
//
//    /// Заголовок над полем ввода
//    @Published var title: String?
//
//    /// Поле валидно, данные введены корректно
//    @Published var isValid = false
//
//    /// Текст из поля ввода
//    var text: String?
//
//    /// Текст из поля ввода с учётом маски
//    var formattedText: String? {
//        isLocked ? lockedField.text : inputField.formattedText
//    }
//
//    /// Подсказка в поле ввода
//    var placeholderText: String? {
//        didSet { inputField.placeholderText = placeholderText }
//    }
//
//    /// Текст ошибки под полем ввода
//    var errorText: String? {
//        didSet { inputField.errorText = errorText }
//    }
//
////    /// Маска для числового текста
////    var numberMask: NuumTextInputFieldMaskProtocol? {
////        didSet {
////            inputField.numberMask = numberMask
////            inputField.keyboardType = .numberPad
////        }
////    }
//
//    /// Состояние поля ввода
//    var state: NuumTextInputField.InputState {
//        get { inputField.state }
//        set { inputField.setState(newValue) }
//    }
//
//    /// Редактирование текста недоступно
//    private(set) var isLocked = true
//
//    /// Автозаглавнй текст
//    var autocapitalizationType: UITextAutocapitalizationType {
//        get { return inputField.autocapitalizationType }
//        set { inputField.autocapitalizationType = newValue }
//    }
//
//    // MARK: - Private Properties
//
//    /// Контейнер для заголовка над полем ввода
//    private let titleContainer = UIView()
//
//    /// Лэйбл для заголовок над полем ввода
//    private let titleLabel = UILabel().apply {
//        $0.font = .bodySMedium
//        $0.textColor = .nuumTextSecondary
//    }
//
//    /// Заблокированное поле
//    private let lockedField = PartnersLockedField()
//
//    /// Поле ввода текста
//    private let inputField = NuumTextInputField()
//
//    // MARK: - Init
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        configureLayout()
//        bind()
//    }
//
//    @available(*, unavailable)
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    // MARK: - Publci Method
//
//    /// Одноразовая настройка поля
//    /// - Parameter onetimeConfig: конфигурация поля
//    func setupOneTimeConfig(onetimeConfig: OnetimeConfig) {
//        isLocked = onetimeConfig.locked
//
//        inputField.isHidden = isLocked
//        lockedField.isHidden = !isLocked
//
//        if isLocked {
//            lockedField.text = onetimeConfig.text
//            text = onetimeConfig.text
//        } else {
//            inputField.setText(onetimeConfig.text)
//        }
//
//        isValid = isLocked
//    }
//
//    /// Принудительно переключить поле ввода в целевое состояние
//    /// - Parameters:
//    ///   - state: целевое состояние
//    ///   - needClearField: очистить текст в поле ввода
//    func setState(
//        _ state: NuumTextInputField.InputState,
//        needClearField: Bool = false
//    ) {
//        inputField.setState(state, needClearField: needClearField)
//    }
//
//    /// Назначить текст в поле ввода
//    /// - Parameter string: текст введённый в поле ввода
//    func setText(_ string: String?) {
//        inputField.setText(string)
//    }
//
//    /// Получить кнофигурацию поля ввода, с текстом и признаком блокировки
//    /// - Returns: Конфигурация поля ввода
//    func getConfiguration() -> PartnersCreatePersonalDataModel.InputOrLockedField? {
//        guard let text = formattedText else { return nil }
//        return InputOrLocked(text: text, locked: isLocked)
//    }
//
//    // MARK: - Private Methods
//
//    /// Настроить вёрстку
//    private func configureLayout() {
//        let stack = [titleContainer, lockedField, inputField]
//            .toVerticalStackView()
//            .build()
//
//        addSubviews(stack)
//        titleContainer.addSubviews(titleLabel)
//
//        stack.snp.makeConstraints {
//            $0.edges.equalToSuperview()
//        }
//
//        titleLabel.snp.makeConstraints {
//            $0.height.equalTo(20)
//            $0.leading.equalToSuperview().inset(12)
//            $0.top.bottom.equalToSuperview()
//        }
//    }
//
//    /// Создать подписки
//    private func bind() {
//        $title
//            .removeDuplicates()
//            .receive(on: RunLoop.main)
//            .sink { [weak self] in
//                guard let text = $0, !text.isEmpty else {
//                    self?.titleContainer.isHidden = true
//                    return
//                }
//                self?.titleContainer.isHidden = false
//                self?.titleLabel.text = text
//            }
//            .store(in: &subscriptions)
//
//        inputField.textChangedSubject
//            .removeDuplicates()
//            .assignWeakly(to: \.text, on: self)
//            .store(in: &subscriptions)
//
//        inputField.beginEditSubject
//            .subscribe(beginEditSubject)
//            .store(in: &subscriptions)
//
//        inputField.finishEditSubject
//            .subscribe(finishEditSubject)
//            .store(in: &subscriptions)
//
//        inputField.textChangedSubject
//            .subscribe(textChangedSubject)
//            .store(in: &subscriptions)
//    }
//}
//
//extension PartnersInputOrLockedField {
//    /// Конфигурация поля ввода, устанавливается один раз
//    struct OnetimeConfig: Equatable {
//        /// Заблокировано
//        var locked = false
//        /// Текст в поле ввода
//        var text: String? {
//            didSet {
//                guard let text, !text.isEmpty else {
//                    locked = false
//                    return
//                }
//                locked = true
//            }
//        }
//
//        /// Создать конфигуратор для поля ввода на базе модели из личных данных
//        /// - Parameter field: Модель поля ввода ил личных данных
//        /// - Returns: Конфигуратор для поля ввода
//        static func configure(
//            _ field: PartnersCreatePersonalDataModel.InputOrLockedField?
//        ) -> OnetimeConfig {
//            guard let field else {
//                return OnetimeConfig()
//            }
//            return OnetimeConfig(
//                locked: field.locked,
//                text: field.text
//            )
//        }
//    }
//}
