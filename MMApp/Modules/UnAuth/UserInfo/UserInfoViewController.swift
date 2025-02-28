//
//  UserInfoViewController.swift
//  MMApp
//
//  Created by artem on 29.12.2024.
//

import UIKit
import SnapKit
import Combine

class UserInfoViewController: UIViewController {
    private let apiFactory = APIFactory.global
    
    // MARK: - UI Elements
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.keyboardDismissMode = .interactive
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView = UIView().apply {
        $0.backgroundColor = .secondbackGraund
        $0.setCornerRadius(34)
    }
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Регистация"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.textColor = .headerText
        return label
    }()
    
    private let subLabel: UILabel = {
        let label = UILabel()
        label.text = "Расскажите о себе"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .center
        label.textColor = .subtitleText
        return label
    }()
    
    lazy var headerStack = [titleLabel, subLabel]
        .toVerticalStackView()
        .spaced(0)
        .build()
    
    private let activity = CustomActivityIndicator(image: UIImage.whiteLoader24)
    
    private let firstNameTextField = UITextField.createTextField2(placeholder: "Имя")
    private let lastNameTextField = UITextField.createTextField2(placeholder: "Фамилия")
    private let userNameTextField = UITextField.createTextField2(placeholder: "Имя пользователя в телеграмм")
    private let occupationTextField = UITextField.createTextField2(placeholder: "Род деятельности")
    private let cityTextField = UITextField.createTextField2(placeholder: "Город проживания")
    private let phoneNumberTextField = UITextField.createTextField2(placeholder: "Номер телефона")
    
    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.isEnabled = false
        button.backgroundColor = .mainRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let stackView = UIStackView().apply {
        $0.axis = .vertical
        $0.spacing = 20
    }
    
    init(viewModel: UserInfoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.setVC(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ViewModel
    private var viewModel: UserInfoViewModel {
        didSet {
            viewModel.setVC(self)
        }
    }
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        (userNameTextField.arrangedSubviews.last! as! UITextField).text = "ArtemNeshko2"
//        (userNameTextField.arrangedSubviews.last! as! UITextField).isEnabled = false
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(view.layoutMarginsGuide.snp.height)
            $0.width.equalTo(view.snp.width)
        }
        
        stackView.addArrangedSubviews(
            headerStack,
            firstNameTextField,
            lastNameTextField,
            userNameTextField,
            occupationTextField,
            cityTextField,
            phoneNumberTextField,
            doneButton
        )
        
        doneButton.addSubview(activity)
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        

        
        
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
//            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(20)
        }
        
        activity.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        // TODO: МБ лучше
        [
            firstNameTextField,
            lastNameTextField,
            userNameTextField,
            occupationTextField,
            cityTextField,
            phoneNumberTextField
        ].forEach({
            $0.snp.makeConstraints {
                $0.height.equalTo(56)
                $0.leading.trailing.equalToSuperview()
            }
        })
        
        doneButton.snp.makeConstraints {
            $0.height.equalTo(36)
        }
        view.setNeedsUpdateConstraints()
        view.setNeedsLayout()
    }
    
    // MARK: - Bind ViewModel
    private func bindViewModel() {
        (firstNameTextField.arrangedSubviews.last! as! UITextField).textPublisher
            .assign(to: \.firstName, on: viewModel)
            .store(in: &cancellables)
        
        (lastNameTextField.arrangedSubviews.last! as! UITextField).textPublisher
            .assign(to: \.lastName, on: viewModel)
            .store(in: &cancellables)
        
        (occupationTextField.arrangedSubviews.last! as! UITextField).textPublisher
            .assign(to: \.occupation, on: viewModel)
            .store(in: &cancellables)
        
        (cityTextField.arrangedSubviews.last! as! UITextField).textPublisher
            .assign(to: \.city, on: viewModel)
            .store(in: &cancellables)
        
        (userNameTextField.arrangedSubviews.last! as! UITextField).textPublisher
            .assign(to: \.userName, on: viewModel)
            .store(in: &cancellables)
        
        (phoneNumberTextField.arrangedSubviews.last! as! UITextField).textPublisher
            .assign(to: \.phoneNumber, on: viewModel)
            .store(in: &cancellables)
        
        viewModel.$isFormValid
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isValid in
                self?.doneButton.isEnabled = isValid
                self?.doneButton.backgroundColor = isValid ? .mainRed : .systemGray
            }
            .store(in: &cancellables)
        
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func doneButtonTapped() {
        Task {
            activity.startAnimating()
            doneButton.isEnabled = false
            doneButton.backgroundColor = .systemGray
            await viewModel.createProfile()
            
            activity.stopAnimating()
            doneButton.isEnabled = true
            doneButton.backgroundColor = .mainRed
        }
    }
}

extension UITextField {
    static func createTextField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.setCornerRadius(8)
//        textField.setBorder(width: 1, color: .lightGray)
//        textField.borderStyle = .
        textField.backgroundColor = .textFieldBack
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textField.textColor = .headerText
        return textField
    }
    
    static func createTextField2(placeholder: String) -> UIStackView {
        let textField = createTextField(placeholder: placeholder)
        let label = UILabel().apply {
            $0.text = placeholder
            $0.font = .systemFont(ofSize: 14, weight: .regular)
            $0.setContentHuggingPriority(.required, for: .vertical)
        }
        let stack = [label, textField]
            .toVerticalStackView()
            .with(alignment: .leading)
            .spaced(4)
            .build()
        textField.snp.makeConstraints {
            $0.leading.right.equalToSuperview()
        }
        return stack
    }
    
    var textPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: self)
            .map { ($0.object as? UITextField)?.text ?? "" }
            .eraseToAnyPublisher()
    }
}
