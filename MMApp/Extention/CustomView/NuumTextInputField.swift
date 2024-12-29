//
//  NuumTextInputField.swift
//  MMApp
//
//  Created by artem on 20.12.2024.
//

import UIKit
import SnapKit
import Combine


/// Поле ввода текста.
/// - Parameters:
///   - text: Чистый текст из поля ввода
///   - formattedText: Текст из поля ввода с учётом маски
///   - placeholderText: Текст подсказки в поле ввода
///   - title: Текст заголовка над полем ввода
///   - errorText: Текст ошибки под полем ввода
///   - numberMask: Маска для числового текста
///   - crossButtonEnabled: Скрыть крестик
///   - secure: Защищённый режим ввода текста
///   - disabled: Заблокировать ввода текста
///   - inputLeftView: Левый контейнер для размещения доп.элемнтов в поле ввода
///   - inputRightView: Правый контейнер для размещения доп.элемнтов в поле ввода
///   - state: Состояние поля ввода
///   - keyboardType: Тип клавиатуры
//final class NuumTextInputField: UIView, Binder, SubscriptionStore {
//    // MARK: - Constants
//
//    private enum Constants {
//        static let inputHeight: CGFloat = 48
//        static let textPadding = UIEdgeInsets(top: 12, left: 18, bottom: 12, right: 42)
//
//        static let httpMask = "http://"
//        static let httpsMask = "https://"
//
//        enum Counter {
//            static let insets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 5.0)
//            static let font = UIFont.captionMRegular
//            enum Colors {
//                static let text = UIColor(.textTertiarly)
//            }
//        }
//    }
//
//    enum TextInputType {
//        case dropDown
//        case defaultType
//        case link
//    }
//
//    enum InputState {
//        /// поле не в фокусе, текста нет (плэйсхолдер опционально)
//        case inactive
//        /// поле в фокусе, пользователь вводит текст
//        case active
//        /// поле не в фокусе, есть текст, валидация прошла успешно
//        case filled
//        /// поле не в фокусе, есть текст, валидация не прошла
//        case error
//        /// поле не в фокусе, есть текст, бордер зеленый + зеленая галочка справа
//        case success
//        /// поле не в фокусе, есть текст, справа крутится лоадер
//        case loading
//        /// поле не доступно для изменений (визуал общий: с текстом или без)
//        case disabled
//
//        var backgroundColor: UIColor {
//            switch self {
//            case .inactive, .filled, .success, .loading, .error: return UIColor.nuumLayerSecondTransparent
//            case .active: return UIColor.layerFirstTransparent
//            case .disabled: return UIColor.layerSecond
//            }
//        }
//
//        var borderColor: CGColor {
//            switch self {
//            case .inactive, .filled, .loading, .disabled: return UIColor.clear.cgColor
//            case .active: return UIColor.nuumControlBorderActive.cgColor
//            case .error: return UIColor.nuumControlNegativeDefault.cgColor
//            case .success: return UIColor.nuumControlSuccessDefault.cgColor
//            }
//        }
//
//        var textColor: UIColor {
//            switch self {
//            case .disabled: return UIColor.textTertiary
//            default: return UIColor.textPrimary
//            }
//        }
//
//        var placeholderColor: UIColor {
//            switch self {
//            case .inactive, .active, .filled, .success, .loading, .error: return UIColor.nuumTextTertiary
//            case .disabled: return UIColor.textTertiary
//            }
//        }
//    }
//
//    /// Маска для текста
//    /// - Parameter pattern: Маска ввода. Пример `### ###-##-#`
//    /// - Parameter replacementCharacter: Символ заполнителя для замены. Пример: `#`
//    struct InputMask: NuumTextInputFieldMaskProtocol {
//        let pattern: String
//        let replacementCharacter: Character
//
//        var maxFormattedTextLenght: Int {
//            pattern.count
//        }
//
//        var maxTextLength: Int {
//            pattern.count - pattern.replacingOccurrences(of: String(replacementCharacter), with: "").count
//        }
//
//        func formate(_ string: String?) -> String? {
//            guard let string = string else { return string }
//            return string.applyPattern(pattern: pattern, replacementCharacter: replacementCharacter)
//        }
//    }
//
//    /// Маска для числового текста
//    /// - Parameter pattern: Маска ввода. Пример `### ###-##-#`
//    /// - Parameter replacementCharacter: Символ заполнителя для замены. Пример: `#`
//    struct NumberMask: NuumTextInputFieldMaskProtocol {
//        let pattern: String
//        let replacementCharacter: Character
//
//        var maxFormattedTextLenght: Int {
//            pattern.count
//        }
//
//        var maxTextLength: Int {
//            pattern.count - pattern.replacingOccurrences(of: String(replacementCharacter), with: "").count
//        }
//
//        func formate(_ string: String?) -> String? {
//            guard let string = string else { return string }
//            return string.applyPatternOnNumbers(
//                pattern: pattern,
//                replacementCharacter: replacementCharacter
//            )
//        }
//    }
//
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
//    /// При каждом изменении состояния поля ввода
//    let stateChangedSubject = PassthroughSubject<InputState, Never>()
//
//    /// Принудительный взов валидации
//    let validateSubject = PassthroughSubject<Void, Never>()
//
//    /// Перевести фокус на поле ввода
//    let makeFirstResponder = PassthroughSubject<Void, Never>()
//
//    /// Состояние поля ввода
//    private(set) var state: InputState = .inactive {
//        didSet {
//            updateAppearance()
//            stateChangedSubject.send(state)
//        }
//    }
//
//    /// Чистый текст из поля ввода
//    private(set) var text: String?
//
//    /// Текст из поля ввода с учётом маски
//    private(set) var formattedText: String?
//
//    /// Текст подсказки в поле ввода
//    var placeholderText: String? {
//        didSet { updatePlaceholderText() }
//    }
//
//    /// Цвет текста подсказки в поле ввода
//    var placeholderColor: UIColor? {
//        didSet { updatePlaceholderText() }
//    }
//
//    /// Обязательное ли поле
//    /// добавляем *
//    var isRequiredInput = false
//
//    /// Делать ли первый символ заглавным
//    var isFirstCharOnUppercase = false
//
//    /// Ограничитель символов
//    var maxTextLength: Int?
//
//    /// Тип NuumTextInputField
//    var textInputType = TextInputType.defaultType {
//        didSet {
//            switch textInputType {
//            case .dropDown:
//                inputRightView.isHidden = true
//                inputLeftView.isHidden = true
//                textField.rightViewMode = .always
//                textField.rightView = UIImageView(.icChevronDown).apply { $0.contentMode = .scaleAspectFit }
//                textField.textInsets = Constants.textPadding
//            default:
//                break
//            }
//        }
//    }
//
//    // шрифт для ограничителя символов
//    var symbolCountLabelFont = Constants.Counter.font {
//        didSet { symbolCountLabel.font = symbolCountLabelFont }
//    }
//
//    // цвет для ограничителя символов
//    var symbolCountLabelTextColor = Constants.Counter.Colors.text {
//        didSet { symbolCountLabel.textColor = symbolCountLabelTextColor }
//    }
//
//    /// Текст заголовка над полем ввода
//    var title: String? {
//        didSet { updateTitle() }
//    }
//
//    /// Нужно ли показывать кнопку готово над клавиатурой
//    var isNeedToShowDoneToolbar = false {
//        didSet {
//            textField.inputAccessoryView = makeDoneToolbar()
//        }
//    }
//
//    /// Нужно ли валидировать поле ввода при выходе из фокуса
//    var shouldValidate: Bool?
//
//    /// Текст ошибки под полем ввода
//    var errorText: String? {
//        didSet { errorLabel.text = errorText }
//    }
//
//    /// Шрифт ошибки под полем ввода
//    var errorFont: UIFont? {
//        didSet { errorLabel.font = errorFont }
//    }
//
//    /// Текст под полем ввода
//    var subtitleText: String? {
//        didSet {
//            subtitleLabel.text = subtitleText
//            subtitleView.isHidden = subtitleText != nil && !(subtitleText!.isEmpty)
//        }
//    }
//
//    /// Скрыть крестик
//    var crossButtonEnabled = true {
//        didSet { crossButton.isHidden = !crossButtonEnabled }
//    }
//
//    /// Маска для числового текста
//    var numberMask: NuumTextInputFieldMaskProtocol?
//
//    /// Тип клавиатуры. По умолчанию: буквы + цифры
//    var keyboardType = UIKeyboardType.default {
//        didSet { textField.keyboardType = keyboardType }
//    }
//
//    /// Защищённый режим ввода текста. По умолчанию вводимый текст виден
//    var secure: Bool {
//        get { return textField.isSecureTextEntry }
//        set { textField.isSecureTextEntry = newValue }
//    }
//
//    /// Заблокировать ввода текста
//    var disabled = false {
//        didSet { updateAvailability() }
//    }
//
//    /// Левый контейнер для размещения доп.элемнтов в поле ввода
//    let inputLeftView = UIView()
//    /// Правый контейнер для размещения доп.элемнтов в поле ввода
//    let inputRightView = UIView()
//
//    /// Вставка текста в поле ввода вкл / выкл
//    var isPasteActionEnabled = true {
//        didSet { textField.isPasteActionEnabled = isPasteActionEnabled }
//    }
//
//    /// Автозаглавнй текст
//    var autocapitalizationType: UITextAutocapitalizationType {
//        get { return textField.autocapitalizationType }
//        set { textField.autocapitalizationType = newValue }
//    }
//
//    /// Свойство указывает, нужно ли скрывать крестик на пустое поле
//    var isNeedCrossButtonOnEmptyField = false
//
//    /// Поле ввода в фокусе
//    var isInputFirstResponder: Bool {
//        textField.isFirstResponder
//    }
//
//    // MARK: - Private Properties
//
//    /// Контейнер для заголовка над полем ввода
//    let titleContainerView = UIView()
//
//    /// Поле ввода
//    private let textField = PaddingTextField().apply {
//        $0.font = .bodyMRegular
//        $0.textColor = UIColor(.nuumTextPrimary)
//        $0.autocapitalizationType = .none
//        $0.autocorrectionType = .no
//    }
//
//    /// Контейнер для поля ввода и боковых контейнеров
//    private let inputBackgroundView = UIView().apply {
//        $0.layer.borderWidth = 1
//        $0.layer.cornerRadius = Constants.inputHeight / 2
//    }
//
//    /// Нижний контейнер для отображения ошибки под полем ввода
//    private let errorView = UIView().apply {
//        $0.isHidden = true
//    }
//
//    /// Лэйбл для отображения текста ошибки под полелм ввода
//    private let errorLabel = UILabel().apply {
//        $0.font = .bodyMRegular
//        $0.numberOfLines = 0
//        $0.textColor = UIColor(.nuumTextError)
//    }
//
//    /// Нижний контейнер для отображения текста под полем ввода
//    private let subtitleView = UIView().apply {
//        $0.isHidden = true
//    }
//
//    /// Лэйбл для отображения текста под полем ввода
//    private let subtitleLabel = UILabel().apply {
//        $0.font = .bodySRegular
//        $0.numberOfLines = 0
//        $0.textColor = UIColor(.nuumTextTertiary)
//    }
//
//    private let crossButton = UIButton().apply {
//        $0.setImage(UIImage(.crossMedium).withRenderingMode(.alwaysTemplate), for: .normal)
//        $0.tintColor = UIColor(.nuumTextHeadline)
//        if #available(iOS 15.0, *) {
//            $0.configuration?.imagePadding = 10
//        } else {
//            $0.imageEdgeInsets = UIEdgeInsets.all(10)
//        }
//    }
//
//    private lazy var symbolCountLabel = UILabel().apply {
//        $0.font = symbolCountLabelFont
//        $0.textColor = symbolCountLabelTextColor
//        $0.numberOfLines = 1
//        $0.backgroundColor = .clear
//        $0.textAlignment = .right
//    }
//
//    /// Контейнер для иконки замка, когда ввод текста заблокирован
//    private let lockIconContainer = UIView()
//
//    /// Делегат поля ввода
//    weak var delegate: NuumTextInputFieldDelegateProtocol?
//
//    // MARK: - Init
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        configureLayout()
//        updateAppearance()
//        bind()
//
//        textField.delegate = self
//    }
//
//    @available(*, unavailable)
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    // MARK: - Public Methods
//
//    /// Получить фокус на поле ввода
//    public func grabFocus() {
//        self.textField.becomeFirstResponder()
//    }
//
//    /// Добавление ограничение по вводу символов
//    /// - Parameter maxTextLength: Int
//    func setSymbolCounter(maxTextLength: Int) {
//        let titleLabel = titleContainerView.subviews.first as? UILabel
//        titleContainerView.addSubview(symbolCountLabel)
//        symbolCountLabel.snp.makeConstraints {
//            $0.top.equalToSuperview()
//            $0.trailing.equalToSuperview().inset(12)
//            $0.bottom.equalToSuperview().inset(4)
//            if let titleLabel = titleLabel {
//                $0.leading.equalTo(titleLabel.snp.trailing)
//            }
//        }
//        self.maxTextLength = maxTextLength
//        symbolCountLabel.text = "0/\(maxTextLength)"
//    }
//
//    /// Назначить текст в поле ввода
//    /// - Parameter string: текст введённый в поле ввода
//    /// - Parameter isNeedToChange: нужно ли передавать событие об изменение текста в поле
//    func setText(_ string: String?, isNeedToChange: Bool = true) {
//        if let string {
//            if let mask = numberMask {
//                text = string.replacingOccurrences(
//                    of: "[^0-9]",
//                    with: "",
//                    options: .regularExpression
//                )
//                formattedText = mask.formate(string)
//            } else {
//                if let maxTextLength = maxTextLength {
//                    let range = 0...maxTextLength
//                    // проверяем огранничение по кол-во символов
//                    guard range.contains(string.count) else {
//                        return
//                    }
//                    symbolCountLabel.text = "\(string.count)/\(maxTextLength)"
//                }
//
//                text = isFirstCharOnUppercase ? string.becomeFirstUpperChar() : string
//                formattedText = text
//            }
//        } else {
//            text = nil
//            formattedText = nil
//            symbolCountLabel.text = "0/\(maxTextLength.orZero)"
//        }
//
//        if isNeedCrossButtonOnEmptyField {
//            crossButtonEnabled = !text.isEmptyOrNil
//        }
//
//        textField.text = formattedText ?? text
//
//        if isNeedToChange {
//            textChangedSubject.send(string)
//        }
//    }
//
//    /// Принудительно переключить поле ввода в целевое состояние
//    /// - Parameters:
//    ///   - state: целевое состояние
//    ///   - needClearField: очистить текст в поле ввода
//    func setState(_ state: InputState, needClearField: Bool = false) {
//        if self.state == state { return }
//        if needClearField {
//            textField.resignFirstResponder()
//            text = nil
//            formattedText = .empty
//            textField.text = nil
//            symbolCountLabel.text = "0/\(maxTextLength.orZero)"
//        }
//        self.state = state
//    }
//    /// Очистка правого контейнера
//    func clearRightView() {
//        inputRightView.subviews.forEach { $0.removeFromSuperview() }
//    }
//
//    /// Принудительно перевести поле ввода в состояние .loading
//    /// - Parameters:
//    ///   - isLoading: целевое состояние
//    func setLoadingState(_ isLoading: Bool) {
//        clearRightView()
//        crossButtonEnabled = false
//        if isLoading {
//            let activityIndicator = CustomActivityIndicator(image: ImageName.whiteLoader()).apply {
//                $0.startAnimating()
//            }
//
//            inputRightView.addSubview(activityIndicator)
//            activityIndicator.snp.makeConstraints {
//                $0.size.equalTo(24)
//                $0.centerY.equalToSuperview()
//                $0.trailing.equalToSuperview().inset(12)
//            }
//            state = .loading
//        } else {
//            state = !text.isEmptyOrNil ? .filled : .inactive
//        }
//    }
//    /// Принудительно перевести поле ввода в состояние .success
//    func setSuccessState(isSuccess: Bool) {
//        clearRightView()
//        crossButtonEnabled = false
//        state = .success
//        if isSuccess {
//            let checkChevron = UIImageView(.icCheckRoundGreen24)
//
//            inputRightView.addSubview(checkChevron)
//            checkChevron.snp.makeConstraints {
//                $0.size.equalTo(24)
//                $0.centerY.equalToSuperview()
//                $0.trailing.equalToSuperview().inset(12)
//            }
//        } else {
//            state = !text.isEmptyOrNil ? .filled : .inactive
//        }
//    }
//
//    // MARK: - Private Methods
//
//    private func configureLayout() {
//        let rootStack = [titleContainerView,
//                         inputBackgroundView,
//                         errorView,
//                         subtitleView]
//            .toVerticalStackView()
//            .build()
//
//        addSubview(rootStack)
//
//        rootStack.snp.makeConstraints {
//            $0.edges.equalToSuperview()
//        }
//
//        titleContainerView.snp.makeConstraints {
//            $0.height.greaterThanOrEqualTo(0)
//            $0.height.equalTo(0).priority(.medium)
//        }
//
//        inputBackgroundView.snp.makeConstraints {
//            $0.height.equalTo(Constants.inputHeight)
//        }
//
//        let inputStack = [inputLeftView,
//                          textField,
//                          crossButton,
//                          lockIconContainer,
//                          inputRightView]
//            .toHorizontalStackView()
//            .with(spacing: -10, after: crossButton)
//            .build()
//
//        /// Контейнер для горизонтального стэка с полем ввода
//        inputBackgroundView.addSubview(inputStack)
//
//        inputStack.snp.makeConstraints {
//            $0.edges.equalToSuperview()
//        }
//
//        inputLeftView.snp.makeConstraints {
//            $0.width.greaterThanOrEqualTo(16)
//            $0.width.equalTo(16).priority(.medium)
//        }
//
//        crossButton.snp.makeConstraints {
//            $0.size.equalTo(Constants.inputHeight)
//        }
//
//        lockIconContainer.snp.makeConstraints {
//            $0.width.greaterThanOrEqualTo(0)
//            $0.width.equalTo(0).priority(.medium)
//        }
//
//        inputRightView.snp.makeConstraints {
//            $0.width.greaterThanOrEqualTo(16)
//            $0.width.equalTo(16).priority(.medium)
//        }
//
//        /// Контейнер для текста ошибки под полем ввода
//        errorView.addSubview(errorLabel)
//
//        errorView.snp.makeConstraints {
//            $0.height.greaterThanOrEqualTo(0)
//            $0.height.equalTo(0).priority(.medium)
//        }
//
//        errorLabel.snp.makeConstraints {
//            $0.top.equalToSuperview().inset(4)
//            $0.leading.trailing.equalToSuperview().inset(12)
//            $0.bottom.equalToSuperview()
//        }
//
//        /// Контейнер для текста под полем ввода
//        subtitleView.addSubview(subtitleLabel)
//
//        subtitleLabel.snp.makeConstraints {
//            $0.top.equalToSuperview().inset(4)
//            $0.leading.trailing.equalToSuperview().inset(12)
//            $0.bottom.equalToSuperview()
//        }
//    }
//
//    private func bind() {
//        inputBackgroundView.publisher.sink { [weak self] _ in
//            self?.textField.becomeFirstResponder()
//        }
//        .store(in: &subscriptions)
//
//        crossButton.tapPublisher.sink { [weak self] _ in
//            self?.setText(nil)
//        }
//        .store(in: &subscriptions)
//
//        validateSubject
//            .sink { [weak self] _ in
//                switch self?.textInputType {
//                case .dropDown:
//                    self?.validateDropDown()
//                case .link:
//                    self?.validateLink()
//                default:
//                    self?.validate()
//                }
//            }.store(in: &subscriptions)
//
//        makeFirstResponder
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] in
//                self?.textField.becomeFirstResponder()
//            }
//            .store(in: &subscriptions)
//    }
//
//    private func updateAppearance() {
//        inputBackgroundView.layer.borderColor = state.borderColor
//        inputBackgroundView.backgroundColor = state.backgroundColor
//        textField.textColor = state.textColor
//        errorView.isHidden = state != .error
//        subtitleLabel.isHidden = state == .error
//        crossButton.isHidden = crossButtonEnabled ? (state != .active) : true
//    }
//
//    private func validate() {
//        /// проверяем обязательность валидации поля
//        if let shouldValidate, !shouldValidate {
//            state = .filled
//            finishEditing()
//            return
//        }
//
//        if let mask = numberMask {
//            if let formattedText = formattedText {
//                state = formattedText.count == mask.maxFormattedTextLenght ? .filled : .error
//            } else {
//                state = .error
//            }
//        } else {
//            if let text = text {
//                state = text.isEmpty ? .error : .filled
//            } else {
//                state = .inactive
//            }
//        }
//        finishEditing()
//    }
//
//    private func validateDropDown() {
//        guard textInputType == .dropDown else { return }
//
//        switch text {
//        case _ where text == nil:
//            state = .error
//        case _ where text?.isEmpty == true:
//            state = .error
//        case _ where text?.isEmpty == false:
//            state = .inactive
//        default:
//            state = .filled
//        }
//    }
//
//    private func validateLink() {
//        guard let text, !text.isEmpty else {
//            state = .filled
//            return
//        }
//
//        // Регулярное выражение для валидации URL-адреса
//        let urlRegEx = #"^((https|http)://)([\w-]+\.)+[a-z]{2,}(\/[\w\-\/?=&+%]*)?$"# // Пример
//        let urlPredicate = NSPredicate(format: "SELF MATCHES %@", urlRegEx)
//        if urlPredicate.evaluate(with: text) {
//            state = .filled
//        } else {
//            state = .error
//        }
//    }
//
//    private func finishEditing() {
//        finishEditSubject.send()
//    }
//
//    private func updateTitle() {
//        titleContainerView.subviews.forEach { $0.removeFromSuperview() }
//
//        if let str = title, !str.isEmpty {
//            let label = UILabel()
//            label.font = .bodySMedium
//            label.attributedText = setTitle(title: str)
//
//            titleContainerView.addSubview(label)
//
//            label.snp.makeConstraints {
//                $0.top.equalToSuperview()
//                $0.leading.equalToSuperview().inset(12)
//                $0.bottom.equalToSuperview().inset(4)
//                $0.trailing.lessThanOrEqualToSuperview().inset(12)
//            }
//        }
//    }
//
//    private func setTitle(title: String) -> NSAttributedString? {
//        let titleAttributes: [NSAttributedString.Key: Any] = [
//            .foregroundColor: UIColor(.nuumTextSecondary)
//        ]
//
//        let titleAttributed = NSAttributedString(string: title, attributes: titleAttributes)
//
//        guard isRequiredInput else {
//            return titleAttributed
//        }
//
//        let requiredAttributes: [NSAttributedString.Key: Any] = [
//            .foregroundColor: UIColor(.nuumTextError)
//        ]
//
//        let requiredAttributed = NSAttributedString(string: "*", attributes: requiredAttributes)
//
//        let combinedAttributedString = NSMutableAttributedString()
//        combinedAttributedString.append(titleAttributed)
//        combinedAttributedString.append(requiredAttributed)
//
//        return combinedAttributedString
//    }
//
//    private func updateAvailability() {
//        lockIconContainer.subviews.forEach { $0.removeFromSuperview() }
//
//        if disabled {
//            let lockIcon = UIImageView()
//            lockIcon.image = UIImage(.icLock24).withRenderingMode(.alwaysTemplate)
//            lockIcon.tintColor = UIColor(.nuumTextTertiary)
//
//            lockIconContainer.addSubview(lockIcon)
//
//            lockIcon.snp.makeConstraints {
//                $0.size.equalTo(24)
//                $0.centerY.equalToSuperview()
//                $0.leading.equalToSuperview().inset(8)
//                $0.trailing.equalToSuperview()
//            }
//
//            isUserInteractionEnabled = false
//            state = .disabled
//        } else {
//            isUserInteractionEnabled = true
//            state = (text != nil && !(text!.isEmpty)) ? .filled : .inactive
//        }
//    }
//}
//
//// MARK: - Text Field Delegate
//
//extension NuumTextInputField: UITextFieldDelegate {
//    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        state = .active
//        return textInputType != .dropDown
//    }
//
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        beginEditSubject.send()
//    }
//
//    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
//        validate()
//        return true
//    }
//
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        return true
//    }
//
//    func textField(
//        _ textField: UITextField,
//        shouldChangeCharactersIn range: NSRange,
//        replacementString string: String
//    ) -> Bool {
//        guard textInputType != .dropDown else { return false }
//
//        if let delegate {
//            return delegate.textField(
//                textField,
//                shouldChangeCharactersIn: range,
//                replacementString: string
//            )
//        }
//
//        var text = text ?? ""
//        let maskedText = formattedText ?? ""
//
//        var cursorePos: Int?
//
//        if maskedText.isEmpty {
//            text.append(string)
//        } else {
//            if (!string.isEmpty) && (range.location >= maskedText.count) {
//                // Добавление текста в конце строки
//                if let numberMask = numberMask,
//                   numberMask.pattern.count == maskedText.count {
//                    return false
//                }
//                text.append(string)
//            } else if string.isEmpty && range.location >= (maskedText.count - 1) {
//                // Удаление текста в конце строки
//                text.removeLast()
//            } else {
//                // Редактирование текста внутри строки
//                if let numberMask = numberMask {
//                    let offset: Int = string.isEmpty ? (range.location + 1) : range.location
//                    let currentIdxInMask = String.Index(utf16Offset: offset, in: numberMask.pattern)
//                    let substringMask = String(numberMask.pattern[..<currentIdxInMask])
//                    let pureSubstringMask = substringMask.replacingOccurrences(
//                        of: String(numberMask.replacementCharacter),
//                        with: ""
//                    )
//                    let countMaskSymbols = pureSubstringMask.count
//                    let targetIdxInText = range.location - countMaskSymbols
//
//                    if targetIdxInText >= 0 {
//                        let charIdx = text.index(text.startIndex, offsetBy: targetIdxInText)
//                        if !string.isEmpty, let char = string.first {
//                            if maskedText.count >= numberMask.pattern.count {
//                                return false
//                            }
//                            text.insert(char, at: charIdx)
//                            cursorePos = range.location + 1
//                        } else {
//                            text.remove(at: charIdx)
//                            if substringMask.last != numberMask.replacementCharacter {
//                                cursorePos = range.location - 1
//                            } else {
//                                cursorePos = range.location
//                            }
//                        }
//                    }
//                } else {
//                    let charIdx = text.index(text.startIndex, offsetBy: range.location)
//                    if !string.isEmpty {
//                        text.insert(contentsOf: string, at: charIdx)
//                        cursorePos = range.location + string.count
//                    } else {
//                        text.remove(at: charIdx)
//                        cursorePos = range.location
//                    }
//                }
//            }
//        }
//
//        if let numberMask = numberMask {
//            let count = numberMask.maxTextLength
//            if text.count > count {
//                text = String(text[..<String.Index(utf16Offset: count, in: text)])
//            }
//        }
//
//        setText(text)
//
//        if let cursorePos = cursorePos {
//            if let newPos = textField.position(from: textField.beginningOfDocument, offset: cursorePos) {
//                textField.selectedTextRange = textField.textRange(from: newPos, to: newPos)
//            }
//        }
//
//        return false
//    }
//
//    /// Обновить текст в подсказке поля ввода
//    private func updatePlaceholderText() {
//        if let text = placeholderText {
//            let attr = [NSAttributedString.Key.foregroundColor: placeholderColor ?? UIColor(.nuumTextTertiary)]
//            textField.attributedPlaceholder = NSAttributedString(string: text, attributes: attr)
//        } else {
//            textField.attributedPlaceholder = nil
//        }
//    }
//}
//
//// MARK: - Helpers
//extension NuumTextInputField {
//    private func makeDoneToolbar() -> UIToolbar {
//        let keyboardToolbar = UIToolbar()
//        keyboardToolbar.sizeToFit()
//        let flexibleSpace = UIBarButtonItem(
//            barButtonSystemItem: .flexibleSpace,
//            target: nil,
//            action: nil
//        )
//        let doneButton = UIBarButtonItem(
//            barButtonSystemItem: .done,
//            target: self,
//            action: #selector(doneButtonAction)
//        )
//
//        keyboardToolbar.items = [.flexibleSpace(), doneButton]
//
//        return keyboardToolbar
//    }
//
//    @objc private func doneButtonAction() {
//        self.endEditing(true)
//    }
//}
//
//extension NuumTextInputField {
//    /// Маска для форматирования стоимости/цены
//    struct CurrencyMask: NuumTextInputFieldMaskProtocol {
//        // MARK: - Public properties
//        var pattern: String = "## ### ###  ₽"
//
//        let replacementCharacter: Character = "#"
//
//        var maxFormattedTextLenght: Int {
//            return pattern.count
//        }
//
//        var maxTextLength: Int {
//            return pattern.count - pattern.replacingOccurrences(of: String(replacementCharacter), with: "").count
//        }
//
//        // MARK: - Private properties
//
//        private var pureNumber: String?
//
//        // MARK: - Public methods
//
//        func formate(_ string: String?) -> String? {
//            guard let string = string else { return string }
//            let pureNumber = string.replacingOccurrences( of: "[^0-9]", with: "", options: .regularExpression)
//            let actualPattern = getActualPattern(byPureNumber: pureNumber) ?? pattern
//
//            return string.applyPatternOnNumbers(
//                pattern: actualPattern,
//                replacementCharacter: replacementCharacter
//            )
//        }
//
//        // MARK: - Private methods
//
//        /// Паттерн маски в зависимости от длины числа
//        /// - Parameter pureNumber: Числовое представление числа в формате строки
//        /// - Returns: Подходящая под значение маска
//        private func getActualPattern(byPureNumber pureNumber: String?) -> String? {
//            switch pureNumber?.count ?? 0 {
//            case 1: "# ₽"
//            case 2: "## ₽"
//            case 3: "### ₽"
//            case 4: "# ### ₽"
//            case 5: "## ### ₽"
//            case 6: "### ### ₽"
//            case 7: "# ### ### ₽"
//            case 8: "## ### ### ₽"
//            default: nil
//            }
//        }
//    }
//}
