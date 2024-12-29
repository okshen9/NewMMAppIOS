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
    
    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Заполните данные о себе"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        return label
    }()
    
    private let firstNameTextField = UITextField.createTextField(placeholder: "Имя")
    private let lastNameTextField = UITextField.createTextField(placeholder: "Фамилия")
    private let occupationTextField = UITextField.createTextField(placeholder: "Род деятельности")
    private let cityTextField = UITextField.createTextField(placeholder: "Город проживания")
    
    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.isEnabled = false
        button.backgroundColor = .systemGray
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    // MARK: - ViewModel
    private var viewModel = UserInfoViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(titleLabel)
        view.addSubview(firstNameTextField)
        view.addSubview(lastNameTextField)
        view.addSubview(occupationTextField)
        view.addSubview(cityTextField)
        view.addSubview(doneButton)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.centerX.equalToSuperview()
        }
        
        firstNameTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        lastNameTextField.snp.makeConstraints { make in
            make.top.equalTo(firstNameTextField.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        occupationTextField.snp.makeConstraints { make in
            make.top.equalTo(lastNameTextField.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        cityTextField.snp.makeConstraints { make in
            make.top.equalTo(occupationTextField.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        doneButton.snp.makeConstraints { make in
            make.top.equalTo(cityTextField.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
    }
    
    // MARK: - Bind ViewModel
    private func bindViewModel() {
        firstNameTextField.textPublisher
            .assign(to: \.firstName, on: viewModel)
            .store(in: &cancellables)
        
        lastNameTextField.textPublisher
            .assign(to: \.lastName, on: viewModel)
            .store(in: &cancellables)
        
        occupationTextField.textPublisher
            .assign(to: \.occupation, on: viewModel)
            .store(in: &cancellables)
        
        cityTextField.textPublisher
            .assign(to: \.city, on: viewModel)
            .store(in: &cancellables)
        
        viewModel.$isFormValid
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isValid in
                self?.doneButton.isEnabled = isValid
                self?.doneButton.backgroundColor = isValid ? .systemBlue : .systemGray
            }
            .store(in: &cancellables)
        
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func doneButtonTapped() {
        let profileVC = ProfileVC()
        navigationController?.pushViewController(profileVC, animated: true)
    }
}

extension UITextField {
    static func createTextField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        return textField
    }
    
    var textPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: self)
            .map { ($0.object as? UITextField)?.text ?? "" }
            .eraseToAnyPublisher()
    }
}
